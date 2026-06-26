# frozen_string_literal: true

require "spec_helper"

RSpec.describe Omca::Jobs::BigAuth do
  describe ":big_auth__collapsing_usage_merge", :slow do
    let(:data) { csv_job_output(:big_auth__collapsing_usage_merge) }

    it "merges provided refname corrections into usages" do
      row = data.find do |row|
        row[:id] == "72464dc8-7eb2-4a15-be5f-ec18b2947fdb" &&
          row[:field] == "otherparty"
      end
      expect(row[:refname]).to eq(
        "urn:cspace:museumca.org:personauthorities:name(person):"\
          "item:name(i45553)'Dana D. Neitzel'"
      )
    end
  end
end
