# Rbed

plink bed file reader for ruby 

```ruby
require 'rbed'
fam, bim, bed = Rbed::Reader.new("test/data/test").load

0.upto(fam.num_individuals() - 1) do |i|
  print fam[i].id, ' '
  0.upto(bim.num_snps() - 1) do |snp|
    gt = bed.get_genotype(snp_index: snp, indiv_index: i)
    case gt
    when Rbed::Homo1
      print bim[snp].allel1 * 2
    when Rbed::Homo2
      print bim[snp].allel2 * 2
    when Rbed::Hetero
      print bim[snp].allel1, bim[snp].allel2
    when Rbed::Missing
      print '__'
    end
    print ' '
  end
  puts ''
end

bed.each_with_index do |snps, i|
  p [i, snps]
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rbed'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rbed

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/rbed/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
