# frozen_string_literal: true

module Omca
  module Jobs
    module Remap
      module_function

      # @param source [Array<Symbol>]
      # @param dest [Symbol]
      # @param table [String]
      # @param tabletype [String]
      # @param rectype [String]
      def job(source:, dest:, table:, tabletype:, rectype:)
        Kiba::Extend::Jobs::Job.new(
          files: {
            source: source,
            destination: dest,
            lookup: get_lookups(table)
          },
          transformer: xforms(table, tabletype, rectype)
        )
      end

      def get_lookups(table)
        base = []
        prev = Omca::RegistryData.previous_phase("remap")
        case table
        when "acquisitions_common"
          base << {
            jobkey: :"#{prev}_addtl_fields__acquisitions_omca",
            lookup_on: :recordcsid,
            name: :acquisitions_omca
          }
        when "acquisitions_common_acquisitionsources"
          base << {
            jobkey: :"#{prev}_addtl_fields__acquisitions_omca",
            lookup_on: :recordcsid,
            name: :acquisitions_omca
          }
        when "consultations_common"
          base << {
            jobkey: :"#{prev}_main__collectionobjects_common",
            lookup_on: :recordcsid,
            name: :collectionobjects_common
          }
        when "consultations_common_notes"
          base << {
            jobkey: :"#{prev}_repeatable_in_group__viewerreferences",
            lookup_on: :groupid,
            name: :viewerreferences
          }
        end

        base
      end

      def xforms(table, tabletype, rectype)
        Kiba.job_segment do
          case table
          when "acquisitioncontactgroup"
            transform Omca::Xforms::DropAllRows
          when "acquisitions_common"
            transform Omca::Xforms::Remap::AcquisitionsOmcaAccessiondescription,
              lookup: acquisitions_omca
          when "acquisitions_common_acquisitionsources"
            transform Omca::Xforms::Remap::AcquisitionsOmcaAnonymous,
              lookup: acquisitions_omca
          when "acquisitions_omca"
            transform Delete::Fields,
              fields: %i[accessiondescription anonymous]
          when "partiesinvolvedgroup"
            transform Omca::Xforms::Remap::BuildPartiesinvolvedgroup
            transform FilterRows::WithLambda,
              action: :reject,
              lambda: ->(row) do
                row[:involvedparty].blank? && row[:involvedrole].blank?
              end
          when "consultations_common"
            transform Omca::Xforms::Remap::BuildConsultationCommon,
              lookup: collectionobjects_common
          when "consultations_common_consultationoutcomes"
            transform Omca::Xforms::Remap::BuildConsultationOutcomes
            transform FilterRows::FieldPopulated,
              action: :keep,
              field: :item
          when "consultations_common_notes"
            transform Omca::Xforms::Remap::BuildConsultationNotes,
              lookup: viewerreferences
            transform FilterRows::FieldPopulated,
              action: :keep,
              field: :item
          when "viewercontributiongroup"
            transform Omca::Xforms::DropAllRows
          when "viewerreferences"
            transform Omca::Xforms::DropAllRows
          end
        end
      end
    end
  end
end
