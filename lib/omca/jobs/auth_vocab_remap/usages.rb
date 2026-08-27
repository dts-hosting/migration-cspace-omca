# frozen_string_literal: true

module Omca
  module Jobs
    module AuthVocabRemap
      module Usages
        module_function

        def desc = "Change terms used in assocculturalcontext from "\
          "concept/associated to concept/ethculture"

        def job
          Kiba::Extend::Jobs::Job.new(
            files: {
              source: :big_auth__collapsing_usage_merge,
              destination: :auth_vocab_remap__usages
            },
            transformer: xforms
          )
        end

        def xforms
          Kiba.job_segment do
            transform do |row|
              table = row[:table]
              field = row[:field]

              if table == "assocculturalcontextgroup" &&
                  field == "assocculturalcontext"
                target = "ethculture"
                row[:vocab] = target
                id = "#{row[:termid]}ethculture"
                row[:termid] = id

                row[:index] = [row[:authority], target, id].join(" ")

                refname = row[:refname]
                vocabreplace = refname.sub("(concept)", "(#{target})")
                row[:refname] = vocabreplace.sub(
                  /item:name\([^)]*\)/, "item:name(#{id})"
                )
              end

              row
            end
          end
        end
      end
    end
  end
end
