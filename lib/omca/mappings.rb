# frozen_string_literal: true

require "roo"

module Omca
  module Mappings
    module_function

    def worksheet = @worksheet ||= Roo::Excelx.new(Omca.mappings_path)
  end
end
