# frozen_string_literal: true

module Omca
  module Jobs
    module Rels
      module ByType
        module_function

        def job(dest:, reltype:)
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :rel_info__types_uniq,
              destination: dest
            },
            transformer: xforms(reltype)
          )
        end

        def xforms(reltype)
          Kiba.job_segment do
            transform FilterRows::FieldEqualTo,
              action: :keep,
              field: :reltype,
              value: reltype
          end
        end
      end
    end
  end
end
