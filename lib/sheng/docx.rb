#
# Sheng::Docx - is a base Mediator which delegates responsibilities
# to another sheng singleton classes, which replace their part of xml.
#
module Sheng
  class Docx
    class InvalidFile < Sheng::Error; end
    class TemplateError < Sheng::Error; end
    class OutputPathAlreadyExists < Sheng::Error; end
    class MergeError < Sheng::Error; end

    WMLFileNamePatterns = [
      /word\/document.xml/,
      /word\/numbering.xml/,
      /word\/header(\d)*.xml/,
      /word\/footer(\d)*.xml/
    ]

    attr_reader :errors

    def initialize(input_file_path, params)
      @input_zip_file = Zip::File.new(input_file_path)
      @data_set = DataSet.new(params)
      @errors = {}
    rescue Zip::Error => e
      raise InvalidFile.new(e.message)
    end

    def wml_files
      @wml_files ||= @input_zip_file.entries.map do |entry|
        if is_wml_file?(entry.name)
          WMLFile.new(entry.name, entry.get_input_stream)
        end
      end.compact
    end

    def to_tree
      wml_files.map { |wml| { :file => wml.filename, :tree => wml.to_tree } }
    end

    def required_hash
      wml_files.inject({}) { |memo, wml| Sheng::Support.merge_required_hashes(memo, wml.required_hash) }
    end

    def generate(path, force: false)
      if File.exists?(path) && !force
        raise OutputPathAlreadyExists, "File at #{path} already exists"
      end

      output_buffer = generate_output_buffer

      if errors.present?
        raise MergeError.new(errors)
      end

      File.open(path, "w") { |f| f.write(output_buffer.string) }
    end

  private

    def generate_output_buffer
      Zip::OutputStream.write_buffer do |out|
        begin
          @input_zip_file.entries.each do |entry|
            write_converted_zip_file_to_buffer(entry, out)
          end
        ensure
          out.close_buffer
        end
      end
    end

    def write_converted_zip_file_to_buffer(entry, buffer)
      contents = entry.get_input_stream.read
      buffer.put_next_entry(entry.name)
      if is_wml_file?(entry.name)
        wml_file = WMLFile.new(entry.name, contents)
        buffer.write wml_file.interpolate(@data_set)
        errors.merge!(wml_file.errors)
      else
        buffer.write contents
      end
    end

    def is_wml_file?(file_name)
      WMLFileNamePatterns.any? { |regex| file_name.match(regex) }
    end
  end
end
