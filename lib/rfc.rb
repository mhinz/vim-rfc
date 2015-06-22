#!/usr/bin/env ruby

module VimRFC
  require 'rubygems'
  require 'nokogiri'

  #
  # Settings.
  #
  $indexfile = File.expand_path('~/.vim-rfc.xml')
  $cachefile = File.expand_path('~/.vim-rfc.yml')

  $entryhash = {}

  #
  # Event-driven XML parsing. Basically a state machine that fills a hash.
  #
  class Parser < Nokogiri::XML::SAX::Document
    def start_element(elem, attrs = [])
      case elem
      when 'rfc-entry', 'std-entry' then @in_entry = true
      when 'doc-id'                 then @in_docid = true
      when 'title'                  then @in_title = true
      end
    end

    def end_element(elem)
      case elem
      when 'rfc-entry', 'std-entry' then @in_entry = false
      when 'doc-id'                 then @in_docid = false
      when 'title'                  then @in_title = false
      end
    end

    def characters(s)
      if @in_entry
        if @in_docid
          # s contains the content of the doc-id tag
          @docid = s
        elsif @in_title
          # s contains the content of the title tag
          $entryhash[@docid] = s if @docid
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

    def initialize(rebuild_cache)
      if File.exist? $cachefile and rebuild_cache == 0
        load_cachefile
      else
        VIM::command('redraw | echo "Building cache.."')
        write_indexfile
        read_indexfile_into_hash
        write_cachefile
        delete_indexfile
      end
    end

    def write_indexfile
      Net::HTTP.start('www.rfc-editor.org') do |http|
        f = open($indexfile, 'w')
        begin
          http.request_get('/in-notes/rfc-index.xml') do |res|
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

    def delete_indexfile
      File.unlink($indexfile) if File.exist? $indexfile
    end

    def search(regex)
      load_cachefile
      $entryhash.select { |id,title| title =~ /#{regex}/i }
    end

    def write_cachefile
      File.open($cachefile, 'w') do |f|
        f.write($entryhash.to_yaml)
      end
    end

    def load_cachefile
      $entryhash = YAML::load_file($cachefile)
    end

    def read_indexfile_into_hash
      Nokogiri::XML::SAX::Parser.new(VimRFC::Parser.new).parse_file($indexfile)
    end
  end
end
