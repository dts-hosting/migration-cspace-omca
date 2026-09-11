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
      File.exist?(usages_path)

    def field_list = @field_list ||= get_field_list

    def by_table = @by_table ||= get_by_table

    def get_field_list
      return [] unless merge_prep_ready?

      cmd = %(xan map 'col(1) ++ "." ++ col(3) as tablefield' ) +
        %(#{usages_path} | ) +
        %(xan select tablefield | ) +
        %(xan dedup -s tablefield)
      `#{cmd}`.chomp.split("\n")[1..].map { |e| e.split(".") }
    end
    private_class_method :get_field_list

    def get_by_table
      return {} unless merge_prep_ready?

      field_list.group_by { |arr| arr[0] }
        .transform_values { |v| v.map { |arr| arr[1] } }
    end
    private_class_method :get_by_table
  end
end
