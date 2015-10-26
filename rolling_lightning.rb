require_relative "light_show"

ENV['TZ'] ||= "America/Denver"

PIXELS = 24
renderers = []

if `uname -a` =~ /armv6l/ # raspberry pi
  require_relative "light_show/neopixel_renderer"
  neopixel = LightShow::NeopixelRenderer.new \
    :led_count => PIXELS,
    :led_pin   => 18,
    :offset    => 8 # for sideways, 14 for upright
  renderers << neopixel
else
  require_relative "light_show/console_renderer"
  renderers << LightShow::ConsoleRenderer.new
end

controller = LightShow::Controller.new do |c|
  c["white"]    = LightShow::Spinner.new(1,1,1, :length => 24)
  c["lightning"] = LightShow::Spinner.new(0.48828125, 0.97265625, 0.99609375, :length => 24)
end

animation = LightShow::Animation.new do |a|
  a.forever
  a.delay_ms 20
  a << controller
end

# Starting frame. Always gotta start somewhere.
black = LightShow.color_frame(PIXELS, 0,0,0)

stopped = false
trap("INT") { stopped = true }

Thread.abort_on_exception = true
Thread.new do
  names = [
    ["white", 100],
    ["lightning", 50],
  ]
  loop do
    sleep 3
    names.rotate!
    name, frames = *names.first
    controller.switch_to name, frames
  end
end

animation.frames(black).each do |frame|
  renderers.each { |renderer| renderer.render frame }
  break if stopped
end
renderers.each { |r| r.render black }
puts
