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
            destination: dest
          },
          transformer: xforms(table, tabletype, rectype)
        )
      end

      def xforms(table, tabletype, rectype)
        Kiba.job_segment do
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

          if table == "citations_common"
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
          end

          if table == "collectionobjects_common_responsibledepartments"
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
          end

          if table == "collectionobjects_omca"
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
          end

          if table == "conditionchecks_common"
            transform Clean::RegexpFindReplaceFieldVals,
              fields: :conditioncheckreason,
              find: /Appraisal'<\/refName>/,
              replace: "Appraisal"
          end

          downcase_opt_list_fields = [
            "acquisitions_common.acquisitionmethod",
            "addressgroupomca.addresstypeomca",
            "collectionobjects_common.recordstatus",
            "concepttermgroup.historicalstatus",
            "concepttermgroup.termtype",
            "conditionchecks_common.conditioncheckreason",
            "conditionchecks_omca_omcaconditioncheckmethods.item",
            "hazardgroup.hazard",
            "intakes_common.entryreason",
            "loctermgroup.termstatus",
            "loctermgroup.termtype",
            "media_common_typelist.item",
            "movements_common.currentlocationfitness",
            "movements_common.reasonformove",
            "orgtermgroup.termtype",
            "persontermgroup.termtype",
            "places_common.placetype",
            "placetermgroup.historicalstatus",
            "placetermgroup.termtype",
            "restrictedmedia_common_typelist.item",
            "taxon_common.taxonrank",
            "taxontermgroup.termtype",
            "titlegroup.titletype",
            "valuationcontrols_common.valuetype"
          ].map do |val|
            parts = val.split(".")
            [parts[0], parts[1].to_sym]
          end.group_by { |e| e[0] }
            .transform_values do |v|
              v.flatten.select { |val| val.is_a?(Symbol) }
            end

          if downcase_opt_list_fields.key?(table)
            transform Clean::DowncaseFieldValues,
              fields: downcase_opt_list_fields[table]
          end

          if table == "conditionchecks_omca_omcaconditioncheckmethods"
            transform Clean::RegexpFindReplaceFieldVals,
              fields: :item,
              find: /handheld led illumination/,
              replace: "handheld LED illumination"
          end

          if tabletype == "main" && rectype == "group"
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

          end
        end
      end
    end
  end
end
