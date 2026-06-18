# frozen_string_literal: true

module Omca
  module Xforms
    class UniqAuthUsages
      def initialize
        @headers = Omca::Authorities.uniq_usages_headers
          .map!(&:to_sym)
        @counter = {}
      end

      def process(row)
        refname = row[:refname]
        counter[refname] = 0 unless counter.key?(refname)
        counter[refname] += 1
        nil
      end

      def close
        counter.each do |refname, ct|
          base = {usagect: ct}
          termdata = Omca::Refname.add_parsed_detail(base, refname)
            .transform_keys!(&:to_sym)
          yield(headers.map { |hdr| [hdr, termdata[hdr]] }.to_h)
        end
      end

      private

      attr_reader :headers, :counter
    end
  end
end
