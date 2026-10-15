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
        when "exits_common"
          base << {
            jobkey: :structured_dates__exitdate,
            lookup_on: :recordcsid,
            name: :dates
          }
        end

        base
      end

      def xforms(table, tabletype, rectype)
        Kiba.job_segment do
          drop_tables = %w[
            accessrestrictiongroup
            acquisitioncontactgroup
            acquisitions_omca
            collectionobjects_anthropology_nagpraapplicabilitylist
            collectionobjects_anthropology_nagprainventorynamelist
            collectionobjects_omca
            exitstatusgroup
            objectexit_common
            objectexit_common_exitmethods
            viewercontributiongroup
            viewerreferences
          ]
          transform Omca::Xforms::DropAllRows if drop_tables.include?(table)

          case table
          when "accesslimitationsgroup"
            transform Omca::Xforms::Remap::BuildAccesslimitationsgroup
          when "acquisitions_common"
            transform Omca::Xforms::Remap::AcquisitionsOmcaAccessiondescription,
              lookup: acquisitions_omca
          when "acquisitions_common_acquisitionsources"
            transform Omca::Xforms::Remap::AcquisitionsOmcaAnonymous,
              lookup: acquisitions_omca
          when "approvalstatusgroup"
            transform Clean::RegexpFindReplaceFieldVals,
              fields: :rectype,
              find: "objectexit",
              replace: "exit"
            transform Rename::Fields, fieldmap: {
              exitstatus: :status,
              exitstatusdate: :date
            }
            transform FilterRows::AnyFieldsPopulated,
              action: :keep,
              fields: %i[status date]
          when "collectionobjects_nagpra_nagpracategories"
            transform Omca::Xforms::Remap::RepeatableFieldTable
          when "collectionobjects_nagpra_nagprainventorynames"
            transform Omca::Xforms::Remap::RepeatableFieldTable
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
          when "exits_common"
            transform Rename::Fields, fieldmap: {
              exitnote: :note,
              exitreason: :reason
            }
            transform Clean::DowncaseFieldValues,
              fields: :reason
            transform Omca::Xforms::Remap::UnstructureExitdates,
              lookup: dates
            transform Delete::Fields,
              fields: :depositor
          when "exits_common_owners"
            transform Delete::FieldsExcept, fields: %i[recordcsid id depositor]
            transform FilterRows::FieldPopulated,
              action: :keep,
              field: :depositor
            transform Merge::ConstantValue, target: :pos, value: "0"
          when "media_common_publishtolist"
            transform Omca::Xforms::Remap::SvFieldToRepeatableFieldTable,
              fieldmap: {approveforpublic: :item}
          when "partiesinvolvedgroup"
            transform Omca::Xforms::Remap::BuildPartiesinvolvedgroup
          when "rightsgroup"
            transform Omca::Xforms::Remap::SvFieldToRepeatableFieldTable,
              fieldmap: {ipaudit: :standardizedrightstatement}
            transform Merge::ConstantValue,
              target: :rectype,
              value: "collectionobject"
          when "taxonomicidentgroup"
            transform Omca::Xforms::Remap::BuildTaxonomicidentgroup
          end
        end
      end
    end
  end
end
