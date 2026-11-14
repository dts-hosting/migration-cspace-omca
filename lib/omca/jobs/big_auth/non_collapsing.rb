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
            transform Rename::Fields, fieldmap: {
              form: :oldform
            }
            transform Copy::Field,
              from: :termid,
              to: :targettermid

            transform do |row|
              refname = row[:refname]

              row[:refname] = refname.sub(
                "'#{row[:oldform]}'", "'#{row[:new_form]}'"
              )

              row
            end

            transform Delete::FieldsExcept,
              fields: %i[index rectype refname oldform targettermid termid]
          end
        end
      end
    end
  end
end
