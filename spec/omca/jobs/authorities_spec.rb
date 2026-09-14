# frozen_string_literal: true

require "spec_helper"

RSpec.describe Omca::Jobs::Authorities do
  let(:path) { Omca.registry.resolve(jobkey).path }

  describe ":authorities__fix_malformed_usages", :slow do
    before(:context) do
      jobkey = :authorities__fix_malformed_usages
      clear_output(jobkey)
      csv_job_output(jobkey)
    end

    let(:jobkey) { :authorities__fix_malformed_usages }

    it "drops citation refname usages with no form/label" do
      id = "96e0bd03-0dc4-4c6b-99d6-fa4459eba07e"
      filter = "'(id eq \"#{id}\") && (field eq \"termsource\")'"
      result = xan_filter(filter, path)
      expect(result).to be_empty
    end

    it "corrects malformed concept refnames" do
      id = "e5f2da9e-6079-4b2b-938c-4c42d120e0da"
      filter = "'(id eq \"#{id}\") && (field eq \"item\")'"
      result = xan_filter(filter, path)

      refname = "urn:cspace:museumca.org:conceptauthorities:name(concept):"\
          "item:name(cn109825)'Swiss-American'"
      expect(result.first).to include(refname)
    end
  end

  describe ":authorities__fix_usages", :slow do
    before(:context) do
      jobkey = :authorities__fix_usages
      clear_output(jobkey)
      csv_job_output(jobkey)
    end

    let(:jobkey) { :authorities__fix_usages }

    it "removes usages from `uncontrol and remove usage` fields" do
      # data
      val1 = xan_search_id_return_field(
        "49f34fc2-cdfc-4850-b3ed-b77e24f9371b", "pos", path
      )
      expect(val1).to be_empty

      val2 = xan_search_and_return_field_vals(
        "field", "foundingplace", "id", path
      )
      expect(val2).to be_empty
    end

    it "doesn't remove usages from `uncontrol` fields" do
      filter = "'(field eq \"assocplace\") && (table eq \"assocplacegroup\")'"
      result = xan_filter(filter, path)
      expect(result.length).to be > 0
    end
  end
end
