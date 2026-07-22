# frozen_string_literal: true

class Del < Thor
  desc "derived SUBPATH", "Delete derived table in all folders"
  def derived(subpath)
    FileUtils.cd(Omca.datadir) do
      Dir.each_child(Omca.datadir) do |child|
        next unless Dir.exist?(child)
        next if ["orig", "nuke_bom"].include?(child)

        path = File.join(child, subpath)
        next unless File.exist?(path)

        FileUtils.rm(path)
        puts "Deleted #{path}"
      end
    end
  end
end
