# frozen_string_literal: true

module Omca
  module AuthVocabRemap
    module_function

    extend Dry::Configurable

    setting :fields_to_divert,
      reader: true,
      default: [
        {table: "accessrestrictiongroup",
         field: "accessrestrictionrequestor"},
        {table: "acquisitioncontactgroup", field: "contact"},
        {table: "assocculturalcontextgroup", field: "assocculturalcontext"},
        {table: "assocplacegroup", field: "assocplace"},
        {table: "collectionobjects_common", field: "fieldcollectionplace"},
        {table: "collectionobjects_common_contentplaces", field: "item"},
        {table: "collectionobjects_omca", field: "copyrightholder"},
        {table: "depositoromcagroup", field: "depositoromca"},
        {table: "determinationhistorygroup", field: "dhname"},
        {table: "determinationhistorygroup", field: "identby"},
        {table: "determinationhistorygroup", field: "institution"},
        {table: "intakes_common", field: "currentowner"},
        {table: "materialgroup", field: "material"},
        {table: "objectexit_common", field: "depositor"},
        {table: "objectnamegroup", field: "objectname"},
        {table: "previousownersgroup", field: "previousowner"},
        {table: "viewercontributiongroup", field: "viewername"}
      ]

    def remapped_diverted
      fields_to_divert.map do |h|
        :"auth_vocab_remap__remap_#{h[:table]}_#{h[:field]}_usages"
      end
    end
  end
end
