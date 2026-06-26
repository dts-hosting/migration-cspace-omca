# frozen_string_literal: true

require "spec_helper"

RSpec.describe Omca::Jobs::NonRefnameAuth do
  describe ":non_refname_auth__final" do
    let(:data) { csv_job_output(:non_refname_auth__final) }

    it "only includes none matchtypes" do
      result = data[:matchtype].all? { |e| e == "none" }
      expect(result).to be true
    end
  end

  describe ":non_refname_auth__usage_merge" do
    let(:data) { csv_job_output(:non_refname_auth__usage_merge) }

    it "merges provided valid refname usages" do
      row = data.find do |row|
        row[:id] == "bc18fb74-23d1-4386-9652-5dd49076dec0" &&
          row[:field] == "objectproductionorganization"
      end
      expect(row[:refname]).to eq(
        "urn:cspace:museumca.org:orgauthorities:name(organization):"\
          "item:name(StoneSteccati1461709280846)'Stone & Steccati'"
      )
    end
  end
end
