require "spec_helper"

describe Photographer::Comparators::MovingFrameComparator do
  subject { Photographer::Comparators::MovingFrameComparator.new(frame_size: 5) }

  describe "#compare" do
    it "raises an error when images too different" do
      expect {
        subject.compare test_snap_path("white_10x10"), test_snap_path("moving_frame_grouped")
      }.to raise_error(Photographer::ComparisonError)
    end

    it "doesn't raise an error when differences scattered across the whole image" do
      expect {
        subject.compare test_snap_path("white_10x10"), test_snap_path("moving_frame_scattered")
      }.not_to raise_error
    end

    context "when maximum difference specified" do
      subject { Photographer::Comparators::GridComparator.new(max_difference: 0.05, cell_size: 5) }

      it "respects it" do
        expect {
          subject.compare test_snap_path("white_10x10"), test_snap_path("moving_frame_scattered")
        }.to raise_error(Photographer::ComparisonError)
      end
    end
  end
end
