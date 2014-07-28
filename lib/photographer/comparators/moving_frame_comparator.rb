require "oily_png"

module Photographer
  module Comparators
    class MovingFrameComparator
      class Differentiator
        attr_reader :frame_difference

        def initialize(image_a, image_b, frame_size: 100)
          @image_a = image_a
          @image_b = image_b
          @frame_size = frame_size

          @width = image_a.width
          @column_sums = []

          @width.times do |x|
            sum = 0

            @frame_size.times do |y|
              sum += 1 unless is_equal(x, y)
            end

            @column_sums << sum
          end

          @x = 0
          @y = 0
          @frame_difference = @column_sums[0, @frame_size].inject(:+)
        end

        def move_right
            @frame_difference -= @column_sums[@x]
            @frame_difference += @column_sums[@x + @frame_size]
            @x += 1
        end

        def move_down
          end_y = @y + @frame_size

          @width.times do |x|
            @column_sums[x] -= 1 unless is_equal(x, @y)
            @column_sums[x] += 1 unless is_equal(x, end_y)
          end

          @frame_difference = @column_sums[0, @frame_size].inject(:+)
          @y += 1
          @x = 0
        end

        def is_equal(x, y)
          @image_a[x, y] == @image_b[x, y]
        end
      end

      def initialize(max_difference: 0.1, frame_size: 100)
        @max_difference = max_difference
        @frame_size = frame_size
        @frame_area = frame_size * frame_size
      end

      def compare(path_a, path_b)
        @image_a = ChunkyPNG::Image.from_file path_a
        @image_b = ChunkyPNG::Image.from_file path_b
        differentiator = Differentiator.new(@image_a, @image_b, frame_size: @frame_size)

        x_limit = @image_a.width - @frame_size
        y_limit = @image_a.height - @frame_size

        y_limit.times do
          x_limit.times do
            raise Photographer::ComparisonError if differentiator.frame_difference.to_f / @frame_area > @max_difference
            differentiator.move_right
          end

          differentiator.move_down
        end
      end
    end
  end
end
