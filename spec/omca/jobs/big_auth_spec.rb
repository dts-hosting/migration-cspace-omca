# frozen_string_literal: true

require "spec_helper"

RSpec.describe Omca::Jobs::BigAuth do
  describe ":big_auth__usages", :slow do
    let(:key) { :big_auth__usages }
    let(:data) { csv_job_output(key) }
    let(:path) { Omca.registry.resolve(key).path }

    it "merges provided refname corrections into usages" do
      data
      filter = "'(id eq \"72464dc8-7eb2-4a15-be5f-ec18b2947fdb\") && "\
        "(field eq \"otherparty\")'"
      row = xan_filter(filter, path, include_headers: true)
      binding.pry

      expect(row[:refname]).to eq(
        "urn:cspace:museumca.org:personauthorities:name(person):"\
          "item:name(i45553)'Dana D. Neitzel'"
      )
    end
  end
end
