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
        "addtl_fields" => {
          "collectionobjects_anthro" => {
            source: [:"#{previous}_addtl_fields__collectionobjects_omca"],
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
          "addressgroup" => {
            source: [
              :"#{previous}_repeatable_field_group__addressgroupomca"
            ],
            rectype: "multi"
          },
          "partiesinvolvedgroup" => {
            source: [
              "acquisitioncontactgroup", "viewercontributiongroup"
            ].map { |table| :"#{previous}_repeatable_field_group__#{table}" },
            rectype: "multi"
          }
        },
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
          "collectionobjects_common_controlledcontentplaces" => {
            source: [
              # rubocop:disable Layout/LineLength
              :"#{previous}_repeatable_field_group__assocplacegroup",
              :"#{previous}_repeatable_field__collectionobjects_common_contentplaces"
              # rubocop:enable Layout/LineLength
            ],
            rectype: "collectionobject"
          },
          "collectionobjects_common_fieldcollectionplaces" => {
            source: [
              :"#{previous}_main__collectionobjects_common"
            ],
            rectype: "collectionobject"
          },
          "collectionobjects_common_namedcollections" => {
            source: [
              :"#{previous}_main__collectionobjects_common"
            ],
            rectype: "collectionobject"
          },
          "collectionobjects_common_publishtolist" => {
            source: [
              :"#{previous}_addtl_fields__collectionobjects_omca"
            ],
            rectype: "collectionobject"
          },
          "collectionobjects_nagpra_nagpracategories" => {
            source: [
              # rubocop:disable Layout/LineLength
              :"#{previous}_repeatable_field__collectionobjects_anthropology_nagpraapplicabilitylist"
              # rubocop:enable Layout/LineLength
            ],
            rectype: "collectionobject"
          },
          "collectionobjects_nagpra_nagpraculturaldeterminations" => {
            source: [
              # rubocop:disable Layout/LineLength
              :"#{previous}_repeatable_field__collectionobjects_anthropology_nagpraculturaldeterminationlist"
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
          "collectionobjects_nagpra_repatriationnotes" => {
            source: [
              # rubocop:disable Layout/LineLength
              :"#{previous}_repeatable_field__collectionobjects_anthropology_repatriationnotelist"
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
          },
          "media_common_publishtolist" => {
            source: [:"#{previous}_addtl_fields__media_omca"],
            rectype: "media"
          },
          "restrictedmedia_common_publishtolist" => {
            source: [:"#{previous}_addtl_fields__restrictedmedia_omca"],
            rectype: "restrictedmedia"
          }
        },
        "repeatable_field_group" => {
          "annotationgroup" => {
            source: [
              :"#{previous}_addtl_fields__collectionobjects_omca",
              :"#{previous}_repeatable_field__collectionobjects_omca_photos"
            ],
            rectype: "collectionobject"
          },
          "anthroownershipgroup" => {
            source: [
              :"#{previous}_repeatable_field_group__previousownersgroup"
            ],
            rectype: "collectionobject"
          },
          "approvalstatusgroup" => {
            source: [
              :"#{previous}_repeatable_field_group__exitstatusgroup"
            ],
            rectype: "exit"
          },
          "conditioncheckgroup" => {
            source: [
              :"#{previous}_addtl_fields__conditionchecks_omca"
            ],
            rectype: "conditioncheck"
          },
          "depositorgroup" => {
            source: [
              :"#{previous}_repeatable_field_group__depositoromcagroup"
            ],
            rectype: "intake"
          },
          "nagpradetermgroup" => {
            source: [
              :"#{previous}_repeatable_field_group__assocculturalcontextgroup"
            ],
            rectype: "collectionobject"
          },
          "objectcountgroup" => {
            source: [
              :"#{previous}_main__collectionobjects_common",
              :"#{previous}_addtl_fields__collectionobjects_omca"
            ],
            rectype: "collectionobject"
          },
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
          },
          "textualinscriptiongroup" => {
            source: [
              :"#{previous}_addtl_fields__collectionobjects_omca"
            ],
            rectype: "collectionobject"
          },
          "usagegroup" => {
            source: [
              # rubocop:disable Layout/LineLength
              :"#{previous}_repeatable_field__collectionobjects_omca_exhibitionhistories"
              # rubocop:enable Layout/LineLength
            ],
            rectype: "collectionobject"
          }
        },
        "subgroup" => {
          "rightholdergroup" => {
            source: [
              :"#{previous}_addtl_fields__collectionobjects_omca"
            ],
            rectype: "collectionobject"
          }
        }
      }
  end
end
