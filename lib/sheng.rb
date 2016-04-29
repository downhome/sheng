require 'active_support/inflector'
require 'active_support/core_ext/hash'
require 'zip'
require 'nokogiri'
require 'fileutils'
require 'json'

module Sheng
  class Error < StandardError; end
end

require 'sheng/support'
require 'sheng/version'
require 'sheng/data_set'
require 'sheng/docx'
require 'sheng/wml_file'
require 'sheng/merge_field_set'
require 'sheng/filters'
require 'sheng/merge_field'
require 'sheng/sequence'
require 'sheng/conditional_block'
require 'sheng/check_box'
