#!/usr/bin/env ruby

module Validations
  def self.email?(value)
    /(\w+\.\w+)+@(\w+\.\w+)+/ =~ value
  end

  def self.hostname?(value)
    /^(\w+[\w\-]{,61}\.)+.(\w{2,3}(\.\w{2})?$/ =~ value
  end

  def self.number?(value)
    /^-?\d+(\.\d+)?(e\d+)?$/ =~ value
  end

  def self.integer?(value)
    /^-?\d+$/ =~ value
  end
end