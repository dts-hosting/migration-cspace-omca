# frozen_string_literal: true

module Omca
  module Jobs
    class NukeBom
      include Omca::DynamicCsvJobable

      attr_reader :source, :destination

      def initialize(source:, dest:, table: nil, rectype: nil, tabletype: nil)
        @source = source
        @destination = dest
      end

      def job_code
        `sed 's/\xef\xbb\xbf//g' #{source_path} > #{destination_path}`
      end
    end
  end
end
