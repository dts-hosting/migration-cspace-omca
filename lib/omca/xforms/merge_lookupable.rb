# frozen_string_literal: true

module Omca
  module Xforms
    module MergeLookupable
      def get_lookup(table)
        Omca::Dependencies.ensure_fix(table)

        Kiba::Extend::Utils::Lookup.from_job(
          jobkey: Omca::Dependencies.jobkey_for(:fix, table),
          lookup_on: :recordcsid
        )
      end
    end
  end
end
