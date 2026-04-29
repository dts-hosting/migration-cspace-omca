# frozen_string_literal: true

module Omca
  module Db
    module Queries
      module_function

      def main_table(table_name)
        <<~SQL
          select tbl.*
          from #{table_name} tbl
          inner join misc on tbl.id = misc.id and
            misc.lifecyclestate != 'deleted'
        SQL
      end
    end
  end
end
