# frozen_string_literal: true

require "collectionspace/client"

module Omca
  module Refname
    module_function

    # @param refname [String]
    # @return [CollectionSpace::RefName]
    def parse(refname) = CollectionSpace::RefName.new(refname)

    # @param refname [String]
    # @return [String]
    def deurn(refname) = parse(refname).label

    # @param base [Hash] to which parsed details will be added
    # @param refname [String]
    # @return [Hash]
    def add_parsed_detail(base, refname, sym: false)
      base["refname"] = refname
      parsed = Omca::Refname.parse(refname)
      base["authority"] = parsed.type
      base["vocab"] = parsed.subtype
      base["termid"] = parsed.identifier
      base["form"] = parsed.label
      base.transform_keys!(&:to_sym) if sym
      base
    rescue
      base.transform_keys!(&:to_sym) if sym
      base
    end
  end
end
