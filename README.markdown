# RDF::TriG reader/writer
[TriG][] reader/writer for [RDF.rb][RDF.rb] .

## Description
This is a [Ruby][] implementation of a [TriG][] reader and writer for [RDF.rb][].

## Features
RDF::TriG parses [TriG][Trig] into statements or quads. It also serializes to TriG.

Install with `gem install rdf-trig`

* 100% free and unencumbered [public domain](http://unlicense.org/) software.
* Implements a complete parser and serializer for [TriG][].
* Compatible with Ruby 1.8.7+, Ruby 1.9.x, and JRuby 1.4/1.5.

## Usage
Instantiate a reader from a local file:

    repo = RDF::Repository.load("etc/doap.trig", :format => :trig)

Define `@base` and `@prefix` definitions, and use for serialization using `:base_uri` an `:prefixes` options.

Canonicalize and validate using `:canonicalize` and `:validate` options.

Write a repository to a file:

    RDF::TriG::Writer.open("etc/test.trig") do |writer|
       writer << repo
    end

Note that reading and writing of graphs is also possible, but as graphs have only a single context,
it is not particularly interesting for TriG.

## Documentation
Full documentation available on [Rubydoc.info][TriG doc].

### Principle Classes
* {RDF::TriG::Format}
* {RDF::TriG::Reader}
* {RDF::TriG::Writer}

### Interpretations of the spec

It is still not defined what the interpretation of multiple uses of the same `graphIri` mean. This implementation takes
the use of multiple graphs having the same `graphIri` to be additive, meaning that the statements from each graph
are combined together to create a single graph.

Graphs are written with `context` set to the associated `graphIri`.

Although `RDF::Repository` allows any `RDF::Value`, such as a BNode, literal or variable to be used as a context, TriG
only allows the use of an IRI.

## Implementation Notes
The reader uses the [Turtle][Turtle doc] parser, which is based on the LL1::Parser with minor updates for the TriG grammar.
The writer also is based on the Turtle writer.
      
## Dependencies

* [Ruby](http://ruby-lang.org/) (>= 1.8.7) or (>= 1.8.1 with [Backports][])
* [RDF.rb](http://rubygems.org/gems/rdf) (>= 0.3.4)
* [rdf-turtle](http://rubygems.org/gems/rdf-turtle) (>= 0.1.1)

## Installation

The recommended installation method is via [RubyGems](http://rubygems.org/).
To install the latest official release of the `RDF::TriG` gem, do:

    % [sudo] gem install rdf-trig

## Mailing List
* <http://lists.w3.org/Archives/Public/public-rdf-ruby/>

## Author
* [Gregg Kellogg](http://github.com/gkellogg) - <http://kellogg-assoc.com/>

## Contributing
* Do your best to adhere to the existing coding conventions and idioms.
* Don't use hard tabs, and don't leave trailing whitespace on any line.
* Do document every method you add using [YARD][] annotations. Read the
  [tutorial][YARD-GS] or just look at the existing code for examples.
* Don't touch the `.gemspec`, `VERSION` or `AUTHORS` files. If you need to
  change them, do so on your private branch only.
* Do feel free to add yourself to the `CREDITS` file and the corresponding
  list in the the `README`. Alphabetical order applies.
* Do note that in order for us to merge any non-trivial changes (as a rule
  of thumb, additions larger than about 15 lines of code), we need an
  explicit [public domain dedication][PDD] on record from you.

## License
This is free and unencumbered public domain software. For more information,
see <http://unlicense.org/> or the accompanying {file:UNLICENSE} file.

[Ruby]:         http://ruby-lang.org/
[RDF]:          http://www.w3.org/RDF/
[YARD]:         http://yardoc.org/
[YARD-GS]:      http://rubydoc.info/docs/yard/file/docs/GettingStarted.md
[PDD]:          http://lists.w3.org/Archives/Public/public-rdf-ruby/2010May/0013.html
[RDF.rb]:       http://rubydoc.info/github/gkellogg/rdf/master/frames
[Backports]:    http://rubygems.org/gems/backports
[TriG]:         http://dvcs.w3.org/hg/rdf/raw-file/default/trig/
[TriG doc]:     http://rubydoc.info/github/gkellogg/rdf-trig/master/file/README.markdown
[TriG EBNF]:    http://dvcs.w3.org/hg/rdf/raw-file/default/trig/trig.bnf
[Turtle doc]:   http://rubydoc.info/github/gkellogg/rdf-turtle/master/file/README.markdown
