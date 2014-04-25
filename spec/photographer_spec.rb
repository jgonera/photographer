require "tmpdir"
require "photographer"

RSpec.configure do |config|
  config.before do
    @dir = Dir.mktmpdir

    Photographer.configure do |config|
      config.dir = @dir
      puts @dir
    end
  end

  config.after do
    FileUtils.remove_entry @dir
  end
end

describe Photographer do
  it "is itself" do
    expect(Photographer).to eq Photographer
  end
end
