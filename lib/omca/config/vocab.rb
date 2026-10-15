# frozen_string_literal: true

module Omca
  module Vocab
    module_function

    extend Dry::Configurable

    setting :norm_xforms,
      reader: true,
      default: nil,
      constructor: ->(default) do
        Kiba.job_segment do
          transform Cspace::NormalizeForID,
            source: :term,
            target: :normterm
          transform CombineValues::FromFieldsWithDelimiter,
            sources: %i[vocab normterm],
            target: :matchpoint,
            delete_sources: false,
            delim: "%^&"
          transform Delete::FieldsExcept,
            fields: %i[term matchpoint vocab description termstatus
              source sourcepage]
        end
      end

    # tabletype > table > field Hash of fields that are mapping
    #   to vocabulary-controlled target fields. Used to extract values
    #   for customizing the terms in target instance term lists/vocabularies
    # @param type [:source, :target] Whether we are returning info on
    #   source or target field/table
    def vocab_fields(type)
      ttypecol = (type == :source) ? "db_table_type" : "target_db_table_type"
      tablecol = "#{type}_db_table"
      fieldcol = (type == :source) ? "db_field" : "target_db_field"

      result = {}
      Omca::Mappings::Fields.vocab_controlled_target_rows
        .reject do |row|
          row["mapping_treatment"]&.match?(/supply value|special merge/)
        end.each do |row|
          tt = row[ttypecol]
          table = row[tablecol]
          field = row[fieldcol]
          vocab = row["target_field_source"].delete_prefix("vocabulary: ")

          table_info = [tt, table]
          result[table_info] = [] unless result.key?(table_info)

          result[table_info] << [vocab, field]
        end
      result
    end

    def terms_added_in_remapping
      Omca::Mappings::Fields.vocab_controlled_target_rows
        .select do |row|
          row["mapping_treatment"]&.match?(/supply value|special merge/)
        end
    end
  end
end
