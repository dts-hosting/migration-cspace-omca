# frozen_string_literal: true

module Omca
  module StructuredDate
    module_function

    extend Dry::Configurable

    # @note :scalarvaluescomputed is omitted because it is known to be set to
    #   true when no scalar values have been computed, or, indeed, if all other
    #   data fields are empty
    setting :data_fields,
      reader: true,
      default: %i[dateearliestsinglequalifier datelatestday
        datelatestyear dateassociation dateearliestsingleera
        datedisplaydate dateearliestsinglecertainty datelatestera
        dateearliestsinglequalifiervalue datelatestcertainty
        dateearliestsingleyear datelatestqualifier
        datelatestqualifiervalue dateearliestsinglequalifierunit
        dateperiod dateearliestscalarvalue datelatestmonth datenote
        datelatestscalarvalue datelatestqualifierunit
        dateearliestsingleday dateearliestsinglemonth]
  end
end
