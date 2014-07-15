require "oily_png"

module Photographer
  module Comparators
    class BasicComparator
      def initialize(max_difference: 0.1)
        @max_difference = max_difference
      end

      def compare(path_a, path_b)
        # based on http://jeffkreeftmeijer.com/2011/comparing-images-and-creating-image-diffs/
        image_a = ChunkyPNG::Image.from_file path_a
        image_b = ChunkyPNG::Image.from_file path_b

        diff_count = 0

        image_a.height.times do |y|
          image_a.row(y).each_with_index do |pixel, x|
            diff_count += 1 unless pixel == image_b[x, y]
          end
        end

        raise Photographer::ComparisonError if diff_count.to_f / image_a.pixels.length > @max_difference
      end
    end
  end
end
