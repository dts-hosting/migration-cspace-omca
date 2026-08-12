# frozen_string_literal: true

module Omca
  module Authmerge
    module_function

    def usages_key = :authorities__usages_new_refname

    def merge_ready? = Kiba::Extend::Job.output?(usages_key)

    def usages_path = Omca.registry
      .resolve(usages_key)[:path]

    def field_list = @field_list ||= get_field_list

    def by_table = @by_table ||= get_by_table

    def get_field_list
      cmd = %(xan map 'col(1) ++ "." ++ col(3) as tablefield' ) +
        %(#{usages_path} | ) +
        %(xan select tablefield | ) +
        %(xan dedup -s tablefield)
      `#{cmd}`.chomp.split("\n")[1..].map { |e| e.split(".") }
    end
    private_class_method :get_field_list

    def get_by_table = field_list.group_by { |arr| arr[0] }
      .transform_values { |v| v.map { |arr| arr[1] } }
    private_class_method :get_by_table
  end
end
