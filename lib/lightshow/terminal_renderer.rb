require "paint"

class Lightshow::TerminalRenderer
  def initialize(offset=0)
    @offset = offset
  end

  def render(pixels)
    values = pixels.rotate(@offset).map do |pixel|
      pixel.map { |p| (p * 255).floor }
    end
    print "* "
    print values.map { |v| Paint["  ", nil, v] }.join("")
    print " *"
    puts
  end
end
