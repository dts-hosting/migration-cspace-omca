# frozen_string_literal: true

module Omca
  module Rels
    class NonhierSource
      def initialize(subject:, object:, path:)
        @subject = subject
        @object = object
        @path = path
      end

      def run
        Omca::Db::QueryWriter.call(
          query: Omca::Db::Queries.nonhier_rel_data(subject, object),
          path: path
        )
        puts "Wrote results to #{path}"
      end

      private

      attr_reader :subject, :object, :path
    end
  end
end
