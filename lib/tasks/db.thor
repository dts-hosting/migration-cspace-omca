# frozen_string_literal: true

class Db < Thor
  desc "main_tables", "Write main tables to orig dir as CSV"
  def main_tables
    Omca::Mappings.main_tables.each do |table|
      path = File.join(Omca.datadir, "main_rectype", "#{table}.csv")
      query = Omca::Db::Queries.main_table(table)
      puts "Querying/writing #{table}"
      Omca::Db::QueryWriter.call(query: query, path: path)
    end
  end
end
