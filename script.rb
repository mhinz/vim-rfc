#!/usr/bin/env ruby

require 'nokogiri'
require 'yaml'
require 'net/http'

module VimRFC

  $rfchash   = {}
  $rfcfile   = 'test.xml'
  $cachefile = 'test.yml'

  class Parser < Nokogiri::XML::SAX::Document
    def start_element(elem, attrs = [])
      case elem
      when 'rfc-entry' then @in_rfc   = true
      when 'doc-id'    then @in_docid = true
      when 'title'     then @in_title = true
      end
    end

    def end_element(elem)
      case elem
      when 'rfc-entry' then @in_rfc   = false and @docid = nil and @title = nil
      when 'doc-id'    then @in_docid = false
      when 'title'     then @in_title = false
      end
    end

    def characters(s)
      if @in_rfc
        if @in_docid
          @docid = s
        elsif @in_title
          @title = s
        end
        $rfchash[@title.to_sym] = @docid if @docid and @title
      end
    end
  end

  class Handling
    def initialize
      update unless File.exist? $rfcfile
    end

    def update
      Net::HTTP.start('www.ietf.org') do |http|
        f = open($rfcfile, 'w')
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
      f = File.new($rfcfile)
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

    def load_from_file
      require 'yaml'
      $rfchash = YAML::load_file($cachefile)
      puts $rfchash.inspect
    end

    def save_to_file
      File.open($cachefile, 'w') do |f|
        f.write $rfchash.to_yaml
      end
    end

    def parse
      Nokogiri::XML::SAX::Parser.new(VimRFC::Parser.new).parse_file($rfcfile)
    end
  end
end

foo = VimRFC::Handling.new
foo.parse
foo.save_to_file
