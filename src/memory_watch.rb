#!/usr/bin/env ruby

class HumanBinarySize
  MATCHER = /([\d_,]+) *([kmgtp])?b?/i
  
  MULTIPLIER = {
    'b' => 1,
    'k' => 2**10,
    'm' => 2**20,
    'g' => 2**30,
    't' => 2**40,
    'p' => 2**50
  }
  
  class HumanBinarySizeError < RuntimeError; end
  
  def initialize(size_str)
    @size_str = size_str
    @parsed = MATCHER.match(size_str)
    raise HumanBinarySizeError.new("Couldn't parse '#{@size_str}'") if @parsed.nil?
    @base = @parsed[1].gsub(",", "")
    @base_int = @base.to_i
    @multiplier_code = (@parsed[2] || 'b').downcase
    mult = MULTIPLIER[@multiplier_code]
    raise HumanBinarySizeError.new("Bad file size code: #{@parsed[2]}") if mult.nil?
    @size_bytes = @base_int*mult
  end
  
  def to_bytes
    @size_bytes
  end
end


def main(args)
  process_grep, rss_size_str, signal, interval_str = args
  interval_sec = 0
  begin
    max_rss = HumanBinarySize.new(rss_size_str).to_bytes
    signal = signal.upcase
    interval_sec = interval_str.to_i
  rescue Exception => e
    puts e.to_s
  end
  if interval_sec == 0
    puts "Usage: memory_watch process_regex max_rss signal interval_sec"
    exit(1)
  end
  
  cmd = "ps -e -www -o pid,rss,command | grep '#{process_grep}'"
  
  loop do
    ps_output = `#{cmd}`.split("\n")
    ps_output.each do |line|
      parts = line.split(' ')
      puts line
      pid = parts[0].to_i
      rss = parts[1].to_i*1024 #ps lists in kb
      if rss >= max_rss
        #puts "Sending #{signal} to #{pid}"
        ::Process.kill(signal, pid)
      else
        #puts "pid #{pid} ok: #{rss} < #{max_rss}"
      end
    end
    sleep interval_sec
  end  
end

if __FILE__ == $0 
  main(ARGV)
end
