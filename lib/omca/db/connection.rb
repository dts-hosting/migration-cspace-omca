# frozen_string_literal: true

require "pg"

module Omca
  module Db
    # Monkey-patch PG::Connection class to add `open?` and `close` methods
    class PG::Connection
      def open?
        status
      rescue PG::ConnectionBad
        false
      else
        true
      end

      def close
        unless open?
          puts "DB connection already closed"
          return
        end

        dbname = db
        finish
        puts "Closed DB connection to #{dbname}"
      end
    end

    # Opens database connection
    class Connection
      CREDS = {
        host: "localhost",
        port: 5432,
        dbname: "omca_domain_omca",
        user: "kristina",
        password: nil
      }

      class << self
        def call
          check_connection = Omca.connection
          return new_connection unless check_connection

          return check_connection if check_connection.open? &&
            check_connection.db == CREDS[:dbname]

          new_connection
        end

        private

        def new_connection
          connection = PG::Connection.new(**CREDS)
          Omca.set_connection(connection)
        end
      end
    end
  end
end
