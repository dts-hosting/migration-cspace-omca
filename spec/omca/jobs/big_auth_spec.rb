# frozen_string_literal: true

require "spec_helper"

RSpec.describe Omca::Jobs::BigAuth do
  before(:all) do
    FileUtils.rm(File.join(Omca.datadir, "authority_ref",
      "usages_big_auth.csv"))

    Dir.children(Omca.wrkdir).each do |file|
      next unless file.start_with?("big_auth_")

      path = File.join(Omca.wrkdir, file)
      puts "Deleting #{path}"
      FileUtils.rm(path)
    end
  end

  describe ":big_auth__usages_undiverted" do
    before(:all) { csv_job_output(:big_auth__usages_undiverted) }

    let(:path) { Omca.registry.resolve(:big_auth__usages_undiverted).path }
  end

  describe ":big_auth__fix_diverted_usages" do
    before(:all) { csv_job_output(:big_auth__fix_diverted_usages) }

    let(:path) { Omca.registry.resolve(:big_auth__fix_diverted_usages).path }

    it "merges provided collapsing refname corrections into usages" do
      filter = "'(id eq \"72464dc8-7eb2-4a15-be5f-ec18b2947fdb\") && "\
        "(field eq \"otherparty\")'"
      result = xan_filter(filter, path, include_headers: true, as: :csv)

      expect(result.first[:refname]).to eq(
        "urn:cspace:museumca.org:personauthorities:name(person):"\
          "item:name(i45553)'Dana D. Neitzel'"
      )
    end

    it "merges provided noncollapsing refname corrections into usages" do
      filter = "'(id eq \"007e30bd-c0fb-4e27-9a38-b0a0bd226bbb\") && "\
        "(field eq \"item\")'"
      result = xan_filter(filter, path, include_headers: true, as: :csv)

      expect(result.first[:refname]).to eq(
        "urn:cspace:museumca.org:placeauthorities:name(place):item"\
          ":name(pl97080)'Oakland, California'"
      )
    end
  end

  describe ":big_auth__usages", :slow do
    before(:all) { csv_job_output(:big_auth__usages) }

    let(:path) { Omca.registry.resolve(:big_auth__usages).path }

    it "merges provided collapsing refname corrections into usages" do
      filter = "'(id eq \"72464dc8-7eb2-4a15-be5f-ec18b2947fdb\") && "\
        "(field eq \"otherparty\")'"
      result = xan_filter(filter, path, include_headers: true, as: :csv)

      expect(result.first[:refname]).to eq(
        "urn:cspace:museumca.org:personauthorities:name(person):"\
          "item:name(i45553)'Dana D. Neitzel'"
      )
    end

    it "collapses ALL usages of old forms into new" do
      filter = "'termid eq \"i43344\"'"
      result = xan_filter(filter, path, include_headers: true, as: :csv)

      expect(result.size).to eq(0)
    end

    it "merges provided noncollapsing refname corrections into usages" do
      filter = "'(id eq \"007e30bd-c0fb-4e27-9a38-b0a0bd226bbb\") && "\
        "(field eq \"item\")'"
      result = xan_filter(filter, path, include_headers: true, as: :csv)

      expect(result.first[:refname]).to eq(
        "urn:cspace:museumca.org:placeauthorities:name(place):item"\
          ":name(pl97080)'Oakland, California'"
      )
    end
  end
end
