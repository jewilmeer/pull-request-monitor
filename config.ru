require 'rubygems'
require 'bundler'

Bundler.require

require './application'
use Rack::Pjax
run Application
