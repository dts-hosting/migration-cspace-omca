# frozen_string_literal: true

module Omca
  module Jobs
    module AuthorityMerge
      module_function

      # @param source [Array<Symbol>]
      # @param dest [Symbol]
      # @param table [String]
      # @param tabletype [String]
      # @param rectype [String]
      def job(source:, dest:, table:, tabletype:, rectype:)
        lkups = get_lookup(tabletype, table)

        Kiba::Extend::Jobs::Job.new(
          files: {
            source: source,
            destination: dest,
            lookup: lkups
          },
          transformer: xforms(table, lkups)
        )
      end

      def get_lookup(tabletype, table)
        key = [tabletype, table]
        config = Omca::Authmerge.authority_controlled_target_field_config
        return [] unless config.key?(key)

        config[key].map do |field|
          :"new_refname_usages_split__#{table}_#{field}"
        end
      end

      def xforms(table, lkups)
        Kiba.job_segment do
          unless lkups.empty?
            lkups.each do |lkup|
              transform Omca::Xforms::AuthorityMerge,
                lookup: send(lkup),
                field: lkup.to_s.split("_").last
            end
          end
        end
      end
    end
  end
end
