#
# Gutenberg::Docx - is a base Mediator whitch delegates responsibilities
# to another gutenberg singleton classes, which replace their part of xml.
#

# required for standalone usage
unless defined?(Rails)
  require 'active_support/inflector'
  require 'active_support/concern'
  require 'gutenberg/support'
  require 'gutenberg/version'
  require 'gutenberg/helpers'
  require 'gutenberg/replacer_base'
  require 'gutenberg/sequences'
  require 'gutenberg/check_boxes'
  require 'gutenberg/tables'
  require 'gutenberg/strings'
  require 'gutenberg/exceptions'
end

require 'zip'
require 'nokogiri'
require 'fileutils'
require 'gutenberg/helpers'
require 'json'

# Add ability to run gem rake tasks from Rails env.
require 'gutenberg/railtie' if defined?(Rails)

module Gutenberg
  class Docx
    include Gutenberg::Helpers
    #
    # Avaliable keys and Mutable xml documents
    #
    PARAMS_KEYS = [:sequences, :check_boxes, :tables, :strings]
    PARTS_FOR_REPLACE_REGEX = [/word\/document.xml/, /word\/numbering.xml/, /word\/header(\d)*.xml/, /word\/footer(\d)*.xml/]

    def initialize(docx_file, params_json)
      @zip_file = docx_file.is_a?(String) ? Zip::File.new(docx_file) : Zip::File.open(docx_file.path)
      #
      # params_json.to_s - adds availability to receive params json as json or Hash
      #
      @params_hash = Gutenberg::Support.symbolize_keys( params_json.is_a?(Hash) ? params_json : JSON.parse(params_json) )
    end

    #
    # generate and save docx file with replaced mergefields
    #
    def generate path
      buffer = Zip::OutputStream.write_buffer do |out|
        @zip_file.entries.each do |entry|
          if entry_for_replacing?(entry.name)
            out.put_next_entry(entry.name)
            out.write replace(entry.name).to_s
          else
            out.put_next_entry(entry.name)
            out.write entry.get_input_stream.read
          end
        end
      end

      File.open(path, "w") {|f| f.write(buffer.string) }
    end

    private
    #
    # delegates replace functionality to apropriate class
    #
    def replace file_path
      xml = PARAMS_KEYS.each_with_object(Nokogiri::XML(@zip_file.read(file_path))) do |k, xml|
        instance = "Gutenberg::#{k.to_s.camelize}".constantize.new
        xml = instance.replace(@params_hash[k], xml) if @params_hash.include?(k)
      end

      fields = get_unmerged_fields(xml)
      raise Gutenberg::MergefieldNotReplacedError.new(fields) if fields.size > 0
      xml
    end

    def entry_for_replacing?(file_name)
      PARTS_FOR_REPLACE_REGEX.any?{|regex| file_name.match(regex)}
    end
  end
end
