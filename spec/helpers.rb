# frozen_string_literal: true

require "omca"

module Helpers
  module_function

  def clear_output(jobkey)
    path = Omca.registry.resolve(jobkey).path
    return unless File.exist?(path)
    FileUtils.rm(path)
  end

  def xan_seach_csid_return_field(csid, field, path)
    cmd = "xan search -s recordcsid -e #{csid} #{path} | "\
      "xan select #{field} | xan behead"
    `#{cmd}`.chomp
  end
end
