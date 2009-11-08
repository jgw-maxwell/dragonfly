require 'rmagick'

module Dragonfly
  module Processing

    module RMagickProcessor
      
      GRAVITY_MAPPINGS = {
        'nw' => Magick::NorthWestGravity,
        'n'  => Magick::NorthGravity,
        'ne' => Magick::NorthEastGravity,
        'w'  => Magick::WestGravity,
        'c'  => Magick::CenterGravity,
        'e'  => Magick::EastGravity,
        'sw' => Magick::SouthWestGravity,
        's'  => Magick::SouthGravity,
        'se' => Magick::SouthEastGravity
      }
      
      def crop(temp_object, opts={})
        x       = opts[:x].to_i
        y       = opts[:y].to_i
        gravity = GRAVITY_MAPPINGS[opts[:gravity]] || Magick::ForgetGravity
        width   = opts[:width].to_i
        height  = opts[:height].to_i

        image = rmagick_image(temp_object)

        # RMagick throws an error if the cropping area is bigger than the image,
        # when the gravity is something other than nw
        width  = image.columns - x if x + width  > image.columns
        height = image.rows    - y if y + height > image.rows

        image.crop(gravity, x, y, width, height).to_blob
      end
      
      def resize(temp_object, opts={})
        rmagick_image(temp_object).change_geometry!(opts[:geometry]) do |cols, rows, img|
         img.resize!(cols, rows)
        end.to_blob
      end

      def resize_and_crop(temp_object, opts={})
        image = rmagick_image(temp_object)
        
        width   = opts[:width] ? opts[:width].to_i : image.columns
        height  = opts[:height] ? opts[:height].to_i : image.rows
        gravity = GRAVITY_MAPPINGS[opts[:gravity]] || Magick::CenterGravity

        image.resize_to_fill(width, height, gravity).to_blob
      end

      def vignette(temp_object, opts={})
        x      = opts[:x].to_f      || temp_object.width  * 0.1
        y      = opts[:y].to_f      || temp_object.height * 0.1
        radius = opts[:radius].to_f ||  0.0
        sigma  = opts[:sigma].to_f  || 10.0

        rmagick_image(temp_object).vignette(x, y, radius, sigma).to_blob
      end
      
      private
      
      def rmagick_image(temp_object)
        Magick::Image.from_blob(temp_object.data).first
      end

    end

  end
end