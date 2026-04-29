# frozen_string_literal: true

class Db < Thor
  desc "main_tables", "Write main tables to `main_rectype` dir as CSV"
  def main_tables
    caller(
      tables: Omca::Mappings.main_tables,
      table_type: "main_rectype",
      query_meth: :main_table
    )
  end

  desc "repeating_field_tables", "Write repeating field tables to "\
    "`repeating` dir as CSV"
  def repeating_field_tables
    caller(
      tables: Omca::Mappings.repeating_field_tables,
      table_type: "repeating",
      query_meth: :repeating_field_table
    )
  end

  desc "addtl_fields_tables", "Write other "\
    "direct-id-linked tables to `addtl_fields` dir as CSV"
  def addtl_fields_tables
    caller(
      tables: Omca::Mappings.addtl_fields_tables,
      table_type: "addtl_fields",
      query_meth: :addtl_fields_table
    )
  end

  desc "group_tables", "Write repeatable field group tables "\
    "to `field_groups` dir as CSV"
  def group_tables
    caller(
      tables: Omca::Mappings.group_tables,
      table_type: "field_groups",
      query_meth: :group_table
    )
  end

  desc "subgroup_tables", "Write repeatable field subgroup tables "\
    "to `field_subgroups` dir as CSV"
  def subgroup_tables
    caller(
      tables: Omca::Mappings.subgroup_tables,
      table_type: "field_subgroups",
      query_meth: :subgroup_table
    )
  end

  no_commands do
    def caller(tables:, table_type:, query_meth:)
      results = {}
      type = table_type

      tables.each do |arr|
        args = [arr].flatten
        table = args[0]
        queryargs = args.compact

        path = File.join(Omca.datadir, type, "#{table}.csv")
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
  end
end
