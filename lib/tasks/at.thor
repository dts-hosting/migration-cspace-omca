# frozen_string_literal: true

# Tasks related to authority terms
class At < Thor
  desc "usages", Omca::Authorities::Usages.desc
  def usages
    Omca::Authorities::Usages.call
  end

  desc "unique_usages", "Write one row per used refname, with count of "\
    "usages. Note that different refnames for the same term record may have "\
    "been used, so this output may still have multiple rows per term"
  def unique_usages
    srcpath = Omca::Authorities.usages_path
    outpath = Omca::Authorities.uniq_usages_path
    counter = {}

    File.open(srcpath) do |file|
      CSV.foreach(file, headers: true) do |row|
        refname = row["refname"]
        counter[refname] = 0 unless counter.key?(refname)
        counter[refname] += 1
      end
    end

    CSV.open(
      outpath,
      "w",
      headers: Omca::Authorities.uniq_usages_headers,
      write_headers: true
    ) do |csv|
      counter.each do |refname, ct|
        base = {
          "usagect" => ct
        }
        termdata = Omca::Refname.add_parsed_detail(base, refname)
        csv << termdata.values_at(*csv.headers)
      end
    end
    puts "Wrote unique authority usages to #{outpath}"
  end
end
