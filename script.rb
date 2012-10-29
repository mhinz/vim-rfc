#!/usr/bin/env ruby

require 'nokogiri'
require 'net/http'
require 'yaml'

module VimRFC

  #
  # Settings.
  #
  $rfcfile   = 'test.xml'
  $cachefile = 'test.yml'

  $rfchash   = {}

  #
  # Event-driven XML parsing. Basically a state machine that fills a hash.
  #
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
        $rfchash[@docid] = @title if @docid and @title
      end
    end
  end

  #
  # Main class of this module.
  #
  class Handling
    def initialize
      if File.exist? $cachefile
        load_from_cachefile
      elsif File.exist? $rfcfile
        read_xml_into_hash
        write_to_cachefile
      else
        get_rfcfile
        read_xml_into_hash
        write_to_cachefile
      end
    end

    def get_rfcfile
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

    def search(regex)
      load_from_cachefile
      $rfchash.each_pair do |id,title|
        if title =~ /#{regex}/i
          puts "#{id}: #{title}"
        end
      end
    end

    def write_to_cachefile
      File.open($cachefile, 'w') do |f|
        f.write($rfchash.to_yaml)
      end
    end

    def load_from_cachefile
      require 'yaml'
      $rfchash = YAML::load_file($cachefile)
    end

    def read_xml_into_hash
      Nokogiri::XML::SAX::Parser.new(VimRFC::Parser.new).parse_file($rfcfile)
    end
  end
end

VimRFC::Handling.new.search($*[0])
