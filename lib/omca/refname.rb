# frozen_string_literal: true

require "collectionspace/client"

module Omca
  module Refname
    module_function

    def parse(refname) = CollectionSpace::RefName.new(refname)

    def deurn(refname) = parse(refname).label
  end
end
