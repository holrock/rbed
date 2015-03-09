require "rbed/version"
require "rbed/reader"
require "rbed/fam"
require "rbed/bim"
begin
  require "rbed/bed.so"
rescue LoadError
  require "rbed/bed"
end
  

module Rbed
  Homo1   = 0b00
  Hetero  = 0b10 # hetero and missing swap bit order
  Homo2   = 0b11
  Missing = 0b01
end
