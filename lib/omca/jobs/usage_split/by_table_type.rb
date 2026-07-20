# frozen_string_literal: true

module Omca
  module Jobs
    module UsageSplit
      module ByTableType
        module_function

        def job(type:)
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :authorities__usages_new_refname,
              destination: :"usages_by_table_type__#{type}"
            },
            transformer: xforms(type)
          )
        end

        def xforms(type)
          Kiba.job_segment do
            transform FilterRows::FieldEqualTo,
              action: :keep,
              field: :tabletype,
              value: type
          end
        end
      end
    end
  end
end
