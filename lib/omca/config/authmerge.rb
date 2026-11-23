# frozen_string_literal: true

module Omca
  module Authmerge
    module_function

    def usages_key = :authorities__usages_new_refname

    def usages_path
      entry = Omca.registry.resolve(usages_key)
      if entry.respond_to?(:path)
        entry.path
      else
        entry[:path]
      end
    end

    def merge_prep_ready? = Omca.ready_for_authority_merge? &&
      Kiba::Extend::Job.output?(usages_key)

    def authority_controlled_target_field_config
      result = {}
      Omca::Mappings::Fields.authority_controlled_target_rows
        .each do |row|
          key = [row["target_db_table_type"], row["target_db_table"]]
          result[key] = [] unless result.key?(key)
          result[key] << row["target_db_field"]
        end
      result
    end

    def authority_controlled_target_fields
      result = []
      authority_controlled_target_field_config.each do |ti, fields|
        fields.each { |f| result << [ti[1], f] }
      end
      result.uniq
    end
  end
end
