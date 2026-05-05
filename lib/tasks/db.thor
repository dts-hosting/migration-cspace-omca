# frozen_string_literal: true

class Db < Thor
  desc "main_tables", "Write main tables to `main_rectype` dir as CSV"
  def main_tables
    caller(
      tables: Omca::Mappings::Db.main_tables,
      table_type: "main_rectype",
      query_meth: :main_table
    )
  end

  desc "repeating_field_tables", "Write repeating field tables to "\
    "`repeating` dir as CSV"
  def repeating_field_tables
    caller(
      tables: Omca::Mappings::Db.repeating_field_tables,
      table_type: "repeating",
      query_meth: :repeating_field_table
    )
  end

  desc "addtl_fields_tables", "Write other "\
    "direct-id-linked tables to `addtl_fields` dir as CSV"
  def addtl_fields_tables
    caller(
      tables: Omca::Mappings::Db.addtl_fields_tables,
      table_type: "addtl_fields",
      query_meth: :addtl_fields_table
    )
  end

  desc "group_tables", "Write repeatable field group tables "\
    "to `field_groups` dir as CSV"
  def group_tables
    caller(
      tables: Omca::Mappings::Db.group_tables,
      table_type: "field_groups",
      query_meth: :group_table
    )
  end

  desc "repeatable_in_group_tables", "Write repeatable field group tables "\
    "to `field_groups` dir as CSV"
  def repeatable_in_group_tables
    caller(
      tables: Omca::Mappings::Db.repeatable_in_group_tables,
      table_type: "repeatable_in_group",
      query_meth: :repeatable_in_group_table
    )
  end

  desc "subgroup_tables", "Write repeatable field subgroup tables "\
    "to `field_subgroups` dir as CSV"
  def subgroup_tables
    caller(
      tables: Omca::Mappings::Db.subgroup_tables,
      table_type: "field_subgroups",
      query_meth: :subgroup_table
    )
  end

  desc "contacts", "Write main contacts table to `main_rectype` dir "\
    "as CSV"
  def contacts
    path = File.join(Omca.datadir, "orig", "subrecord", "contacts_common.csv")
    query = Omca::Db::Queries.contacts
    Omca::Db::QueryWriter.call(query: query, path: path)
  end

  desc "blobs", "Write main blobs table to `main_rectype` dir "\
    "as CSV"
  def blobs
    path = File.join(Omca.datadir, "orig", "subrecord", "blobs_common.csv")
    query = Omca::Db::Queries.blobs
    Omca::Db::QueryWriter.call(query: query, path: path)
  end

  desc "structured_dates", "Writes structured date data to "\
    "`structured_dates` dir as CSV"
  def structured_dates
    path = File.join(Omca.datadir, "orig", "structured_dates", "nested.csv")
    query = Omca::Db::Queries.nested_structured_dates
    Omca::Db::QueryWriter.call(query: query, path: path)

    path = File.join(Omca.datadir, "orig", "structured_dates", "top.csv")
    query = Omca::Db::Queries.top_level_structured_dates
    Omca::Db::QueryWriter.call(query: query, path: path)
  end

  desc "tables_and_columns", "writes CSV of tables and columns"
  def tables_and_columns
    path = File.join(Omca.datadir, "db_tables_columns.csv")
    csv = CSV.open(
      path,
      "w",
      headers: %w[tabletype table column rectype],
      write_headers: true
    )
    Omca.orig_dirs.each { |dir| extract_from_files(dir, csv) }
    csv.close
    puts "Wrote db tables and columns to #{path}"

    dupecheck = {}
    CSV.parse(File.read(path), headers: true).each do |row|
      next if row["rectype"].blank?

      key = [row["rectype"], row["column"]].join(".")
      dupecheck[key] = [] unless dupecheck.key?(key)
      dupecheck[key] << row["table"]
    end
    dupes = dupecheck.select { |_k, v| v.length > 1 }
    return if dupes.empty?

    puts "Duplicate column names in rectype:"
    dupes.each { |k, v| puts "  #{k} is in tables: #{v.join(", ")}" }
  end

  desc "missing_id", "Identify orig tables without an id field"
  def missing_id
    path = File.join(Omca.datadir, "tables_missing_ids.csv")
    CSV.open(
      path,
      "w",
      headers: %w[tabletype table headers],
      write_headers: true
    )
    acc = []
    Omca.orig_dirs.each { |dir| chk_dir_files_for_id_field(dir, acc) }
    if acc.empty?
      puts "No tables missing id field"
    else
      CSV.open(
        path,
        "w",
        headers: %w[tabletype table headers],
        write_headers: true
      ) { |csv| acc.each { |r| csv << r } }
      puts "Wrote #{acc.length} tables to #{path}"
    end
  end

  no_commands do
    def chk_dir_files_for_id_field(dir, acc)
      dirpath = File.join(Omca.datadir, "orig", dir)
      Dir.children(dirpath).each do |filename|
        chk_dir_file_for_id_field(dir, dirpath, filename, acc)
      end
    end

    def chk_dir_file_for_id_field(dir, dirpath, filename, acc)
      filepath = File.join(dirpath, filename)
      headers = csv_headers(filepath)
      return if headers.include?("id")

      acc << [dir, File.basename(filename, ".csv"), headers.join(Omca.delim)]
    end

    def caller(tables:, table_type:, query_meth:)
      results = {}
      type = table_type

      tables.each do |arr|
        args = [arr].flatten
        table = args[0]
        queryargs = args.compact

        path = File.join(Omca.datadir, "orig", type, "#{table}.csv")
        query = Omca::Db::Queries.send(query_meth, *queryargs)
        puts "Querying #{table}"
        results[table] = Omca::Db::QueryWriter.call(query: query, path: path)
        report(type, results)
      end
    end

    def report(type, results)
      path = File.join(Omca.datadir, "reports", "#{type}_db_table_extract.csv")
      headers = %w[table rowct]
      CSV.open(path, "w", headers: headers, write_headers: true) do |csv|
        results.each { |k, v| csv << [k, v] }
      end
    end

    def extract_from_files(dir, csv)
      dirpath = File.join(Omca.datadir, "orig", dir)
      Dir.children(dirpath).each do |filename|
        extract_from_file(dir, filename, csv)
      end
    end

    def csv_headers(path)
      File.new(path).readline
        .chomp
        .split(",")
    end

    def extract_from_file(dir, filename, csv)
      filepath = File.join(Omca.datadir, "orig", dir, filename)
      puts "Extracting from #{filepath}"
      table = File.basename(filename, ".csv")
      base = {
        "tabletype" => dir,
        "table" => table,
        "rectype" => Omca::Mappings::Db.rectype_for_table(table)
      }

      csv_headers(filepath).each do |field|
        next if %w[csid deprecated groupid id item parentcsid proposed
          pos recordcsid sas].include?(field)

        data = base.dup.merge({"column" => field})
        csv << data.values_at(*csv.headers)
      end
    end
  end
end
