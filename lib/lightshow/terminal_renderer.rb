begin
  require "paint"
rescue LoadError
  abort "Couldn't load the 'paint' gem, which is requred for the terminal renderer"
end

class Lightshow::TerminalRenderer
  # Public: the offset from 0, where pixel 1 starts.
  attr_accessor :offset
  attr_accessor :reverse

  def initialize(offset=0, reverse=false)
    @offset  = offset
    @reverse = reverse
  end

  def render(pixels)
    values = pixels.rotate(@offset).map do |pixel|
      pixel.map { |p| (p * 255).floor }
    end
    values = values.reverse if reverse
    print "\r* "
    print values.map { |v| Paint["  ", nil, v] }.join("")
    print " *"
  end
end
