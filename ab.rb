# -*- coding: utf-8 -*-

require 'optparse'
require 'net/http'
require 'uri'

module ApacheBench
  class KeepAliveClient
    def initialize(host,port,path,sleep)
      @host = host
      @port = port
      @path = path
      @sleep = sleep

      @stat = 'n'
    end

    def stat
      @stat
    end

    def run
      t = Thread.new do

        while true do
          begin
            http = Net::HTTP.new(@host, @port)
            # http.set_debug_output STDERR
            http.start do
              while true do
                begin
                  http.get(@path)
                  if @stat == 'c' then
                    @stat = 'r'
                  else
                    @stat = 'k'
                  end
                  sleep @sleep
                rescue
                  @stat = "c"
                  break
                end
              end
            end
          rescue
            @stat = "e"
            sleep @sleep
            next
          end
        end
        
      end
    end
  end
end

CLIENTS = []
OPTS = {}
OPTS[:n] = 1
OPTS[:s] = 4
OPTS[:d] = -1
OPTS[:u] = false

opt = OptionParser.new
opt.on('-n VAL'){|v| OPTS[:n] = v.to_i}
opt.on('-s VAL'){|v| OPTS[:s] = v.to_i}
opt.on('-u VAL'){|v| OPTS[:u] = v}
opt.on('-d VAL'){|v| OPTS[:d] = v.to_f}

opt.parse!(ARGV)

OPTS[:u] = ARGV.shift if ARGV.size > 0

if OPTS[:d] == -1 then
  OPTS[:d] = OPTS[:s].to_f / OPTS[:n]
end

raise "no target URL present." if !OPTS[:u]

uri = URI(OPTS[:u])

OPTS[:n].times do
  client = ApacheBench::KeepAliveClient.new(uri.host,uri.port,uri.path,OPTS[:s])
  CLIENTS.push(client)
  client.run()
  sleep OPTS[:d]
end

while true do
  CLIENTS.each do |c|
    print c.stat
  end
  print "\n"
  sleep OPTS[:s]
end
