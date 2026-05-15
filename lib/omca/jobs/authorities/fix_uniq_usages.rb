# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      module FixUniqUsages
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :authorities__fix_usages,
              destination: :authorities__fix_uniq_usages
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Delete::FieldsExcept,
              fields: %i[authority vocab termid index form]
            transform Deduplicate::Table,
              field: :index,
              delete_field: false,
              include_occs: true,
              compile_uniq_fieldvals: true
            # transform Sort::ByFieldValue,
            #   field: :occurrences,
            #   order: :desc
          end
        end
      end
    end
  end
end
