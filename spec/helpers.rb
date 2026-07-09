# frozen_string_literal: true

require "omca"

module Helpers
  module_function

  def clear_output(jobkey)
    path = Omca.registry.resolve(jobkey).path
    return unless File.exist?(path)
    FileUtils.rm(path)
  end
end
