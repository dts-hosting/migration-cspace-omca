# frozen_string_literal: true

module Omca
  module Vocab
    module_function

    extend Dry::Configurable

    # tabletype (source) > table > field Hash of fields that are mapping
    #   to vocabulary-controlled target fields. Used to extract values
    #   for customizing the terms in target instance term lists/vocabularies
    def source_fields_to_vocab
      result = {}
      Omca::Mappings::Fields.vocab_controlled_target_rows.each do |row|
        tt = row["db_table_type"]
        table = row["source_db_table"]
        field = row["db_field"]
        vocab = row["target_field_source"].delete_prefix("vocabulary: ")

        table_info = [tt, table]
        result[table_info] = [] unless result.key?(table_info)

        result[table_info] << [vocab, field]
      end
      result
    end
  end
end
