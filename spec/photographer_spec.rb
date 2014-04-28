require "spec_helper"

describe Photographer do
  include FakeFS::SpecHelpers

  describe ".snap" do
    it "raises an error if no camera defined" do
      expect { Photographer.snap "test" }.to raise_error(/camera/i)
    end

    context "when in update mode" do
      before :each do
        ENV["PHOTOGRAPHER"] = "update"
        Photographer.configure do |config|
          config.dir = "/somepath"
          config.camera do |path|
            image = ChunkyPNG::Image.new(1, 1, ChunkyPNG::Color::WHITE)
            image.save(path)
          end
        end
      end

      after :each do
        ENV.delete "PHOTOGRAPHER"
      end

      it "saves a named snap in given directory" do
        Photographer.snap "test"
        expect(File.exists?("/somepath/snaps/test.png")).to eq true
      end

      it "replaces existing snap" do
        image = ChunkyPNG::Image.new(1, 1, ChunkyPNG::Color::BLACK)
        image.save("/somepath/snaps/test.png")

        Photographer.snap "test"
        image_new = ChunkyPNG::Image.from_file("/somepath/snaps/test.png")
        expect(image_new[0, 0]).to_not eq image[0, 0]
      end
    end
  end
end
