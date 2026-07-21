# frozen_string_literal: true

module Omca
  module OptList
    module_function

    extend Dry::Configurable

    # tabletype (source) > table > field Hash of fields that are mapping
    #   to option list-controlled target fields. Used to extract values
    #   for customizing the option lists in hosted UI config
    def source_fields_to_opt_list
    end
  end
end
