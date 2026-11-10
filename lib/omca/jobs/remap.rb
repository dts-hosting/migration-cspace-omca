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
        when "collectionobjects_common_comments"
          base << {
            jobkey: :"#{prev}_main__collectionobjects_common",
            lookup_on: :recordcsid,
            name: :collectionobjects
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
          base << {
            jobkey: :"#{prev}_addtl_fields__conditionchecks_omca",
            lookup_on: :recordcsid,
            name: :conditionchecks_omca
          }
        when "conservation_common"
          base << {
            jobkey: :"#{prev}_addtl_fields__conservation_omca",
            lookup_on: :recordcsid,
            name: :conservation_omca
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
        when "loansin_common"
          base << {
            jobkey: :"#{prev}_addtl_fields__loansin_omca",
            lookup_on: :recordcsid,
            name: :loansin_omca
          }
        when "loansout_common"
          base << {
            jobkey: :"#{prev}_repeatable_field_group__loanoutvenuesgroup",
            lookup_on: :recordcsid,
            name: :loanoutvenuesgroup
          }
          base << {
            jobkey: :"#{prev}_repeatable_field_group__loanoutfeesgroup",
            lookup_on: :recordcsid,
            name: :loanoutfeesgroup
          }
        when "media_common"
          base << {
            jobkey: :"#{prev}_addtl_fields__media_omca",
            lookup_on: :recordcsid,
            name: :media_omca
          }
        when "objectcomponentgroup"
          base << {
            jobkey: :"#{prev}_addtl_fields__collectionobjects_omca",
            lookup_on: :recordcsid,
            name: :collectionobjects_omca
          }
        when "organizations_common"
          base << {
            jobkey: :contact__addressnotes,
            lookup_on: :termcsid,
            name: :addressnotes
          }
        when "persons_common"
          base << {
            jobkey: :contact__addressnotes,
            lookup_on: :termcsid,
            name: :addressnotes
          }
        when "restrictedmedia_common"
          base << {
            jobkey: :"#{prev}_addtl_fields__restrictedmedia_omca",
            lookup_on: :recordcsid,
            name: :restrictedmedia_omca
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
            collectionobjects_omca_exhibitionhistories
            conservation_omca
            exitstatusgroup
            loansout_omca
            media_omca
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
          when "annotationgroup"
            transform Omca::Xforms::Remap::BuildArgusremarksPhotoAnnotations
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
          when "collectionobjects_anthro"
            transform Delete::FieldsExcept,
              fields: %i[recordcsid id argusdescription]
            transform FilterRows::FieldPopulated,
              action: :keep,
              field: :argusdescription
            transform Rename::Field,
              from: :argusdescription,
              to: :materialtechniquedescription
          when "collectionobjects_common"
            transform Delete::Fields, fields: :distinguishingfeatures
          when "collectionobjects_common_comments"
            transform Omca::Xforms::Remap::AddDistinguishingfeatureComments,
              lookup: collectionobjects
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
          when "collectionobjects_common_publishtolist"
            transform FilterRows::FieldPopulated,
              action: :keep,
              field: :donotpublishonweb
            transform Delete::FieldsExcept,
              fields: %i[recordcsid id donotpublishonweb]
            transform Rename::Field, from: :donotpublishonweb, to: :item
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
              lookup: conditionchecks_omca,
              keycolumn: :recordcsid,
              fieldmap: {envrecommendations: :envrecommendations}
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
          when "conservation_common"
            transform Merge::MultiRowLookup,
              lookup: conservation_omca,
              keycolumn: :recordcsid,
              fieldmap: {datefornote: :dateofanalysis}
            transform Prepend::ToFieldValue,
              field: :datefornote,
              value: "Date of analysis: "
            transform CombineValues::FromFieldsWithDelimiter,
              sources: %i[proposedanalysis datefornote],
              target: :proposedanalysis,
              delete_sources: true,
              delim: Omca.notedelim
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
          when "loansin_common"
            transform Merge::MultiRowLookup,
              lookup: loansin_omca,
              keycolumn: :recordcsid,
              fieldmap: {lendernote: :lendernote}
            transform Prepend::ToFieldValue,
              field: :lendernote,
              value: "Lender note: "
            transform CombineValues::FromFieldsWithDelimiter,
              sources: %i[loaninnote lendernote],
              target: :loaninnote,
              delete_sources: true,
              delim: Omca.notedelim
          when "loansout_common"
            transform Merge::MultiRowLookup,
              lookup: loanoutfeesgroup,
              keycolumn: :recordcsid,
              fieldmap: {feenote: :note},
              delim: "\n"
            transform CombineValues::FromFieldsWithDelimiter,
              sources: %i[loanoutnote feenote],
              target: :loanoutnote,
              delete_sources: true,
              delim: Omca.notedelim
            transform Omca::Xforms::Remap::MergeVenueInfo,
              lookup: loanoutvenuesgroup
          when "media_common"
            transform Merge::MultiRowLookup,
              lookup: media_omca,
              keycolumn: :recordcsid,
              fieldmap: {filename: :originalfilename}
            transform CombineValues::FromFieldsWithDelimiter,
              sources: %i[title filename],
              target: :title,
              delete_sources: true,
              delim: " - "
          when "media_common_publishtolist"
            transform Omca::Xforms::Remap::SvFieldToRepeatableFieldTable,
              fieldmap: {approveforpublic: :item}
          when "nagpradetermgroup"
            transform Rename::Fields, fieldmap: {
              assocculturalcontexttype: :nagpradetermtype,
              assocculturalcontext: :nagpradetermculture,
              assocculturalcontextnote: :nagpradetermnote
            }
          when "objectcomponentgroup"
            transform Omca::Xforms::Remap::CollectionobjectsOmcaAccessory,
              lookup: collectionobjects_omca
          when "objectcountgroup"
            transform Omca::Xforms::Remap::BuildObjectcountgroup
          when "organizations_common"
            transform Merge::MultiRowLookup,
              lookup: addressnotes,
              keycolumn: :recordcsid,
              fieldmap: {addressnotes: :note},
              sorter: Lookup::RowSorter.new(
                on: :pos, as: :to_i, blanks: :last
              ),
              delim: Omca.notedelim
            transform CombineValues::FromFieldsWithDelimiter,
              sources: %i[namenote addressnotes],
              target: :namenote,
              delete_sources: true,
              delim: Omca.notedelim
          when "partiesinvolvedgroup"
            transform Omca::Xforms::Remap::BuildPartiesinvolvedgroup
          when "persons_common"
            transform Merge::MultiRowLookup,
              lookup: addressnotes,
              keycolumn: :recordcsid,
              fieldmap: {addressnotes: :note},
              sorter: Lookup::RowSorter.new(
                on: :pos, as: :to_i, blanks: :last
              ),
              delim: Omca.notedelim
            transform CombineValues::FromFieldsWithDelimiter,
              sources: %i[namenote addressnotes],
              target: :namenote,
              delete_sources: true,
              delim: Omca.notedelim
          when "restrictedmedia_common"
            transform Merge::MultiRowLookup,
              lookup: restrictedmedia_omca,
              keycolumn: :recordcsid,
              fieldmap: {filename: :originalfilename}
            transform CombineValues::FromFieldsWithDelimiter,
              sources: %i[title filename],
              target: :title,
              delete_sources: true,
              delim: " - "
          when "restrictedmedia_common_publishtolist"
            transform Omca::Xforms::Remap::SvFieldToRepeatableFieldTable,
              fieldmap: {approveforpublic: :item}
          when "rightsgroup"
            transform Omca::Xforms::Remap::SvFieldToRepeatableFieldTable,
              fieldmap: {ipaudit: :standardizedrightstatement}
            transform Merge::ConstantValue,
              target: :rectype,
              value: "collectionobject"
          when "rightsholdergroup"
            transform Delete::FieldsExcept,
              fields: %i[recordcsid id copyrightholder]
            transform FilterRows::FieldPopulated,
              action: :keep,
              field: :copyrightholder
            transform Rename::Field,
              from: :copyrightholder,
              to: :rightholder
            transform Copy::Field,
              from: :id,
              to: :groupid
            transform Merge::ConstantValues,
              constantmap: {
                rectype: "collectionobject",
                pos: "0",
                grouptable: "rightsgroup"
              }
          when "taxonomicidentgroup"
            transform Omca::Xforms::Remap::BuildTaxonomicidentgroup
          when "textualinscriptiongroup"
            transform Omca::Xforms::Remap::BuildTextualinscriptiongroup
          when "usagegroup"
            transform Rename::Field, from: :item, to: :usagenote
            transform Merge::ConstantValues,
              constantmap: {
                rectype: "collectionobject",
                usage: "Exhibition history"
              }
          end
        end
      end
    end
  end
end
