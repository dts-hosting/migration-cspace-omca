# frozen_string_literal: true

module Omca
  module DynamicCsvJobable
    include Kiba::Extend::Jobs::DynamicJobable

    # @param [String] path to output CSV from which to get row count
    # @return [Integer]
    def outrows
      `xan count #{destination_path}`.chomp.to_i
    end
  end
end
