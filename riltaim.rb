#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'date'

# Hjelpemetode for å printe antall sekunder litt penere
def humanize secs
  [[60, :seconds], [60, :minutes], [24, :hours], [1000, :days]].map{ |count, name|
    if secs > 0
      secs, n = secs.divmod(count)
      "#{n.to_i} #{name}"
    end
  }.compact.reverse.join(' ')
end

stop = JSON.parse(Net::HTTP.get('api.ruter.no',"/ReisRest/Place/FindMatches/helgesens%20gate"))[0]['ID']

#skoyen = JSON.parse(Net::HTTP.get('api.ruter.no',"/ReisRest/Place/FindMatches/skøyen"))[0]['ID']

#JSON.parse(Net::HTTP.get('api.ruter.no',"/ReisRest/RealTime/GetRealTimeData/#{stop}")).select { |s| s['DestinationRef'] == 3012501 }[0]

nordover = JSON.parse(Net::HTTP.get('api.ruter.no',"/ReisRest/RealTime/GetRealTimeData/#{stop}")).select { |s| s['DirectionRef'] == "2" }[0]

avreiseJSDate = nordover['ExpectedDepartureTime']

#avreiseJSDate =~ /\/Date\((\d+)(.*)\)\//
#timestamp = $1.to_i
#offset = $2

avreiseJSDate =~ /\/Date\((\d+.*)\)\//

avreiseDT = DateTime.strptime($1, '%Q%z')

avreiseTime = avreiseDT.to_time

diffSec = avreiseTime - Time.now

#puts "Forste avreise nordover om #{humanize(diffSec)}"
puts "Forste avreise nordover om #{diffSec} secs\t(#{humanize(diffSec)})\t(#{avreiseTime})"
