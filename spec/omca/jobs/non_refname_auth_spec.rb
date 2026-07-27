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

  describe ":non_refname_auth__usages_final", :slow do
    before(:context) do
      jobkey = :non_refname_auth__usages_final
      clear_output(jobkey)
      csv_job_output(jobkey)
    end

    let(:jobkey) { :non_refname_auth__usages_final }
    let(:path) { Omca.registry.resolve(jobkey).path }

    it "merges collapsing authority values" do
      val1 = xan_search_id_return_field(
        "521d86b6-6dd3-4a7c-8673-93db0f4d36f6", "refname", path
      )
      expect(val1).to eq("urn:cspace:museumca.org:placeauthorities:"\
                         "name(place):item:name(pl175414)"\
                         "'Cliff House, San Francisco'")
    end
  end
end
