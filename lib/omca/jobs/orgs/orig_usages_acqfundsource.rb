# frozen_string_literal: true

module Omca
  module Jobs
    module Orgs
      class OrigUsagesAcqfundsource
        include Omca::DynamicCsvJobable

        def self.desc = "Extract original usages of "\
          "acquisitions_common.acquisitionFundingSource field, in a "\
          "format that can be joined to main usages table"

        def norm = @norm ||=
                     Kiba::Extend::Utils::StringNormalizer.new(mode: :cspaceid)

        def source = [
          :nuke_bom_repeatable_field_group__acquisitionfunding,
          Omca.auth_uniq_usages
        ]

        def source_path = Omca.registry
          .resolve(source.first)
          .path

        def usages_path = Omca.registry
          .resolve(source.last)
          .path

        def destination = :orgs__orig_usages_acqfundsource

        def existing_orgs = @existing_orgs ||= build_existing_orgs

        def job_code
          cmd = %(xan select ) +
            %(acquisitionfundingsource,id,pos #{source_path} | ) +
            %(xan filter 'acquisitionfundingsource ne ""')

          xan_result = `#{cmd}`.chomp

          data = CSV.parse(xan_result, headers: true)
            .map do |row|
              row["tabletype"] = "repeatable_field_group"
              row["table"] = "acquisitionfunding"
              row["field"] = "acquisitionfundingsource"
              vocab_refname = row["acquisitionfundingsource"]
              row.delete("acquisitionfundingsource")
              normterm = norm.call(Omca::Refname.deurn(vocab_refname))

              refname = if existing_orgs.key?(normterm)
                existing_orgs[normterm]
              else
                fix_refname(vocab_refname)
              end
              Omca::Refname.add_parsed_detail(row, refname)
              row["index"] = [
                row[:authority], row["vocab"], row["termid"]
              ].join(" ")

              row
            end

          headers = Omca::Authorities.usages_headers

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

        def build_existing_orgs
          cmd = %(xan filter 'vocab eq "organization"' #{usages_path} | ) +
            %(xan select form,refname | xan behead | xan fmt -t '\t')

          `#{cmd}`.chomp
            .split("\n")
            .to_h do |str|
              parts = str.split("\t")
              [norm.call(parts[0]), parts[1]]
            end
        end

        def fix_refname(val)
          val.sub(
            ":vocabularies:name(fundsource)",
            ":orgauthorities:name(organization)"
          ).sub(")'", "-new)'")
        end
      end
    end
  end
end
