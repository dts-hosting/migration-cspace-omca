# frozen_string_literal: true

module Omca
  module AuthmergePrep
    module_function

    extend Dry::Configurable

    setting :target_auth_vocabs,
      reader: true,
      default: [],
      constructor: ->(default) do
        Omca::Mappings::Fields.authority_controlled_target_rows
          .map do |r|
            r["target_field_source"].delete_prefix("authority: ")
              .split("; ")
          end.flatten
          .uniq
          .map do |val|
            vals = val.split("/")
            [
              Omca::Mappers.authority_type_by_rectype(vals[0]),
              Omca::Mappers.auth_vocab_shortid(*vals)
            ]
          end
      end
  end
end
