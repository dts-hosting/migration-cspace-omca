# frozen_string_literal: true

module Omca
  module Remap
    module_function

    extend Dry::Configurable

    setting :previous,
      reader: true,
      default: Omca::RegistryData.previous_phase("remap")

    # @return [Hash] data used by
    #   {Omca::RegistryData.register_new_table_remappings} to trigger creation
    #   of new database tables from existing database data
    setting :new_tables,
      reader: true,
      default: {
        "main" => {
          "consultations_common" => {
            source: [
              :"#{previous}_repeatable_field_group__viewercontributiongroup"
            ],
            rectype: "consultation"
          },
          "exits_common" => {
            source: [:"#{previous}_main__objectexit_common"],
            rectype: "exit"
          }
        },
        "repeatable_field" => {
          "collectionobjects_nagpra_nagpracategories" => {
            source: [
              # rubocop:disable Layout/LineLength
              :"#{previous}_repeatable_field__collectionobjects_anthropology_nagpraapplicabilitylist"
              # rubocop:enable Layout/LineLength
            ],
            rectype: "collectionobject"
          },
          "collectionobjects_nagpra_nagprainventorynames" => {
            source: [
              # rubocop:disable Layout/LineLength
              :"#{previous}_repeatable_field__collectionobjects_anthropology_nagprainventorynamelist"
              # rubocop:enable Layout/LineLength
            ],
            rectype: "collectionobject"
          },
          "consultations_common_consultationoutcomes" => {
            source: [
              :"#{previous}_repeatable_field_group__viewercontributiongroup"
            ],
            rectype: "consultation"
          },
          "consultations_common_notes" => {
            source: [
              :"#{previous}_repeatable_field_group__viewercontributiongroup"
            ],
            rectype: "consultation"
          },
          "exits_common_methods" => {
            source: [
              :"#{previous}_repeatable_field__objectexit_common_exitmethods"
            ],
            rectype: "exit"
          },
          "exits_common_owners" => {
            source: [:"#{previous}_main__objectexit_common"],
            rectype: "exit"
          }
        },
        "repeatable_field_group" => {
          "rightsgroup" => {
            source: [
              :"#{previous}_addtl_fields__collectionobjects_omca"
            ],
            rectype: "collectionobject"
          },
          "taxonomicidentgroup" => {
            source: [
              :"#{previous}_repeatable_field_group__determinationhistorygroup"
            ],
            rectype: "collectionobject"
          }
        },
        "extension_field_group" => {
          "accesslimitationsgroup" => {
            source: [
              :"#{previous}_repeatable_field_group__accessrestrictiongroup"
            ],
            rectype: "multi"
          },
          "partiesinvolvedgroup" => {
            source: [
              "acquisitioncontactgroup", "viewercontributiongroup"
            ].map { |table| :"#{previous}_repeatable_field_group__#{table}" },
            rectype: "multi"
          }
        }
      }
  end
end
