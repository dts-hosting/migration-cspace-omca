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
    before(:context) do
      jobkey = :non_refname_auth__usage_merge
      clear_output(jobkey)
      csv_job_output(jobkey)
    end

    let(:jobkey) { :non_refname_auth__usage_merge }
    let(:path) { Omca.registry.resolve(jobkey).path }

    it "merges provided valid refname usages" do
      id = "bc18fb74-23d1-4386-9652-5dd49076dec0"
      field = "objectproductionorganization"
      filter = "'(id eq \"#{id}\") && (field eq \"#{field}\")'"
      result = xan_filter(filter, path)

      refname = "urn:cspace:museumca.org:orgauthorities:name(organization):"\
        "item:name(StoneSteccati1461709280846)'Stone & Steccati'"
      expect(result.first).to include(refname)
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
      expect(val1.first).to eq("urn:cspace:museumca.org:placeauthorities:"\
                         "name(place):item:name(pl175414)"\
                         "'Cliff House, San Francisco'")
    end
  end
end
