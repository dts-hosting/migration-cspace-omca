# frozen_string_literal: true

module Omca
  module Jobs
    module Works
      class OrigUsages
        include Omca::DynamicCsvJobable

        def self.desc = "Extract original usages of "\
          "collectionobjects_common.collection field, in a "\
          "format that can be joined to main usages table"

        def source = :nuke_bom_main__collectionobjects_common

        def destination = :works__orig_usages

        def job_code
          cmd = %(xan select collection,id #{source_path} | ) +
            %(xan filter 'collection ne ""')

          xan_result = `#{cmd}`.chomp

          data = CSV.parse(xan_result, headers: true)
            .map do |row|
              row["tabletype"] = "main"
              row["table"] = "collectionobjects_common"
              row["field"] = "collection"
              row["pos"] = "0"
              refname = fix_refname(row["collection"])
              row["refname"] = refname
              row.delete("collection")
              Omca::Refname.add_parsed_detail(row, refname)
              row["index"] = [
                row[:authority], row["vocab"], row["termid"]
              ].join(" ")

              row
            end

          headers = %w[tabletype table id field pos authority vocab
            termid form refname]

          CSV.open(
            destination_path,
            "w",
            headers: headers,
            write_headers: true
          ) do |csv|
            data.each { |r| csv << r.values_at(*headers) }
          end
        end

        private

        def fix_refname(val)
          val.sub(
            ":vocabularies:name(collection)",
            ":workauthorities:name(work)"
          )
        end
      end
    end
  end
end
