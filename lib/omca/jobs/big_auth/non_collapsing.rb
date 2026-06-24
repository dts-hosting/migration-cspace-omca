# frozen_string_literal: true

module Omca
  module Jobs
    module BigAuth
      module NonCollapsing
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :big_auth__final,
              destination: :big_auth__non_collapsing
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform FilterRows::FieldEqualTo,
              action: :keep,
              field: :collapsingterm,
              value: "n"
            transform Delete::Fields,
              fields: %i[collapsingterm userefname]
          end
        end
      end
    end
  end
end
