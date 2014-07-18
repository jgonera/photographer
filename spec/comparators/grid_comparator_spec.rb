require "spec_helper"

describe Photographer::Comparators::GridComparator do
  subject { Photographer::Comparators::GridComparator.new(cell_size: 5) }

  describe "#compare" do
    it "raises an error when images too different" do
      expect {
        subject.compare test_snap_path("white"), test_snap_path("grid_2x2_last_cell_0.2")
      }.to raise_error(Photographer::ComparisonError)
    end

    it "doesn't raise an error when differences spread across the whole image" do
      expect {
        subject.compare test_snap_path("white"), test_snap_path("grid_2x2_all_cells_0.08")
      }.not_to raise_error
    end

    context "when maximum difference specified" do
      subject { Photographer::Comparators::GridComparator.new(max_difference: 0.05, cell_size: 5) }
      it "respects it" do
        expect {
          subject.compare test_snap_path("white"), test_snap_path("grid_2x2_all_cells_0.08")
        }.to raise_error(Photographer::ComparisonError)
      end
    end
  end
end
