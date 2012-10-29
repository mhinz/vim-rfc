#!/usr/bin/env ruby

require 'nokogiri'
require 'net/http'

module VimRFC
  class MyDoc < Nokogiri::XML::SAX::Document
    def start_element(elem, attrs = [])
      if elem == 'doc-id' || elem == 'title'
        @readmode = true
      end
      #p Hash[*attrs.flatten]
    end

    def end_element(elem)
      @readmode = false
    end

    def characters(s)
      puts s if @readmode
    end
  end

  class RFCHandling
    def initialize
      @rfc = '/data/rfc/test.xml'
      update unless File.exist? @rfc
    end

    def update
      Net::HTTP.start('www.ietf.org') do |http|
        f = open(@rfc, 'w')
        begin
          http.request_get('/rfc/new-rfc-index.xml') do |res|
            res.read_body do |segment|
              f.write(segment)
            end
          end
        rescue => err
          puts "Exception: #{err}"
          err
        ensure
          f.close
        end
      end
    end

    def search
      counter = 0
      f = File.new(@rfc)
      begin
        while (line = f.gets)
          puts "#{counter}: #{line}"
          counter += 1
        end
      rescue => err
        puts "Exception: #{err}"
        err
      ensure
        f.close
      end
    end

    def parse
      Nokogiri::XML::SAX::Parser.new(VimRFC::MyDoc.new).parse_file(@rfc)
    end
  end
end

VimRFC::RFCHandling.new.parse
