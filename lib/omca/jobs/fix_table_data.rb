# frozen_string_literal: true

module Omca
  module Jobs
    module FixTableData
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
        prev = Omca::RegistryData.previous_phase("fix")
        case table
        when "loanoutvenuesgroup"
          base << {
            jobkey: :"#{prev}_addtl_fields__loansout_omca",
            lookup_on: :recordcsid,
            name: :loansout_omca
          }
        end

        base
      end

      def xforms(table, tabletype, rectype)
        Kiba.job_segment do
          # Dynamically uncontrol specified fields
          if Omca::Mappings::Fields.uncontrol_rectypes.include?(rectype)
            uncontrol_rows =
              Omca::Mappings::Fields.uncontrol_rows_for_rectype(rectype)
            tables = uncontrol_rows.map { |r| r["source_db_table"] }
            if tables.include?(table)
              uncontrol_rows.map { |r| r["db_field"].to_sym }
                .each do |field|
                  transform do |row|
                    val = row[field]
                    next row if val.blank?
                    next row unless val.start_with?("urn:")

                    row[field] = Omca::Refname.deurn(val)
                    row
                  end
                end
            end
          end

          # Dynamically downcase field values mapping into option
          #   list-controlled fields
          if Omca::OptList.downcase_field_config.key?(table)
            transform Clean::DowncaseFieldValues,
              fields: Omca::OptList.downcase_field_config[table]
          end

          # applies to both media_omca and restrictedmedia_omca tables
          if table.match?(/media_omca/)
            transform Replace::FieldValueWithStaticMapping,
              source: :approveforpublic,
              mapping: {
                "t" => "OMCA Browser",
                "f" => "none"
              }
          end

          # Table-specific fixes, ordered by table name
          case table
          when "acquisitioncontactgroup"
            transform Clean::DowncaseFieldValues,
              fields: :contactrole
          when "acquisitions_omca"
            transform Replace::FieldValueWithStaticMapping,
              source: :anonymous,
              mapping: {
                "t" => "urn:cspace:omca.staging.collectionspace.org:"\
                  "personauthorities:name(person):item:"\
                  "name(Anonymous430877234)'Anonymous'",
                "f" => nil
              }
          when "addressgroupomca"
            transform do |row|
              row[:countrynote] = nil
              notable = ["a. e. f."]
              val = row[:addresscountryomca]
              next row if val.blank?
              next row unless notable.include?(val)

              row[:countrynote] = "Pre-migration country value was: #{val}"

              row
            end

            transform CombineValues::FromFieldsWithDelimiter,
              sources: %i[addressnoteomca countrynote],
              target: :addressnoteomca,
              delete_sources: true,
              delim: Omca.notedelim

            transform Replace::FieldValueWithStaticMapping,
              source: :addresscountryomca,
              fallback_val: nil,
              mapping: {
                "VENEZUELA, BOLIVARIAN REPUBLIC OF" => "VE",
                "a. e. f." => "",
                "ARGENTINA" => "AR",
                "BAHAMAS" => "BS",
                "BRAZIL" => "BR",
                "CANADA" => "CA",
                "CHINA" => "CN",
                "DENMARK" => "DK",
                "ECUADOR" => "EC",
                "EL SALVADOR" => "SV",
                "FRANCE" => "FR",
                "GERMANY" => "DE",
                "GUAM" => "GU",
                "HONDURAS" => "HN",
                "ICELAND" => "IS",
                "IRELAND" => "IE",
                "ISLE OF MAN" => "IM",
                "ITALY" => "IT",
                "JAPAN" => "JP",
                "MEXICO" => "MX",
                "NEW CALEDONIA" => "NC",
                "NEW ZEALAND" => "NZ",
                "PHILIPPINES" => "PH",
                "SPAIN" => "ES",
                "SWEDEN" => "SE",
                "UNITED KINGDOM" => "GB",
                "UNITED STATES" => "US"
              }
          when "assocculturalcontextgroup"
            transform Clean::DowncaseFieldValues,
              fields: :assocculturalcontexttype
          when "citationagentinfogroup"
            transform Clean::DowncaseFieldValues, fields: :role
          when "citations_common"
            transform do |row|
              if row[:id] == "8d1e478c-81d8-4ec2-bb28-2204a3938109"
                val = row[Omca.ingestid_field]
                row[:citationnote] = val
                row[Omca.ingestid_field] =
                  "Varjola, Pirjo. The Etholen Collection"
              end

              row
            end

            transform Clean::EnsureConsistentFields
          when "citations_omca"
            transform Clean::DowncaseFieldValues, fields: :publicationtype
          when "citationtermgroup"
            transform Clean::DowncaseFieldValues, fields: :termtype
          when "collectionobjects_anthropology_nagpraapplicabilitylist"
            transform Replace::FieldValueWithStaticMapping,
              source: :item,
              mapping: {
                "afo" => "associated funerary object (AFO)",
                "nonNagpra" => "not subject to NAGPRA",
                "objectOfCulturalPatrimony" => "object of cultural patrimony",
                "ufo" => "unassociated funerary object (UFO)",
                "unaffiliatedCuiHsr" => "unaffiliated human skeletal "\
                  "remains (HSR) (=CUI)"
              }
          when "collectionobjects_anthropology_nagprainventorynamelist"
            transform Clean::RegexpFindReplaceFieldVals,
              fields: :item,
              find: /^notOnAnInventory$/,
              replace: "not on an inventory"
          when "collectionobjects_common"
            transform Prepend::ToFieldValue,
              field: :distinguishingfeatures,
              value: "Distinguishing features: "
          when "collectionobjects_common_responsibledepartments"
            transform Delete::FieldValueConditional,
              fields: :item,
              lambda: ->(val, row) do
                ["CIA", "Education Department",
                  "Professional Services Department"].any? do |str|
                  val == str
                end
              end
            transform FilterRows::FieldPopulated,
              action: :keep,
              field: :item
            transform Clean::RegexpFindReplaceFieldVals,
              fields: :item,
              find: / Department/,
              replace: ""
          when "collectionobjects_omca"
            fields = %i[art history science]
            transform Delete::FieldValueMatchingRegexp,
              fields: fields,
              match: /^f$/
            fields.each do |field|
              transform Clean::RegexpFindReplaceFieldVals,
                fields: field,
                find: /^t$/,
                replace: field.to_s.capitalize
            end

            transform Replace::FieldValueWithStaticMapping,
              source: :donotpublishonweb,
              fallback_val: :nil,
              mapping: {
                "t" => "none",
                "f" => "OMCA Browser"
              }

            transform Replace::FieldValueWithStaticMapping,
              source: :ipaudit,
              fallback_val: :orig,
              mapping: {
                "Assumed Protected by Copyright" =>
                  "assumed protected by copyright",
                "Copyright Not Evaluated" => "copyright not evaluated",
                "Copyright OMCA" => "copyright OMCA",
                "Copyright Undetermined" => "copyright undetermined",
                "In Copyright" => "in copyright",
                "No Copyright - United States (Public Domain)" =>
                  "no copyright - United States (public domain)",
                "No Known Copyright" => "no known copyright"
              }
          when "conditionchecks_common"
            transform Clean::RegexpFindReplaceFieldVals,
              fields: :conditioncheckreason,
              find: /appraisal'<\/refname>/,
              replace: "appraisal"
          when "conditionchecks_omca"
            transform Prepend::ToFieldValue,
              field: :humidityrequirement,
              value: "Humidity requirement: "
            transform Prepend::ToFieldValue,
              field: :lightrequirement,
              value: "Light requirement: "
            transform Prepend::ToFieldValue,
              field: :temprequirement,
              value: "Temperature requirement: "
            transform CombineValues::FromFieldsWithDelimiter,
              sources: %i[humidityrequirement lightrequirement temprequirement],
              target: :envrecommendations,
              delete_sources: true,
              delim: "\n"
          when "conditionchecks_omca_omcaconditioncheckmethods"
            transform Clean::RegexpFindReplaceFieldVals,
              fields: :item,
              find: /handheld led illumination/,
              replace: "handheld LED illumination"
          when "conservation_common"
            transform Replace::FieldValueWithStaticMapping,
              source: :treatmentpurpose,
              fallback_val: :orig,
              mapping: {
                "Acquisition" => "acquisition",
                "Appraisal" => "appraisal",
                "Damage" => "damage",
                "Exhibition" => "exhibition",
                "Insurance" => "insurance",
                "Loan Out" => "loan out",
                "Loan Return" => "loan return",
                "Other" => "other",
                "Pest - Anoxia" => "pest - anoxia",
                "Pest - Low temp" => "pest - low temp"
              }
          when "conservationstatusgroup"
            transform Clean::DowncaseFieldValues, fields: :status
          when "contactgroup"
            transform Clean::DowncaseFieldValues, fields: :contactrole
          when "determinationhistorygroup"
            transform Clean::DowncaseFieldValues,
              fields: :dhqualifier
          when "dimensionsubgroup"
            transform Clean::RegexpFindReplaceFieldVals,
              fields: :dimension,
              find: /^running-time$/,
              replace: "running time"
          when "exhibitions_common"
            transform Clean::DowncaseFieldValues, fields: :type
          when "exhibitionstatusgroup"
            transform Clean::DowncaseFieldValues, fields: :exhibitionstatus
          when "exitstatusgroup"
            transform Clean::DowncaseFieldValues, fields: :exitstatus
          when "groups_common"
            transform do |row|
              val = row[Omca.ingestid_field]
              fulltitle = "Guy Rose, American Impressionist: OMCA "\
                "7/1-9/24/95, Irvine Museum 10/20/95-2/24/96, Norton Museum "\
                "of Art, West Palm Beach, FL 9/14-11/10/96, Greenville "\
                "County Museum of Art, Greenville, SC 12/4/96-1/19/97, The "\
                "Montclair Art Museum 4/27/97-7/27/97"
              next row unless val == fulltitle

              row[:scopenote] = [
                row[:scopenote],
                "Pre-migration title: #{fulltitle}"
              ].reject(&:blank?)
                .join("\n\n")

              row[Omca.ingestid_field] = "Guy Rose, American Impressionist "\
                "(venue/date list)"

              row
            end
          when "intakes_common_entrymethods"
            transform Clean::DowncaseFieldValues, fields: :item
          when "loanoutfeesgroup"
            transform FilterRows::WithLambda,
              action: :reject,
              lambda: ->(row) do
                val = row[:loanoutfeesamount]
                val.blank? || val == "0"
              end
            transform Delete::FieldValueMatchingRegexp,
              fields: :loanoutfeescurrency,
              match: "US Dollar"
            transform Prepend::ToFieldValue,
              field: :loanoutfeesdatepaid,
              value: "paid on "
            transform Prepend::ToFieldValue,
              field: :loanoutfeesamount,
              value: "$"
            transform CombineValues::FromFieldsWithDelimiter,
              sources: %i[loanoutfeesamount loanoutfeesdatepaid],
              target: :note,
              delete_sources: true,
              delim: " "
            transform Prepend::ToFieldValue,
              field: :note,
              value: "Loan fee: "
            transform Delete::EmptyFields
          when "loanoutvenuesgroup"
            transform Merge::MultiRowLookup,
              lookup: loansout_omca,
              keycolumn: :recordcsid,
              fieldmap: {exhibitiontitle: :loanoutexhibitiontitle}
          when "loansin_omca"
            transform Delete::Fields, fields: :loanininsurancenote
          when "loansin_omca_loanininsuranceinsurers"
            transform Omca::Xforms::DropAllRows
          when "loansout_omca_loanoutinsuranceinsurers"
            transform Omca::Xforms::DropAllRows
          when "locations_common"
            transform Clean::DowncaseFieldValues, fields: :locationtype
          when "movements_common"
            transform FilterRows::FieldPopulated,
              action: :keep,
              field: :currentlocation
            transform do |row|
              val = row[:locationdate]
              next row if val.blank?
              next row if val.match?(/^\d{4}-\d{2}-\d{2}$/)

              row[:locationdate] = val.sub(/^(\d{4}-\d{2}-\d{2}).*/, '\1')

              row
            end
          when "objectexit_common_exitmethods"
            transform Clean::DowncaseFieldValues,
              fields: :item
          when "otherpartygroup"
            transform Clean::DowncaseFieldValues, fields: :otherpartyrole
          end
        end
      end
    end
  end
end
