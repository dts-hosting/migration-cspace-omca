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
        when "citationtermgroup"
          base << {
            jobkey: :"#{prev}_addtl_fields__citations_omca",
            lookup_on: :recordcsid,
            name: :citations_omca
          }
        when "collectionobjects_common_responsibledepartments"
          base << {
            jobkey: :"#{prev}_addtl_fields__collectionobjects_omca",
            lookup_on: :recordcsid,
            name: :collectionobjects_omca
          }
        when "conditionchecks_common"
          # rubocop:disable Layout/LineLength
          base << {
            jobkey: :"#{prev}_repeatable_field__conditionchecks_omca_omcaconditioncheckmethods",
            lookup_on: :recordcsid,
            name: :omcaconditioncheckmethods
          }
          # rubocop:enable Layout/LineLength
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
            citations_omca
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
          when "addressgroup"
            fieldmap = {
              addresscountryomca: :addresscountry,
              addressmunicipalityomca: :addressmunicipality,
              addressplace1omca: :addressplace1,
              addressplace2omca: :addressplace2,
              addresspostcodeomca: :addresspostcode,
              addressstateorprovinceomca: :addressstateorprovince,
              addresstypeomca: :addresstype
            }
            transform Delete::Fields,
              fields: :addressnoteomca
            transform Rename::Fields, fieldmap: fieldmap
            transform FilterRows::AnyFieldsPopulated,
              action: :keep,
              fields: fieldmap.values
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
          when "citationtermgroup"
            transform Rename::Field, from: :termtype, to: :termflag
            transform Merge::MultiRowLookup,
              lookup: citations_omca,
              keycolumn: :recordcsid,
              fieldmap: {termtype: :publicationtype},
              conditions: ->(r, rows) do
                return [] unless r[:pos] == "0"

                rows
              end
          when "collectionobjects_common_controlledcontentplaces"
            transform Delete::Fields,
              fields: %i[rectype assocplacenote]
            transform CombineValues::FromFieldsWithDelimiter,
              sources: %i[assocplace item],
              target: :item,
              delete_sources: true,
              delim: " "
          when "collectionobjects_common_namedcollections"
            transform FilterRows::FieldPopulated,
              action: :keep,
              field: :collection
            transform Delete::FieldsExcept,
              fields: %i[recordcsid id collection]
            transform Merge::ConstantValue,
              target: :pos,
              value: "0"
          when "collectionobjects_common_responsibledepartments"
            transform Omca::Xforms::Remap::MergeArtHistoryScienceRespdepts,
              lookup: collectionobjects_omca
          when "collectionobjects_nagpra_nagpracategories"
            transform Omca::Xforms::Remap::RepeatableFieldTable
          when "collectionobjects_nagpra_nagprainventorynames"
            transform Omca::Xforms::Remap::RepeatableFieldTable
          when "collectionobjects_omca"
            transform Delete::Fields,
              fields: %i[art history science]
          when "conditionchecks_common"
            transform Merge::MultiRowLookup,
              lookup: omcaconditioncheckmethods,
              keycolumn: :recordcsid,
              fieldmap: {o_conditioncheckmethod: :item},
              conditions: ->(_r, rows) { rows.select { |r| r[:pos] == "0" } }
            transform Merge::MultiRowLookup,
              lookup: omcaconditioncheckmethods,
              keycolumn: :recordcsid,
              fieldmap: {more_conditioncheckmethod: :item},
              conditions: ->(_r, rows) { rows.reject { |r| r[:pos] == "0" } },
              delim: "; "

            transform do |row|
              methexist = row.key?(:conditioncheckmethod)
              row[:conditioncheckmethod] = nil unless methexist

              ometh = row[:o_conditioncheckmethod]
              row.delete(:o_conditioncheckmethod)

              if methexist
                next row if ometh.blank?
                meth = row[:conditioncheckmethod]
                if meth.blank?
                  row[:conditioncheckmethod] = ometh
                else
                  row[:more_conditioncheckmethod] = [
                    ometh, row[:more_conditioncheckmethod]
                  ].join("; ")
                end
              else
                row[:conditioncheckmethod] = ometh
              end

              row
            end

            transform Prepend::ToFieldValue,
              field: :more_conditioncheckmethod,
              value: "Additional condition check methods: "
            transform CombineValues::FromFieldsWithDelimiter,
              sources: %i[conditionchecknote more_conditioncheckmethod],
              target: :conditionchecknote,
              delete_sources: true,
              delim: "\n\n"
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
          when "restrictedmedia_common_publishtolist"
            transform Omca::Xforms::Remap::SvFieldToRepeatableFieldTable,
              fieldmap: {approveforpublic: :item}
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
