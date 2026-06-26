# frozen_string_literal: true

require "spec_helper"

RSpec.describe Omca::Jobs::Authorities do
  describe ":authorities__fix_malformed_usages", :slow do
    let(:data) { csv_job_output(:authorities__fix_malformed_usages) }

    it "drops citation refname usages with no form/label" do
      row = data.find do |row|
        row[:id] == "96e0bd03-0dc4-4c6b-99d6-fa4459eba07e" &&
          row[:field] == "termsource"
      end
      expect(row).to be_nil
    end

    it "corrects malformed concept refnames" do
      row = data.find do |row|
        row[:id] == "e5f2da9e-6079-4b2b-938c-4c42d120e0da" &&
          row[:field] == "item"
      end
      expect(row[:refname]).to eq(
        "urn:cspace:museumca.org:conceptauthorities:name(concept):"\
          "item:name(cn109825)'Swiss-American'"
      )
    end
  end

  describe ":authorities__fix_usages", :slow do
    let(:data) { csv_job_output(:authorities__fix_usages) }

    it "removes usages from `uncontrol and remove usage` fields" do
      result = data.find { |row| row[:field] == "foundingplace" }
      expect(result).to be_nil
    end

    it "doesn't remove usages from `uncontrol` fields" do
      result = data.find do |row|
        row[:field] == "assocplace" &&
          row[:table] == "assocplacegroup"
      end
      expect(result).not_to be_nil
    end
  end
end
