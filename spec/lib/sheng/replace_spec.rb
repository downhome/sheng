require_relative '../spec_helper'
include Sheng::Helpers

describe Sheng::Docx do

  include_context "lets"

  let(:string_fields) {["first_name", "last_name", "a_long_paragraph"]}

  let(:tables_fields) {["table_identifier_1", "meal", "drink", "appetizer", "dessert"]}

  let(:sequences_fields) {["start_owner_signature", "end_owner_signature"]}

  it "newly created xml should have all fields unmerged" do
    get_unmerged_fields(xml).should == mergefields
  end

  it "'Sheng::Strings.new.replace' should remove strings keys from unmerged fields" do
    params = input_hash[:strings]
    strings_xml = Sheng::Strings.new.replace(params, xml)
    get_unmerged_fields(strings_xml).should == (mergefields - string_fields)
  end

  it "'Sheng::CheckBoxes.new.replace' should remove check_boxes keys from unmerged fields" do
    params = input_hash[:check_boxes]
    old_element = find_element("//w:name[contains(@w:val, 'check_me')]", xml).parent.clone
    check_boxes_xml = Sheng::CheckBoxes.new.replace(params, xml)
    new_element = find_element("//w:name[contains(@w:val, 'check_me')]", check_boxes_xml).parent
    old_element.to_xml.should_not eq(new_element.to_xml)
  end

  it "'Sheng::Tables.new.replace' should remove strings keys from unmerged fields" do
    params = input_hash[:tables]
    tables_xml = Sheng::Tables.new.replace(params, xml)
    get_unmerged_fields(tables_xml).should == (mergefields - tables_fields)
  end

  it "'Sheng::Sequences.new.replace' should remove sequences keys from unmerged fields" do
    params = input_hash[:sequences]
    sequences_xml = Sheng::Sequences.new.replace(params, xml)
    get_unmerged_fields(sequences_xml).should == (mergefields - sequences_fields)
  end
end
