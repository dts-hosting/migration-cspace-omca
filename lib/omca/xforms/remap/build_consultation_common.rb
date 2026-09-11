# frozen_string_literal: true

module Omca
  module Xforms
    module Remap
      class BuildConsultationCommon
        def initialize(lookup:)
          @lookup = lookup
          @target = :consultationnumber
          @prefix = "CNV."
        end

        def process(row)
          row[:rectype] = "consultation"
          row[:reason] = "viewer contribution"
          row[:consultationdate] = row[:viewercontributiondate]

          objnum = lookup[row[:recordcsid]].first[:ingestid]
          pos = row[:pos].to_i
          posplus = pos + 1
          row[target] = "#{prefix}#{objnum}.#{posplus}"
          row[:ingestid] = row[target]

          %i[pos viewername viewerrole viewercontributiondate
            viewercontributionnote viewercontribution].each do |f|
            row.delete(f)
          end

          row
        end

        private

        attr_reader :lookup, :target, :prefix
      end
    end
  end
end
