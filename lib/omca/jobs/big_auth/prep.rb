# frozen_string_literal: true

module Omca
  module Jobs
    module BigAuth
      module Prep
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :authorities__fix_uniq_usages,
              destination: :big_auth__prep
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform FilterRows::WithLambda,
              action: :keep,
              lambda: ->(row) do
                row[:occurrences].to_i > 9000
              end
            transform Sort::ByFieldValue,
              field: :occurrences,
              order: :desc

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
