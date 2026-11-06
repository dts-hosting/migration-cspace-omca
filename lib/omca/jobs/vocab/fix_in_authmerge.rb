# frozen_string_literal: true

module Omca
  module Jobs
    module Vocab
      module FixInAuthmerge
        module_function

        def desc = "Terms whose form needs to be normalized as part of the "\
          "authmerge phase"

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :vocab__diff,
              destination: :vocab__fix_in_authmerge
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform FilterRows::FieldPopulated,
              action: :keep,
              field: :different_form
            transform Delete::FieldsExcept,
              fields: %i[vocab term in_target_form]
            transform Rename::Fields, fieldmap: {
              term: :source,
              in_target_form: :target
            }
          end
        end
      end
    end
  end
end
