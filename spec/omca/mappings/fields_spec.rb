# frozen_string_literal: true

require "spec_helper"

RSpec.describe Omca::Mappings::Fields do
  describe ":skeleton_rectypes" do
    let(:result) { Omca::Mappings::Fields.skeleton_rectypes }
    it "includes organization" do
      expect(result).to include("organization")
    end
  end

  describe ":skeleton_fields" do
    let(:result) do
      Omca::Mappings::Fields.skeleton_fields(rectype, tabletype)
    end

    context "when organization/main" do
      let(:rectype) { "organization" }
      let(:tabletype) { "main" }

      it "includes foundingplace" do
        chk = result.find { |r| r["db_field"] == "foundingplace" }
        expect(chk).not_to be_nil
      end
    end
  end
end
