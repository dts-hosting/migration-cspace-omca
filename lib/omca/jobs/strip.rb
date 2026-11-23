# frozen_string_literal: true

module Omca
  module Jobs
    module Strip
      module_function

      # @param sources [Array<Symbol>]
      # @param dest [Symbol]
      # @param table [String]
      # @param rectype [String]
      # @param tabletype [String]
      def job(source:, dest:, table:, rectype:, tabletype:)
        Kiba::Extend::Jobs::Job.new(
          files: {
            source: source,
            destination: dest
          },
          transformer: xforms(table)
        )
      end

      def xforms(table)
        Kiba.job_segment do
          transform Clean::StripFields, fields: :all
          transform Clean::RegexpFindReplaceFieldVals,
            fields: :all,
            find: /  +/,
            replace: " "

          # OMCA have since added currentlocations in these records, as
          #   per https://3.basecamp.com/3410311/buckets/46713017/card_tables/cards/10220579292
          if table == "movements_common" && Omca.db_iteration == 0
            transform do |row|
              curloc = row[:currentlocation]
              next if curloc.blank?

              row
            end
          end
        end
      end
    end
  end
end
