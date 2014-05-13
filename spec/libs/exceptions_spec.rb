require_relative '../spec_helper'

describe Sheng::Docx do

  include_context "lets"

  it "should raise an error when empty file supplied" do
    lambda { Sheng::Docx.new('', '') }.should raise_error( Sheng::InputArgumentError )
  end

  it "should raise an error when one ore more mergefields isn't merged" do
    #
    # *** broken_input.json ***
    # Removed first_name and last_name from strings.
    # Thus 2 field must be left unmerged.
    #
    doc = Sheng::Docx.new( input_docx, broken_json )
    lambda { doc.generate(output_file) }.should raise_error( Sheng::MergefieldNotReplacedError )
  end

  it "should raise an error when bad document supplied" do
    bad_documents.each do |doc|
      doc = Sheng::Docx.new( File.open(doc), input_json )
      lambda { doc.generate(output_file) }.should raise_error( Sheng::MergefieldNotReplacedError )
    end
  end
end
