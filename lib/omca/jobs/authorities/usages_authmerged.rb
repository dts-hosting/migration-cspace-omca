# frozen_string_literal: true

module Omca
  module Jobs
    module Authorities
      class UsagesAuthmerged
        include Omca::DynamicCsvJobable

        def self.desc = "Compile all merged-in new authority usages"

        def config = Omca::Authmerge.authority_controlled_target_field_config

        def source = config.keys
          .map { |arr| :"authmerge_#{arr[0]}__#{arr[1]}" }

        def destination = :authorities__usages_authmerged

        def job_code
          tmppath = File.join(Omca.wrkdir, "temp")
          FileUtils.mkdir_p(tmppath)

          config.each do |table, fields|
            extract_from_table(table, fields, tmppath)
          end

          `xan cat rows --glob '#{tmppath}/*.csv' > #{destination_path}`

          # FileUtils.rm_rf(tmppath)
        end

        private

        def extract_from_table(table, fields, tmppath)
          tabletype = table[0]
          table = table[1]

          path = Omca.registry
            .resolve(:"authmerge_#{tabletype}__#{table}")
            .path

          fields.each do |field|
            extract_from_field(path, field, tmppath, table)
          end
        end

        def extract_from_field(path, field, tmppath, table)
          puts "Extracting #{table}.#{field}"
          outpath = File.join(tmppath, "#{table}_#{field}.csv")
          `#{extractcmd(path, field, table, outpath)}`
        end

        def extractcmd(path, field, table, outpath)
          "xan filter '#{field} ne \"\"' #{path} | "\
            "xan select -e 'recordcsid,id,#{field} as val' | "\
            "xan map '\"#{table}\" as table, \"#{field}\" as field' "\
            "> #{outpath}"
        end
      end
    end
  end
end
