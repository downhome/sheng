module Sheng
  module Support
    class << self
      def merge_required_hashes(hsh1, hsh2)
        hsh1.merge(hsh2) do |key, old_value, new_value|
          if [old_value, new_value].all? { |v| v.is_a?(Hash) }
            merge_required_hashes(old_value, new_value)
          elsif [old_value, new_value].all? { |v| v.is_a?(Array) } && !old_value.empty?
            [merge_required_hashes(old_value.first, new_value.first)]
          else
            new_value
          end
        end
      end

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
