# frozen_string_literal: true

module Omca
  module Jobs
    class NukeBom
      def self.desc = "Remove BOM from all orig data values"

      def self.run(...) = new(...).run

      def initialize(source:, dest:, table:, rectype:, tabletype:)
        @source = source
        @destination = dest
        @sourcepath = Omca.registry.resolve(source).path
        @destpath = Omca.registry.resolve(destination).path
      end

      def run
        # FileUtils.cp(sourcepath, destpath)
        `sed 's/\xef\xbb\xbf//g' #{sourcepath} > #{destpath}`
        puts "Wrote to #{destpath}"
      end

      private

      attr_reader :source, :destination, :sourcepath, :destpath
    end
  end
end
