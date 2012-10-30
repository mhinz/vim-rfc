#!/usr/bin/env ruby

module VimRFC
  require 'nokogiri'

  #
  # Settings.
  #
  $rfcfile   = File.expand_path('~/.rfc.xml')
  $cachefile = File.expand_path('~/.rfc-cache.yml')

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
      when 'rfc-entry' then @in_rfc   = false
      when 'doc-id'    then @in_docid = false
      when 'title'     then @in_title = false
      end
    end

    def characters(s)
      if @in_rfc
        if @in_docid
          # s contains the content of the doc-id tag
          @docid = s
        elsif @in_title
          # s contains the content of the title tag
          $rfchash[@docid] = s if @docid
        end
      end
    end
  end

  #
  # Main class of this module.
  #
  class Handling
    require 'net/http'
    require 'yaml'

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
      delete_rfcfile
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

    def delete_rfcfile
      File.unlink($rfcfile) if File.exist? $rfcfile
    end

    def search(regex)
      load_from_cachefile
      ret = {}
      $rfchash.each_pair do |id,title|
        if title =~ /#{regex}/i
          ret[id] = title
        end
      end
      ret
    end

    def write_to_cachefile
      File.open($cachefile, 'w') do |f|
        f.write($rfchash.to_yaml)
      end
    end

    def load_from_cachefile
      $rfchash = YAML::load_file($cachefile)
    end

    def read_xml_into_hash
      Nokogiri::XML::SAX::Parser.new(VimRFC::Parser.new).parse_file($rfcfile)
    end
  end
end
