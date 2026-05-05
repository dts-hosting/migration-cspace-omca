# frozen_string_literal: true

# Tasks related to vocabulary terms
class Vt < Thor
  desc "extract_all", "Write all term lists"
  def extract_all
    all = {}
    all["unparseable"] = Set.new

    Omca.orig_dirs.each { |dir| extract_from_files(dir, all) }
    path = File.join(Omca.datadir, "vocab_terms.csv")
    CSV.open(
      path,
      "w",
      headers: %w[vocab term],
      write_headers: true
    ) do |csv|
      all.each { |k, v| write_terms_for_vocab(csv, k, v) }
    end
    puts "Wrote all terms to #{path}"
  end

  no_commands do
    def extract_from_files(dir, all)
      dirpath = File.join(Omca.datadir, "orig", dir)
      puts "Extracting from #{dirpath}"
      Dir.children(dirpath).each do |filename|
        extract_from_file(dir, filename, all)
      end
    end

    def extract_from_file(dir, filename, all)
      filepath = File.join(Omca.datadir, "orig", dir, filename)
      puts "Extracting from #{filepath}"
      CSV.foreach(filepath, headers: true) do |row|
        extract_from_row(row, all)
      end
    end

    def extract_from_row(row, all)
      row.to_h
        .values
        .compact
        .select { |v| v.start_with?("urn:cspace:museumca.org:vocabularies") }
        .each { |v| extract_from_field(v, all) }
    end

    def extract_from_field(v, all)
      parsed = Omca::Refname.parse(v)
      subtype = parsed.subtype
      all[subtype] = Set.new unless all.key?(subtype)
      all[subtype] << parsed.label
    rescue
      all["unparseable"] << v
    end

    def write_terms_for_vocab(csv, vocab, terms)
      terms.each { |term| csv << [vocab, term] }
    end
  end
end
