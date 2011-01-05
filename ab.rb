# -*- coding: utf-8 -*-

require 'optparse'
require 'net/http'

module ApacheBench
  class KeepAliveClient
    SLEEP = 6
    def initialize
      @sleep = SLEEP
    end

    def run
      t = Thread.new do

        while true do
          begin
            http = Net::HTTP.new("mana-web-a-b-1.utagoe.net", 80)
            # http.set_debug_output STDERR
            http.start do
              while true do
                begin
                  http.get("/chat2.php")
                  sleep @sleep
                rescue
                  p "closed"
                  break
                end
              end
            end
          rescue
            p "error"
            sleep @sleep
            next
          end
        end
        
      end
    end
  end
end

n = 150

n.times do
  client = ApacheBench::KeepAliveClient.new
  client.run()
end

while true do
  sleep 5
end
