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

  no_commands do
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
  end
end
