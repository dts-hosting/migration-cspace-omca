# frozen_string_literal: true

module Omca
  module Jobs
    module OptList
      class Usages
        def initialize
          @holder = Set.new
        end

        def path = Omca.registry.resolve(:optlist__usages).path

        def run
          Omca::OptList.source_fields_to_opt_list
            .each { |table, fields| extract_from(table, fields) }

          CSV.open(
            path,
            "w",
            headers: %i[optionlist value],
            write_headers: true
          ) do |csv|
            holder.each { |row| csv << row }
          end

          puts "Wrote #{holder.length} optlist usages to #{path}"
        end

        def outrows = holder.length

        private

        attr_reader :holder

        def extract_from(table, fields)
          table_key = :"fcarmerge_#{table[0]}__#{table[1]}"
          table_path = Omca.registry.resolve(table_key).path
          unless File.exist?(table_path)
            Kiba::Extend::Command::Run.job(table_key)
          end

          fields.each { |field_info| extract_vals(field_info, table_path) }
        end

        def extract_vals(field_info, table_path)
          optlist = field_info[0]
          field = field_info[1]

          result = `#{cmd(field, table_path)}`.chomp
            .split("\n")
            .map { |val| [optlist, val] }

          result.each { |res| holder << res }
        end

        def cmd(field, path)
          "xan select #{field} #{path} | "\
            "xan dedup -s #{field} | "\
            "xan search -N -s #{field} | "\
            "xan behead"
        end
      end
    end
  end
end
