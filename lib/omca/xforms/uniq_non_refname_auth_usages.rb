# frozen_string_literal: true

module Omca
  module Xforms
    class UniqNonRefnameAuthUsages
      def initialize
        @headers = Omca::Authorities.uniq_non_refname_usages_headers
          .map!(&:to_sym)
        @counter = {}
      end

      def process(row)
        rowhash = row.to_h
        rowhash.delete(:id)
        rowhash.delete(:recordcsid)
        counter[rowhash] = 0 unless counter.key?(rowhash)
        counter[rowhash] += 1
        nil
      end

      def close
        counter.each do |rowhash, ct|
          data = rowhash.merge({usagect: ct})
          yield(headers.map { |hdr| [hdr, data[hdr]] }.to_h)
        end
      end

      private

      attr_reader :headers, :counter
    end
  end
end
