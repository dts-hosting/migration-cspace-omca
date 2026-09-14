# frozen_string_literal: true

require "omca"

module Helpers
  module_function

  def clear_output(jobkey)
    path = Omca.registry.resolve(jobkey).path
    return unless File.exist?(path)
    FileUtils.rm(path)
  end

  # @param searchfield [String] field in which to search for searchvalue
  # @param searchvalue [String] value to search for in searchfield
  # @param returnfield [String] column/field from which to return value(s)
  # @param path [String] to CSV in which to search
  def xan_search_and_return_field_vals(
    searchfield, searchvalue, returnfield, path
  )
    cmd = "xan search -s #{searchfield} -e #{searchvalue} #{path} | "\
      "xan select #{returnfield} | xan behead"
    `#{cmd}`.chomp.split("\n").reject { |v| v.blank? || v == '""' }
  end

  # @param csid [String] CSID value to search for
  # @param field [String] column from which to return value(s)
  # @param path [String] to CSV in which to search
  def xan_search_csid_return_field(csid, field, path)
    xan_search_and_return_field_vals("recordcsid", csid, field, path)
  end

  # @param id [String] ID value to search for
  # @param field [String] column from which to return value(s)
  # @param path [String] to CSV in which to search
  def xan_search_id_return_field(id, field, path)
    xan_search_and_return_field_vals("id", id, field, path)
  end

  # @param filter [String] moonblade filter to run on path
  # @param path [String] to CSV in which to search
  # @param include_headers [Boolean]
  def xan_filter(filter, path, include_headers: false)
    basecmd = "xan filter #{filter} #{path}"
    cmd = include_headers ? basecmd : "#{basecmd} | xan behead"
    `#{cmd}`.chomp.split("\n").reject { |v| v.blank? || v == '""' }
  end
end
