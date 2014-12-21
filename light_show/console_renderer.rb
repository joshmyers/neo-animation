#!ruby19
# encoding: utf-8

begin
  require "paint"
rescue LoadError
  abort "Couldn't load the 'paint' gem, which is requred for the terminal renderer"
end

class LightShow::ConsoleRenderer
  # Public: the offset from 0, where pixel 1 starts.
  attr_accessor :offset
  attr_accessor :reverse

  def initialize(offset=0, reverse=false)
    @offset  = offset
    @reverse = reverse
  end

  def render(pixels)
    values = pixels.map do |pixel|
      pixel.map { |p| (p * 255).floor }
    end
    values = values.reverse if reverse
    values = values.rotate(-@offset)
    print "\r "
    print values.map { |v| Paint["◉ ", v] }.join("")
    print " "
  end
end
