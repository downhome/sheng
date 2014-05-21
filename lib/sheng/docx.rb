#
# Sheng::Docx - is a base Mediator whitch delegates responsibilities
# to another sheng singleton classes, which replace their part of xml.
#
module Sheng
  class Docx
    WMLFileNamePatterns = [
      /word\/document.xml/,
      /word\/numbering.xml/,
      /word\/header(\d)*.xml/,
      /word\/footer(\d)*.xml/
    ]

    def initialize(docx_file, params)
      @zip_file = docx_file.is_a?(String) ? Zip::File.new(docx_file) : Zip::File.open(docx_file.path)
      @data_set = Sheng::DataSet.new(params)
    rescue Zip::ZipError
      raise InputArgumentError.new(e.message)
    end

    def generate path
      buffer = Zip::OutputStream.write_buffer do |out|
        begin
          @zip_file.entries.each do |entry|
            write_converted_zip_file_to_buffer(entry, out)
          end
        ensure
          out.close_buffer
        end
      end

      File.open(path, "w") { |f| f.write(buffer.string) }
    end

    def write_converted_zip_file_to_buffer(entry, buffer)
      contents = entry.get_input_stream.read
      buffer.put_next_entry(entry.name)
      if is_wml_file?(entry.name)
        buffer.write WMLFile.new(contents).interpolate(@data_set)
      else
        buffer.write contents
      end
    end

    private

    def is_wml_file?(file_name)
      WMLFileNamePatterns.any? { |regex| file_name.match(regex) }
    end
  end
end
