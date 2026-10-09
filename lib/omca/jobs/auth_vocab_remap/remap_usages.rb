# frozen_string_literal: true

module Omca
  module Jobs
    module AuthVocabRemap
      module RemapUsages
        module_function

        def self.desc(args) = "Remaps diverted usages for #{args[:table]}."\
          "#{args[:field]}. These will be merged back in by "\
          ":authorities__usages_final_source"

        def job(args)
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :"auth_vocab_remap__#{args[:source]}",
              destination: :"auth_vocab_remap__#{args[:name]}"
            },
            transformer: xforms(table: args[:table], field: args[:field])
          )
        end

        def xforms(table:, field:)
          Kiba.job_segment do
            if table == "objectexit_common" && field == "depositor"
              transform do |row|
                row[:tabletype] = "repeatable_field"
                row[:table] = "exits_common_owners"
                row[:field] = "item"
                row[:pos] = "0"
                row
              end
            end
          end
        end
      end
    end
  end
end
