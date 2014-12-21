clock = Enumerator.new { |y| loop { y << Time.now.to_f } }
const = Enumerator.new { |y| loop { y << 1 } }
limited = (0..10).to_enum

enums = [clock, const, limited]
loop do
  begin
    nexts = enums.map { |e| e.next }
    puts nexts.inspect
    sleep 1
  rescue StopIteration
    break
  end
end
