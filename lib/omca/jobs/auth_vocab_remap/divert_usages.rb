# frozen_string_literal: true

module Omca
  module Jobs
    module AuthVocabRemap
      class DivertUsages
        include Omca::DynamicCsvJobable

        def initialize(args)
          @table = args[:table]
          @field = args[:field]
          @name = args[:name]
        end

        def self.desc(args) = "Diverts usages for #{args[:table]}."\
          "#{args[:field]} for remapping. These will be merged back in by "\
          ":authorities__usages_final_source"

        def phase = Omca::Remap.previous

        def source = :big_auth__collapsing_usage_merge

        def source_path = Omca.registry
          .resolve(source)
          .path

        def destination = :"auth_vocab_remap__#{name}"

        def job_code
          cmd = %(xan filter '(table eq "#{table}") && ) +
            %((field eq "#{field}")' #{source_path})

          xan_result = `#{cmd}`.chomp
          File.open(destination_path, "w") { |f| f << xan_result }
        end

        private

        attr_reader :table, :field, :name
      end
    end
  end
end
