require "spec_helper"

describe Photographer do
  let(:comparator) { double }
  before :each do
    Photographer.configure do |config|
      config.dir = snaps_dir
    end
  end

  it "uses BasicComparator as the default comparator" do
    expect(Photographer.comparator).to be_a Photographer::Comparators::BasicComparator
  end

  describe ".snap" do
    it "raises an error if no camera defined" do
      expect { Photographer.snap "test" }.to raise_error(/camera/i)
    end

    context "when in update mode" do
      before :each do
        Photographer.stub(:update?).and_return(true)
      end

      it "saves a named snap in given directory" do
        stub_camera("white_10x10")
        Photographer.snap "test"
        expect(File.exists?(snap_path("test"))).to eq true
        expect(FileUtils.compare_file(snap_path("test"), test_snap_path("white_10x10"))).to eq true
      end

      it "replaces existing snap" do
        use_test_snap("test", "white_10x10")
        stub_camera("basic_0.1")
        Photographer.snap "test"
        expect(FileUtils.compare_file(snap_path("test"), test_snap_path("basic_0.1"))).to eq true
      end
    end

    context "when in normal mode" do
      before :each do
        Photographer.configure do |config|
          config.comparator = comparator
        end
        Photographer.stub(:update?).and_return(false)
      end

      it "raises an error when snap missing" do
        expect { Photographer.snap "test" }.to raise_error(/missing/i)
      end

      it "raises an error when comparison fails" do
        use_test_snap("test", "white_10x10")
        expect(comparator).to receive(:compare)
          .with(snap_path("test"), snap_path("test.new"))
          .and_raise(Photographer::ComparisonError)
        expect { Photographer.snap "test" }.to raise_error(Photographer::ComparisonError)
      end

      it "doesn't raise an error when comparison successful" do
        use_test_snap("test", "white_10x10")
        expect(comparator).to receive(:compare)
          .with(snap_path("test"), snap_path("test.new"))
        expect { Photographer.snap "test" }.not_to raise_error
      end
    end
  end
end
