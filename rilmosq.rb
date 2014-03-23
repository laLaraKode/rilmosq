#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'date'
require 'mqtt'

# Configuration
mqttServer="raspi-weez-hf3"
ledHost="pi3"

# Hjelpemetode for å printe antall sekunder litt penere
def humanize secs
  [[60, :seconds], [60, :minutes], [24, :hours], [1000, :days]].map{ |count, name|
    if secs > 0
      secs, n = secs.divmod(count)
      "#{n.to_i} #{name}"
    end
  }.compact.reverse.join(' ')
end

def parseJStime jsString
  jsString =~ /\/Date\((\d+.*)\)\//

  DateTime.strptime($1, '%Q%z').to_time
end

#stop = JSON.parse(Net::HTTP.get('api.ruter.no',"/ReisRest/Place/FindMatches/helgesens%20gate"))[0]['ID']
# Saving one call
stop = "3010536"

nordover = JSON.parse(Net::HTTP.get('api.ruter.no',"/ReisRest/RealTime/GetRealTimeData/#{stop}")).select { |s| s['DirectionRef'] == "2" }[0]

avreiseJSDate = nordover['ExpectedDepartureTime']

avreiseTime = parseJStime(avreiseJSDate)

jsNow = JSON.parse(Net::HTTP.get('sodasmile.org',"/jsdate/?format=json"))

justNow = parseJStime(jsNow['timestamp'])

diffSec = avreiseTime - justNow

puts "Forste avreise nordover om #{diffSec} secs\t(#{humanize(diffSec)})\t(#{avreiseTime})"

led=0

if diffSec < 60
   led = 5
elsif diffSec < 2*60
   led = 4
elsif diffSec < 3*60
   led = 3
elsif diffSec < 4*60
   led = 2
elsif diffSec < 5*60
   led = 1
end

topic="#{ledHost}/leds/"
puts "Setting led to #{led}"

MQTT::Client.connect(mqttServer) do |c|
    c.publish("#{topic}/1", "off")
    c.publish("#{topic}/2", "off")
    c.publish("#{topic}/3", "off")
    c.publish("#{topic}/4", "off")
    c.publish("#{topic}/5", "off")
    if led != 0
       c.publish("#{topic}/#{led}", "on")
    end
end
