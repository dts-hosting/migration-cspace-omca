# frozen_string_literal: true

module Omca
  module Jobs
    module Rels
      module CollectionobjectConsultationSource
        module_function

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :remap_main__consultations_common,
              destination: :rels_source_nonhier__collectionobject_consultation
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform Delete::FieldsExcept,
              fields: %i[recordcsid pos]

            transform do |row|
              row[:subjectcsid] = row[:recordcsid].sub(/_\d+$/, "")

              row
            end

            transform Delete::Fields,
              fields: :pos
            transform Rename::Field,
              from: :recordcsid,
              to: :objectcsid
          end
        end
      end
    end
  end
end
