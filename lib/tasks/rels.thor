# frozen_string_literal: true

# Tasks related to relations
class Rels < Thor
  desc "check_fixed_nhrs", "Report row count and whether any are missing "\
    "merged csids"
  def check_fixed_nhrs
    dir = File.join(Omca.datadir, "rels", "fix")
    files = Dir.children(dir)

    FileUtils.cd(dir) do |dir|
      path = File.join(Omca.datadir, "rels", "fix_nonhier_check.txt")
      File.open(path, "w") do |output|
        files.each do |file|
          fdisp = file.delete_suffix(".csv").delete_prefix("nonhier_")
          rows = `csvstat --count #{file}`.chomp.to_i
          subids = `csvstat --non-nulls -c item1_id #{file}`.chomp.to_i
          nullsub = rows - subids
          objids = `csvstat --non-nulls -c item2_id #{file}`.chomp.to_i
          nullobj = rows - objids
          line = [fdisp, rows, nullsub, nullobj].join("\t")
          puts line
          output << "#{line}\n"
        end
      end
      puts "Wrote output to #{path}"
    end
  end

  no_commands do
  end
end
