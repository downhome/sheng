# Sheng

[![Build Status](https://travis-ci.org/renewablefunding/sheng.svg?branch=master)](https://travis-ci.org/renewablefunding/sheng)

A Ruby gem for data merging Word documents.  Given a set of data (as a Hash), and a `.docx` template created in [a specific way](docs/creating_templates.md), you can generate a new Word document with the values from the data substituted in place.

## Installation

Add this line to your application's Gemfile:

    gem 'sheng'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sheng

## Quick Start

#### 1. Create Your Template
Follow the instructions in [creating_templates.docx](https://github.com/renewablefunding/sheng/raw/master/docs/creating_templates.docx) (there's also a Markdown version here: [creating_templates.md](docs/creating_templates.md), but it obviously doesn't have example mergefields in it like the `docx` file does, so we recommend the `docx` file).  Store the template you created somewhere in the filesystem where you'll have access to it from your Ruby app.

#### 2. Generate a Data Set Hash
In your application, generate a data set Hash (see [the relevant section in the creation instructions](docs/creating_templates.md#the-data-set) to learn what a data set should look like); for the purposes of these instructions, we'll assume you stored that Hash in a variable called `data_set`.

#### 3. Write Some Code
```ruby
docx = Sheng::Docx.new("path/to/template.docx", data_set)
docx.generate("path/to/store/merged/document.docx")
```

#### 4. Rejoice
\\(• ◡ •)/

## Other Helpful Features

### Generating a Hash of Required Data From a Template
To generate a list of all the mergefield variables expected to be substituted (this can be helpful for developers to ensure they're providing all the necessary data after a template author has added their mergefields):

```ruby
docx = Sheng::Docx.new("path/to/template.docx", {})
docx.required_hash
```

You'll get, in response, a Hash that you'll want to imitate.  Note that for now, the *values* in the hash won't be very meaningful (they'll just be nils and empty arrays), but we plan on adding helpful metadata here about how the fields are actually being used in the document.

### Viewing a Tree of All Mergefields in a Template
This method will show you the actual raw keys being used in the template (including any filters), and also what kind of node Sheng instantiated for each mergefield it encountered (check box, sequence, etc).

```ruby
docx = Sheng::Docx.new("path/to/template.docx", {})
docx.to_tree
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
