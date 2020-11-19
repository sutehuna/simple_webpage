# frozen_string_literal: true

require 'rexml/document'
require_relative './simple_file'
require 'fileutils'

# class for read and write xml file
class SimpleIO
  class << self
    def read(id)
      xml = REXML::Document.new(File.new(filepath(id)))
      SimpleFile.new(id, xml.elements['root/title'].text, xml.elements['root/text'].text)
    end

    def read_all
      Dir.glob('public/files/*.xml').map do |x|
        xml = REXML::Document.new(File.new(x))
        SimpleFile.new(File.basename(x, '.xml').to_i, xml.elements['root/title'].text, xml.elements['root/text'].text)
      end
    end

    def write(file)
      File.open(filepath(file.id), 'w') do |f|
        f.write("<root><title>#{file.title}</title><text>#{file.text}</text></root>")
      end
    end

    def delete(id)
      FileUtils.rm(filepath(id))
    end

    def exist?(id)
      File.exist?(filepath(id))
    end

    def filepath(id)
      "public/files/#{id}.xml"
    end
  end
end
