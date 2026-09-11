# frozen_string_literal: true

module Omca
  module Remap
    module_function

    extend Dry::Configurable

    setting :previous,
      reader: true,
      default: Omca::RegistryData.previous_phase("remap")

    setting :new_tables,
      reader: true,
      default: {
        "main" => {
          "consultations_common" => {
            source: [
              :"#{previous}_repeatable_field_group__viewercontributiongroup"
            ],
            rectype: "consultation"
          }
        },
        "repeatable_field_group" => {
          "partiesinvolvedgroup" => {
            source: ["acquisitioncontactgroup", "viewercontributiongroup"],
            rectype: "multi"
          }
        }
      }
  end
end
