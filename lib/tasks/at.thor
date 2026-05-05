# frozen_string_literal: true

# Tasks related to authority terms
class At < Thor
  desc "usages", "Write all authority usages, with table, row id, and field"
  def usages
    path = File.join(Omca.datadir, "authority_ref", "authority_usages.csv")
    csv = CSV.open(
      path,
      "w",
      headers: %w[tabletype table id field authority vocab termid form refname],
      write_headers: true
    )
    Omca.orig_dirs.each { |dir| extract_from_files(dir, csv) }
    csv.close
    puts "Wrote all authority usages to #{path}"
  end

  no_commands do
    def add_parsed_detail(base, val)
      base["refname"] = val
      parsed = Omca::Refname.parse(val)
      base["authority"] = parsed.type
      base["vocab"] = parsed.subtype
      base["termid"] = parsed.identifier
      base["form"] = parsed.label
      base
    rescue
      base
    end

    def extract_from_files(dir, csv)
      dirpath = File.join(Omca.datadir, "orig", dir)
      puts "Extracting from #{dirpath}"
      Dir.children(dirpath).each do |filename|
        extract_from_file(dir, filename, csv)
      end
    end

    def extract_from_file(dir, filename, csv)
      filepath = File.join(Omca.datadir, "orig", dir, filename)
      puts "Extracting from #{filepath}"
      base = {
        "tabletype" => dir,
        "table" => File.basename(filename, ".csv")
      }
      CSV.foreach(filepath, headers: true) do |row|
        extract_from_row(base.dup, row, csv)
      end
    end

    def extract_from_row(base, row, csv)
      base["id"] = row["id"]
      row.each { |field, val| extract_from_field(base.dup, field, val, csv) }
    end

    def extract_from_field(base, field, val, csv)
      return if field.end_with?("refname")
      return if val.blank?
      return unless val.start_with?("urn:cspace:")
      return if val[":vocabularies:"]

      base["field"] = field
      termdata = add_parsed_detail(base, val)
      csv << termdata.values_at(*csv.headers)
    end
  end
end
