require "photographer/version"
require "oily_png"

module Photographer
  class << self
    attr_accessor :max_difference

    def initialize
      @max_difference = 0.1
    end

    def configure
      yield self
    end

    def dir=(path)
      @dir = File.join path, "snaps"
      FileUtils.mkpath @dir
    end

    def camera(&block)
      @camera = block
    end

    def snap(name)
      path = File.join @dir, name + ".png"
      path_new = File.join @dir, name + ".new.png"

      @camera.call path_new
      raise "New snap too different!" if compare(path, path_new) > @max_difference
    end

    protected

    def compare(path, path_new)
      return 0 unless File.exists? path

      # based on http://jeffkreeftmeijer.com/2011/comparing-images-and-creating-image-diffs/
      image = ChunkyPNG::Image.from_file path
      image_new = ChunkyPNG::Image.from_file path_new

      diff_count = 0

      image.height.times do |y|
        image.row(y).each_with_index do |pixel, x|
          diff_count += 1 unless pixel == image_new[x, y]
        end
      end

      diff_count.to_f / image.pixels.length
    end
  end

  module DSL
    def snap(name)
      Photographer.snap name
    end
  end
end
