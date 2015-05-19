module Sheng
  module Support
    class << self
      def new_text_run(value, xml_document:, style_run: nil, space_preserve: false)
        r_tag = new_tag('r', xml_document: xml_document)
        if style_run
          r_tag.add_child(style_run)
        end
        t_tag = new_tag('t', xml_document: xml_document)
        if space_preserve
          t_tag["xml:space"] = "preserve"
        end
        t_tag.content = value
        r_tag.add_child(t_tag)
        r_tag
      end

      def new_tag(tag_name, xml_document:)
        tag = Nokogiri::XML::Node.new(tag_name, xml_document)
        tag.namespace = xml_document.root.namespace_definitions.find { |ns| ns.prefix == "w" }
        tag
      end
    end
  end
end
