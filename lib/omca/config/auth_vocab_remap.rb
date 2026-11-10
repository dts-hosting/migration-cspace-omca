# frozen_string_literal: true

module Omca
  module AuthVocabRemap
    module_function

    extend Dry::Configurable

    setting :fields_to_divert,
      reader: true,
      default: [
        {table: "objectexit_common", field: "depositor"},
        {table: "accessrestrictiongroup",
         field: "accessrestrictionrequestor"},
        {table: "collectionobjects_omca", field: "copyrightholder"},
        {table: "determinationhistorygroup", field: "dhname"},
        {table: "determinationhistorygroup", field: "identby"},
        {table: "determinationhistorygroup", field: "institution"},
        {table: "materialgroup", field: "material"},
        {table: "assocculturalcontextgroup", field: "assocculturalcontext"}
      ]
  end
end
