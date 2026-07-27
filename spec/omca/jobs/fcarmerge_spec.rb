# frozen_string_literal: true

require "spec_helper"

RSpec.describe Omca::Jobs::FcarMerge do
  describe ":fcarmerge_repeatable_field_group__persontermgroup" do
    before(:context) do
      jobkey = :fcarmerge_repeatable_field_group__persontermgroup
      clear_output(jobkey)
      csv_job_output(jobkey)
    end

    let(:jobkey) { :fcarmerge_repeatable_field_group__persontermgroup }
    let(:path) { Omca.registry.resolve(jobkey).path }

    it "merges collapsing authority values" do
      val1 = xan_search_id_return_field(
        "af4a6045-9013-45e0-a940-c6ffc3d7d62e", "pos", path
      )
      expect(val1).to eq("1")

      val2 = xan_search_id_return_field(
        "9aeffbc9-7cc2-4e9f-8d6c-f600a3186150", "pos", path
      )
      expect(val2).to eq("0")

      val3 = xan_search_id_return_field(
        "c167b4bb-b1f0-486f-8beb-138d109aea47", "pos", path
      )
      expect(val3).to eq("1")
    end
  end
end
