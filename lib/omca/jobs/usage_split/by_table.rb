# frozen_string_literal: true

module Omca
  module Jobs
    module UsageSplit
      module ByTable
        module_function

        def job(type:, table:)
          source = :"usages_by_table_type__#{type}"
          destination = :"usages_by_table__#{table}"
          files = {
            source: source,
            destination: destination
          }

          unless Kiba::Extend::Job.output?(source)
            return Kiba::Extend::Jobs::NullJob.new(files: files)
          end

          Kiba::Extend::Jobs::Job.new(
            files: files,
            transformer: xforms(table)
          )
        end

        def xforms(table)
          Kiba.job_segment do
            transform FilterRows::FieldEqualTo,
              action: :keep,
              field: :table,
              value: table
          end
        end
      end
    end
  end
end
