# frozen_string_literal: true

module Omca
  module Xforms
    module Remap
      class BuildConsultationOutcomes
        def process(row)
          row[:recordcsid] = "#{row[:recordcsid]}_#{row[:pos]}"

          row[:item] = row[:viewercontribution]
          %i[rectype pos viewername viewerrole viewercontributiondate
            viewercontributionnote viewercontribution].each do |f|
            row.delete(f)
          end

          row[:pos] = "0"

          row
        end
      end
    end
  end
end
