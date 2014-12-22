begin
  require "pixel_pi"
rescue LoadError
  abort "Couldn't load the 'pixel_pi' gem, which is requred for the neopixel renderer"
end

class LightShow::NeopixelRenderer
  # Public: the offset from 0, where pixel 1 starts.
  attr_accessor :offset
  attr_accessor :reverse

  # Internal: the neopixels instance
  attr_reader :neopixels

  def initialize(opts={})
    @neopixels = PixelPi::Leds.new \
      opts.fetch(:led_count),
      opts.fetch(:led_pin),
      :frequency  => opts.fetch(:led_frequency_hz, 800_000),
      :dma        => opts.fetch(:led_dma, 5),
      :brightness => opts.fetch(:led_brightness, 255),
      :invert     => opts.fetch(:led_invert, false)
    @offset  = opts.fetch(:offset, 0)
    @reverse = opts.fetch(:reverse, false)
  end

  def render(pixels)
    values = pixels.map do |pixel|
      rgb = pixel.map { |p| (p * 255).floor }
      PixelPi::Color(*rgb)
    end
    values = values.reverse if reverse
    values = values.rotate(-@offset)

    0.upto(@neopixels.length) do |n|
      @neopixels[n] = values[n] if values[n]
    end
    @neopixels.show
  end
end
