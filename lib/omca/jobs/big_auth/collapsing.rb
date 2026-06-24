# frozen_string_literal: true

module Omca
  module Jobs
    module BigAuth
      module Collapsing
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :big_auth__final,
              destination: :big_auth__collapsing
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform FilterRows::FieldEqualTo,
              action: :keep,
              field: :collapsingterm,
              value: "y"
            transform Delete::FieldsExcept,
              fields: %i[form rectype index userefname]
            transform Rename::Fields, fieldmap: {
              userefname: :refname,
              form: :oldform
            }
            transform do |row|
              row[:targettermid] = Omca::Refname.parse(row[:refname])
                .identifier
              row
            end
          end
        end
      end
    end
  end
end
