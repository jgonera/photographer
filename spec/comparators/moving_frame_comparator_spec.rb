require "spec_helper"

class FakeImage
  def initialize(matrix)
    @matrix = matrix
  end

  def [](x, y)
    @matrix[y][x]
  end

  def width
    @matrix[0].length
  end
end

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

describe Photographer::Comparators::MovingFrameComparator::Differentiator do
  let(:blank_image) {
    FakeImage.new([
      [0, 0, 0],
      [0, 0, 0],
      [0, 0, 0]
    ])
  }

  it "calculates the difference for frame at x=0" do
    subject = Photographer::Comparators::MovingFrameComparator::Differentiator.new(
      blank_image,
      FakeImage.new([
        [1, 0, 0],
        [0, 0, 0],
        [0, 0, 0]
      ]),
      frame_size: 2
    )
    expect(subject.frame_difference).to eq 1
  end

  describe "#move_right" do
    it "calculates the difference for frame at x=1" do
      subject = Photographer::Comparators::MovingFrameComparator::Differentiator.new(
        blank_image,
        FakeImage.new([
          [0, 0, 1],
          [0, 0, 0],
          [0, 0, 0]
        ]),
        frame_size: 2
      )
      subject.move_right
      expect(subject.frame_difference).to eq 1
    end

    it "subtracts previous column's sum" do
      subject = Photographer::Comparators::MovingFrameComparator::Differentiator.new(
        blank_image,
        FakeImage.new([
          [1, 0, 0],
          [0, 0, 0],
          [0, 0, 0]
        ]),
        frame_size: 2
      )
      subject.move_right
      expect(subject.frame_difference).to eq 0
    end
  end

  describe "#move_down" do
    it "calculates the difference for frame at y=1" do
      subject = Photographer::Comparators::MovingFrameComparator::Differentiator.new(
        blank_image,
        FakeImage.new([
          [0, 0, 0],
          [0, 0, 0],
          [1, 0, 0]
        ]),
        frame_size: 2
      )
      subject.move_down
      expect(subject.frame_difference).to eq 1
    end

    it "subtracts previous row's values" do
      subject = Photographer::Comparators::MovingFrameComparator::Differentiator.new(
        blank_image,
        FakeImage.new([
          [1, 0, 0],
          [0, 0, 0],
          [0, 0, 0]
        ]),
        frame_size: 2
      )
      subject.move_down
      expect(subject.frame_difference).to eq 0
    end

    it "resets x to zero" do
      subject = Photographer::Comparators::MovingFrameComparator::Differentiator.new(
        blank_image,
        FakeImage.new([
          [0, 0, 0],
          [0, 0, 0],
          [0, 0, 1]
        ]),
        frame_size: 2
      )
      subject.move_right
      subject.move_down
      subject.move_right
      expect(subject.frame_difference).to eq 1
    end
  end
end
