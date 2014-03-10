gutenberg
=========

Gutenberg is a Ruby Gem that returns a MS Word document given a template document and data.


References: 
  http://tomasvarsavsky.com/2009/04/04/simple-word-document-templating-using-ruby-and-xml/
  https://github.com/jawspeak/ruby-docx-templater

The latest Microsoft Word document (some_doc.docx) is basically a zip package of many documents. Once unzipped,
the file word/document.xml contains the full structure of the word document.

To experiment:
  1. unzip input_document.docx word/document.xml   (there is a sample in this folder)
  2. view the word/document.xml (use a tool to make it pretty)
  3. Change some text in the word/document.xml, and save it.
  4. Add the modified word/document.xml back into the package
    zip input_document.docx word/document.xml 
  5. Now open the input_document.docx in MS Word, and you'll see the changes.

[[Strings]]
We used MERGEFIELD as tokens to be replaced with data that we'll pass to this library (gem).  A merge field in
the xml looks as follows:

  <w:fldSimple w:instr=" MERGEFIELD first_name \* MERGEFORMAT ">
    <w:r>
      <w:rPr>
        <w:noProof/>
      </w:rPr>
      <w:t>«first_name»</w:t>
    </w:r>
  </w:fldSimple>

We can replace this entire w:fldSimple tag with:
  <w:t>Bobby</w:t>

[[CheckBoxes]]
The name of the ckeckbox can be found in this tag, there is also a bookmark with the same name.
To check a box, you can change the <w:default w:val="0"/> to <w:default w:val="1"/>

  <w:r>
    <w:fldChar w:fldCharType="begin">
      <w:ffData>
        <w:name w:val="leave_me_unchecked"/>
        <w:enabled/>
        <w:calcOnExit w:val="0"/>
        <w:checkBox>
          <w:sizeAuto/>
          <w:default w:val="0"/>
        </w:checkBox>
      </w:ffData>
    </w:fldChar>
  </w:r>

[[Tables]]
Tables are enclosed in a <w:tbl> tag;  To find the table, first look for the unique 'table_identifier' 
within a <w:tbl> tag, delete that row, and use MERGEFIELDs in the third row for replacements.

[[Sequences]]
Sequences are the same as tables, except that there is a 'start_' and 'end_' markers to identify the beginning
and end of the block that should be repeated.  

The input will include an array of 'n' named values to replace, and the result should include as many blocks 
as there are elements in the array.
