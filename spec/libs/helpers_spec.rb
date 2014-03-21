require_relative '../spec_helper'
include Gutenberg::Helpers

describe Gutenberg::Helpers do

  include_context "lets"

  before do
    @xml = Nokogiri::XML(input_xml)
  end

  it "dup_node_set test" do 
    original_set = get_node_set("owner_signature", @xml)
    new_set = dup_node_set(original_set, @xml)
    new_set.inner_html.should == original_set.inner_html
  end

  it "helper 'get_node_set' should find node_set by criteria" do
    first_set = @xml.xpath("//w:fldSimple[contains(@w:instr, 'start_owner_signature')]/../following-sibling::node()
                            [count(.|//w:fldSimple[contains(@w:instr, 'end_owner_signature')]/../preceding-sibling::node())=count(
                            //w:fldSimple[contains(@w:instr, 'end_owner_signature')]/../preceding-sibling::node())]")
    
    second_set = get_node_set("owner_signature", @xml)
    first_set.should == second_set
  end

  it "newly created xml should have all fields unmerged" do
    get_unmerged_fields(xml).should == mergefields
  end

  describe "find_element(s)" do
    it "should find node by criteria" do 
      first = find_element("first_name", @xml)
      second = @xml.xpath("w:fldSimple[contains(@w:instr, 'first_name') and contains(@w:instr, 'MERGEFIELD')]").first
      first.should == second
    end

    it "should find nodes by criteria" do 
      first_set = find_elements("first_name", @xml)
      second_set = @xml.xpath("w:fldSimple[contains(@w:instr, 'first_name') and contains(@w:instr, 'MERGEFIELD')]")
      first_set.should == second_set
    end
  end
  
  describe "new elements" do
    it "helper 'new_tag' should add new tag to document" do 
      tag = new_tag('r', @xml)
      tag.content = "test_content"

      @xml.root.add_child(tag)

      find_tag = @xml.xpath("//w:r[contains(.,'test_content')]").first
      tag.should == find_tag
    end

    it "helper 'new_label_node' should add new text label to document" do 
      tag = new_label_node('test_content', @xml)
      @xml.root.add_child(tag)

      find_tag = @xml.xpath("//w:t[contains(.,'test_content')]").first.parent
      tag.should == find_tag
    end 
  end

  describe "get_unmerged_fields helper" do
    it "should find mergefields in input xml" do 
      fields = get_unmerged_fields(@xml)
      fields.should == ["first_name", "last_name", "a_long_paragraph", "table_identifier_1", "meal", "drink", "appetizer", "dessert", "start_owner_signature", "end_owner_signature"]
    end 

    it "should not find mergefields in output xml" do 
      @output_xml = Nokogiri::XML(output_xml)
      fields = get_unmerged_fields(@output_xml)
      fields.should == []
    end
  end
end