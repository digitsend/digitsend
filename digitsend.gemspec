# -*- encoding: utf-8 -*-
require File.expand_path('../lib/digitsend/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Chad Hendry"]
  gem.email         = ["chendry@digitsend.com"]
  gem.description   = %q{client library for DigitSend.}
  gem.summary       = %q{DigitSend allows you to send secure, phone-verified messages.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "digitsend"
  gem.require_paths = ["lib"]
  gem.version       = Digitsend::VERSION
end
