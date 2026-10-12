# frozen_string_literal: true

module Omca
  module Jobs
    module Vocab
      class Usages
        include Omca::DynamicCsvJobable

        def initialize
          @holder = Set.new
        end

        def source = :remap_vocab_field_tables

        def destination = :vocab__usages

        def job_code
          Omca::Vocab.vocab_fields(:target)
            .each { |table, fields| extract_from(table, fields) }

          CSV.open(
            destination_path,
            "w",
            headers: %i[vocab term tablefield],
            write_headers: true
          ) do |csv|
            holder.each { |row| csv << row }
          end
        end

        private

        attr_reader :holder

        def extract_from(table, fields)
          table_key = :"remap_#{table[0]}__#{table[1]}"
          table_path = Omca.registry.resolve(table_key).path
          unless File.exist?(table_path)
            Kiba::Extend::Command::Run.job(table_key)
          end

          fields.each do |field_info|
            extract_vals(table, field_info, table_path)
          end
        end

        def extract_vals(table, field_info, table_path)
          termlist = field_info[0]
          field = field_info[1]
          tableval = "#{table[0]}__#{table[1]}"
          tablefield = "#{tableval}.#{field}"

          puts "Extracting from #{tablefield}"

          result = `#{cmd(field, table_path)}`.chomp
            .split("\n")
            .map { |val| [termlist, val, tablefield] }

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
