# frozen_string_literal: true

require "spec_helper"

RSpec.describe Omca::Jobs::UnlinkedAuth do
  describe ":unlinked_auth__usages", :slow do
    let(:data) { csv_job_output(:unlinked_auth__usages) }

    it "merges provided refname corrections into usages" do
      row = data.find do |row|
        row[:id] == "1160ba3c-c92b-4e39-9628-0f7bb454bbe2" &&
          row[:field] == "rightsholder"
      end
      expect(row[:refname]).to eq(
        "urn:cspace:museumca.org:orgauthorities:name(organization):item:"\
          "name(OaklandMuseumofCalifornia1454610329915)"\
          "'Oakland Museum of California'"
      )
    end

    it "handles merges of exploded usages correctly" do
      row = data.find do |row|
        row[:id] == "a8c36133-11c9-4175-8653-a27604aa8fd0" &&
          row[:field] == "dhname"
      end
      expect(row[:refname]).to eq(
        "urn:cspace:museumca.org:taxonomyauthority:name(taxon):"\
          "item:name(hematite1892896061)'hematite'|"\
          "urn:cspace:museumca.org:taxonomyauthority:name(taxon):"\
          "item:name(specularite1702936722482)'specularite'|"\
          "urn:cspace:museumca.org:taxonomyauthority:name(taxon):"\
          "item:name(Quartz1696708466530)'Quartz'"
      )
    end
  end
end
