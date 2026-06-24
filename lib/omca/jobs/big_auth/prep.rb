# frozen_string_literal: true

module Omca
  module Jobs
    module BigAuth
      module Prep
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :unlinked_auth__uniq_usages_final,
              destination: :big_auth__prep
            },
            transformer: [
              Omca::Authorities.add_term_index,
              xforms
            ]
          )
        end

        def xforms
          Kiba.job_segment do
            transform FilterRows::WithLambda,
              action: :keep,
              lambda: ->(row) do
                row[:usagect].to_i > 9000
              end
            transform Sort::ByFieldValue,
              field: :usagect,
              order: :desc
            transform Rename::Field,
              from: :usagect,
              to: :occurrences
            transform Fingerprint::Add,
              fields: %i[index form],
              target: :matchfingerprint
            transform do |row|
              val = row[:form]
              next row unless val[Omca.delim]

              row[:form] = val.split(Omca.delim).first
              row
            end
          end
        end
      end
    end
  end
end
