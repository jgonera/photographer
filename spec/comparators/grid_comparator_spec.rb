require "spec_helper"

describe Photographer::Comparators::GridComparator do
  subject { Photographer::Comparators::GridComparator.new(cell_size: 5) }

  describe "#compare" do
    it "raises an error when images too different" do
      expect {
        subject.compare test_snap_path("white_10x10"), test_snap_path("grid_5_last_cell_0.2")
      }.to raise_error(Photographer::ComparisonError)
    end

    it "doesn't raise an error when differences spread across the whole image" do
      expect {
        subject.compare test_snap_path("white_10x10"), test_snap_path("grid_5_all_cells_0.08")
      }.not_to raise_error
    end

    it "detects difference if image size not divisible by cell size" do
      expect {
        subject.compare test_snap_path("white_14x14"), test_snap_path("grid_5_4_last_cell_0.16")
      }.to raise_error(Photographer::ComparisonError)
    end

    it "ensures the right and bottom edge cells are the same size as other cells" do
      expect {
        subject.compare test_snap_path("white_11x11"), test_snap_path("grid_5_1_last_cell_0.12")
      }.to raise_error(Photographer::ComparisonError)
    end

    context "when maximum difference specified" do
      subject { Photographer::Comparators::GridComparator.new(max_difference: 0.05, cell_size: 5) }
      it "respects it" do
        expect {
          subject.compare test_snap_path("white_10x10"), test_snap_path("grid_5_all_cells_0.08")
        }.to raise_error(Photographer::ComparisonError)
      end
    end
  end
end
