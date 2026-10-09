# frozen_string_literal: true

module Omca
  module Jobs
    module StructuredDates
      class Exitdate
        include Omca::DynamicCsvJobable

        def self.desc = "Extract exitdate rows from top level structured "\
          "date table"

        def phase = Omca::Remap.previous

        def source = [:"#{phase}_structured_dates__top"]

        def source_path = Omca.registry
          .resolve(source.first)
          .path

        def destination = :structured_dates__exitdate

        def job_code
          cmd = %(xan filter 'primarytype eq "exitDateGroup"' ) +
            source_path.to_s

          xan_result = `#{cmd}`.chomp
          File.open(destination_path, "w") { |f| f << xan_result }
        end
      end
    end
  end
end
