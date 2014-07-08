require "fakefs/spec_helpers"
require "photographer"

module TestHelpers
  def test_snaps_dir
    File.expand_path(File.join(File.dirname(__FILE__), "test_snaps"))
  end
  module_function :test_snaps_dir

  def test_snap_path(snap)
    File.join(test_snaps_dir, snap) + ".png"
  end

  def snaps_dir
    File.expand_path(File.join(File.dirname(__FILE__), "snaps"))
  end

  def snap_path(snap)
    File.join(snaps_dir, snap) + ".png"
  end

  def stub_camera(test_snap)
    Photographer.configure do |config|
      config.camera do |path|
        FileUtils.cp test_snap_path(test_snap), path
      end
    end
  end

  def use_test_snap(name, test_snap)
    FileUtils.cp test_snap_path(test_snap), snap_path(name)
  end
end

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers
  config.include TestHelpers

  config.before :each do
    FakeFS::FileSystem.clone(TestHelpers.test_snaps_dir)
  end
end
