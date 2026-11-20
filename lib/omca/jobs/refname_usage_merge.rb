# frozen_string_literal: true

module Omca
  module Jobs
    class RefnameUsageMerge
      include Omca::DynamicCsvJobable

      def self.desc(type_subtype) = "Merges new refnames into "\
        ":split_usages_for_refname_lkup__#{type_subtype}"

      def initialize(type:, subtype:)
        @type = type
        @subtype = subtype
      end

      def source = [
        "split_usages_for_refname_lkup__#{type}_#{subtype}",
        "refname_lkup_uniq_usages_split__#{type}_#{subtype}"
      ].map(&:to_sym)

      def source_path = Omca.registry.resolve(source.first).path

      def lookup_path = Omca.registry.resolve(source.last).path

      def destination = :"refname_usage_merge__#{type}_#{subtype}"

      def job_code
        unless Kiba::Extend::Job.output?(source.first)
          return Kiba::Extend::Jobs::NullJob.new(files: {
            source: source.first,
            destination: destination
          })
        end

        `#{cmd}`
      end

      private

      attr_reader :type, :subtype

      def cmd
        "xan join --left --prefix-right \"new\" --drop-key right "\
          "refname #{source_path} refname #{lookup_path} | "\
          "xan select -e 'tabletype, table, id, field, pos, "\
          "newauthority as authority, newvocab as vocab, newtermid as termid, "\
          "newform as form, newnewrefname as refname' "\
          "> #{destination_path}"
      end
    end
  end
end
