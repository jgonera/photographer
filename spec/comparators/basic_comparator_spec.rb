require "spec_helper"

describe Photographer::Comparators::BasicComparator do
  describe "#compare" do
    it "raises an error when images too different" do
      expect {
        subject.compare test_snap_path("white"), test_snap_path("basic_0.11")
      }.to raise_error(Photographer::ComparisonError)
    end

    it "doesn't raise an error when images not too different" do
      expect {
        subject.compare test_snap_path("white"), test_snap_path("basic_0.1")
      }.not_to raise_error
    end

    context "when maximum difference specified" do
      subject { Photographer::Comparators::BasicComparator.new(max_difference: 0.05) }
      it "respects it" do
        expect {
          subject.compare test_snap_path("white"), test_snap_path("basic_0.11")
        }.to raise_error(Photographer::ComparisonError)
      end
    end
  end
end
