require "spec_helper"

describe Photographer::Comparators::BasicComparator do
  describe "#compare" do
    it "raises an error when images too different" do
      expect {
        subject.compare test_snap_path("1.0white"), test_snap_path("0.89white_0.11black")
      }.to raise_error(Photographer::ComparisonError)
    end

    it "doesn't raise an error when images not too different" do
      expect {
        subject.compare test_snap_path("1.0white"), test_snap_path("0.9white_0.1black")
      }.not_to raise_error
    end

    context "when maximum difference specified" do
      subject { Photographer::Comparators::BasicComparator.new(max_difference: 0.05) }
      it "respects it" do
        expect {
          subject.compare test_snap_path("1.0white"), test_snap_path("0.9white_0.1black")
        }.to raise_error(Photographer::ComparisonError)
      end
    end
  end
end
