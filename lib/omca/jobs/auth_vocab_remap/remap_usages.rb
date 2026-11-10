# frozen_string_literal: true

module Omca
  module Jobs
    module AuthVocabRemap
      module RemapUsages
        module_function

        def self.desc(args) = "Remaps diverted usages for #{args[:table]}."\
          "#{args[:field]}. These will be merged back in by "\
          ":authorities__usages_final_source"

        def job(args)
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :"auth_vocab_remap__#{args[:source]}",
              destination: :"auth_vocab_remap__#{args[:name]}"
            },
            transformer: xforms(table: args[:table], field: args[:field])
          )
        end

        def xforms(table:, field:)
          Kiba.job_segment do
            if table == "objectexit_common" && field == "depositor"
              transform do |row|
                row[:tabletype] = "repeatable_field"
                row[:table] = "exits_common_owners"
                row[:field] = "item"
                row[:pos] = "0"
                row
              end
            elsif table == "accessrestrictiongroup" &&
                field == "accessrestrictionrequestor"
              transform do |row|
                row[:tabletype] = "extension_field_group"
                row[:table] = "accesslimitationsgroup"
                row[:field] = "requester"
                row
              end
            elsif table == "collectionobjects_omca" &&
                field == "copyrightholder"
              transform do |row|
                row[:tabletype] = "subgroup"
                row[:table] = "rightholdergroup"
                row[:field] = "rightholder"
                row[:pos] = "0"
                row
              end
            elsif table == "materialgroup" &&
                field == "material"
              transform do |row|
                row[:field] = "materialcontrolled"
                row
              end
            elsif table == "objectnamegroup" &&
                field == "objectname"
              transform do |row|
                row[:field] = "objectnamecontrolled"
                row
              end
            elsif table == "assocculturalcontextgroup" &&
                field == "assocculturalcontext"
              transform do |row|
                target = "ethculture"
                row[:vocab] = target
                id = "#{row[:termid]}#{target}"
                row[:termid] = id

                refname = row[:refname]
                vocabreplace = refname.sub("(concept)", "(#{target})")
                row[:refname] = vocabreplace.sub(
                  /item:name\([^)]*\)/, "item:name(#{id})"
                )
                row[:table] = "nagpradetermgroup"
                row[:field] = "nagpradetermculture"

                row
              end
            elsif table == "determinationhistorygroup"
              case field
              when "dhname"
                transform do |row|
                  row[:table] = "taxonomicidentgroup"
                  row[:field] = "taxon"
                  row
                end
              when "identby"
                transform do |row|
                  row[:table] = "taxonomicidentgroup"
                  row
                end
              when "institution"
                transform do |row|
                  row[:table] = "taxonomicidentgroup"
                  row
                end
              end
            end
          end
        end
      end
    end
  end
end
