# frozen_string_literal: true

require "omca"

module Helpers
  module_function

  def clear_output(jobkey)
    path = Omca.registry.resolve(jobkey).path
    return unless File.exist?(path)
    FileUtils.rm(path)
  end

  # @param csid [String] CSID value to search for
  # @param field [String] column from which to return value(s)
  # @param path [String] to CSV in which to search
  def xan_search_csid_return_field(csid, field, path)
    cmd = "xan search -s recordcsid -e #{csid} #{path} | "\
      "xan select #{field} | xan behead"
    `#{cmd}`.chomp
  end

  # @param id [String] ID value to search for
  # @param field [String] column from which to return value(s)
  # @param path [String] to CSV in which to search
  def xan_search_id_return_field(id, field, path)
    cmd = "xan search -s id -e #{id} #{path} | "\
      "xan select #{field} | xan behead"
    `#{cmd}`.chomp
  end
end
