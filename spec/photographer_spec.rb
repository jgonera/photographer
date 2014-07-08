require "spec_helper"

describe Photographer do
  before :each do
    Photographer.configure do |config|
      config.dir = snaps_dir
    end
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
        stub_camera("1.0white")
        Photographer.snap "test"
        expect(File.exists?(snap_path("test"))).to eq true
        expect(FileUtils.compare_file(snap_path("test"), test_snap_path("1.0white"))).to eq true
      end

      it "replaces existing snap" do
        use_test_snap("test", "1.0white")
        stub_camera("0.9white_0.1black")
        Photographer.snap "test"
        expect(FileUtils.compare_file(snap_path("test"), test_snap_path("0.9white_0.1black"))).to eq true
      end
    end

    context "when in normal mode" do
      before :each do
        Photographer.stub(:update?).and_return(false)
      end

      it "raises an error when snap missing" do
        expect { Photographer.snap "test" }.to raise_error(/missing/i)
      end

      it "raises an error when new snap too different" do
        use_test_snap("test", "1.0white")
        stub_camera("0.89white_0.11black")
        expect { Photographer.snap "test" }.to raise_error(/too different/i)
      end

      it "doesn't raise an error when new snap not too different" do
        use_test_snap("test", "1.0white")
        stub_camera("0.9white_0.1black")
        expect { Photographer.snap "test" }.not_to raise_error
      end
    end
  end
end
