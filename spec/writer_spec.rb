$:.unshift "."
require 'spec_helper'
require 'rdf/spec/writer'

describe RDF::TriG::Writer do
  before(:each) do
    @writer = RDF::TriG::Writer.new(StringIO.new)
  end
  
  it_should_behave_like RDF_Writer

  # XXX This should work for Ruby 1.8, but don't have time to investigate further right now
  describe ".for" do
    formats = [
      :trig,
      'etc/doap.trig',
      {:file_name      => 'etc/doap.trig'},
      {:file_extension => 'trig'},
      {:content_type   => 'application/trig'},
    ].each do |arg|
      it "discovers with #{arg.inspect}" do
        RDF::Writer.for(arg).should == RDF::TriG::Writer
      end
    end
  end

  describe "simple tests" do
    it "should use full URIs without base" do
      input = %({<http://a/b> <http://a/c> <http://a/d> .})
      serialize(input, nil, [%r(\{\s*<http://a/b> <http://a/c> <http://a/d> \.\s*\}$)m])
    end

    it "should use relative URIs with base" do
      input = %({<http://a/b> <http://a/c> <http://a/d> .})
      serialize(input, "http://a/",
       [ %r(^@base <http://a/> \.$),
        %r(^\{\s*<b> <c> <d> \.\s*\}$)m]
      )
    end

    it "should use pname URIs with prefix" do
      input = %({<http://xmlns.com/foaf/0.1/b> <http://xmlns.com/foaf/0.1/c> <http://xmlns.com/foaf/0.1/d> .})
      serialize(input, nil,
        [%r(^@prefix foaf: <http://xmlns.com/foaf/0.1/> \.$),
        %r(^\{\s*foaf:b foaf:c foaf:d \.$\s*\})m],
        :prefixes => { :foaf => RDF::FOAF}
      )
    end

    it "should use pname URIs with empty prefix" do
      input = %({<http://xmlns.com/foaf/0.1/b> <http://xmlns.com/foaf/0.1/c> <http://xmlns.com/foaf/0.1/d> .})
      serialize(input, nil,
        [%r(^@prefix : <http://xmlns.com/foaf/0.1/> \.$),
        %r(^\{\s*:b :c :d \.$\s*\})m],
        :prefixes => { "" => RDF::FOAF}
      )
    end
    
    # see example-files/arnau-registered-vocab.rb
    it "should use pname URIs with empty suffix" do
      input = %({<http://xmlns.com/foaf/0.1/> <http://xmlns.com/foaf/0.1/> <http://xmlns.com/foaf/0.1/> .})
      serialize(input, nil,
        [%r(^@prefix foaf: <http://xmlns.com/foaf/0.1/> \.$),
        %r(^\{\s*foaf: foaf: foaf: \.\s*\}$)m],
        :prefixes => { "foaf" => RDF::FOAF}
      )
    end
    
    it "should order properties" do
      input = %(
        @prefix : <http://xmlns.com/foaf/0.1/> .
        @prefix dc: <http://purl.org/dc/elements/1.1/> .
        @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
        {
          :b :c :d .
          :b dc:title "title" .
          :b a :class .
          :b rdfs:label "label" .
        }
      )
      serialize(input, nil,
        [
          %r(^\{\s*:b)m,
          %r(^\s+:b a :class;$)m,
          %r(\s+:class;\s+rdfs:label "label";)m,
          %r(\s+"label";\s+dc:title "title";)m,
          %r(\s+"title";\s+:c :d \.\s*\}$)m
        ],
        :prefixes => { "" => RDF::FOAF, :dc => "http://purl.org/dc/elements/1.1/", :rdfs => RDF::RDFS}
      )
    end
    
    it "should generate object list" do
      input = %(@prefix : <http://xmlns.com/foaf/0.1/> . {:b :c :d, :e .})
      serialize(input, nil,
        [
          %r(^@prefix : <http://xmlns.com/foaf/0.1/> \.$),
          %r(^\{\s*:b)m,
          %r(^\s+:b :c :d,$),
          %r(^\s+:e \.$)
        ],
        :prefixes => { "" => RDF::FOAF}
      )
    end
    
    it "should generate property list" do
      input = %(@prefix : <http://xmlns.com/foaf/0.1/> . {:b :c :d; :e :f .})
      serialize(input, nil,
        [
          %r(^@prefix : <http://xmlns.com/foaf/0.1/> \.$),
          %r(^\{\s+:b :c :d;$)m,
          %r(:d;\s+:e :f \.)m,
          %r(:f \.\s+\}$)m,
        ],
        :prefixes => { "" => RDF::FOAF}
      )
    end
  end

  context "Named Graphs" do
    {
      "default" => [
        %q({<a> <b> <c> .}),
        [
          %r(\{\s*<a> <b> <c> .\s*\})m
        ]
      ],
      "named" => [
        %q(<C> {<a> <b> <c> .}),
        [
          %r(<C> \{\s*<a> <b> <c> .\s*\})m
        ]
      ],
      "combo" => [
        %q(
          {<a> <b> <c> .}
          <C> {<A> <b> <c> .}
        ),
        [
          %r(^\{\s*<a> <b> <c> .\s*\})m,
          %r(^<C> \{\s*<A> <b> <c> .\s*\})m
        ]
      ],
      "combo with duplicated statement" => [
        %q(
          {<a> <b> <c> .}
          <C> {<a> <b> <c> .}
        ),
        [
          %r(^\{\s*<a> <b> <c> .\s*\})m,
          %r(^<C> \{\s*<a> <b> <c> .\s*\})m
        ]
      ],
    }.each_pair do |title, (input, matches)|
      it title do
        serialize(input, nil, matches)
      end
    end
  end

  def parse(input, options = {})
    graph = RDF::Repository.new
    RDF::TriG::Reader.new(input, options).each do |statement|
      graph << statement
    end
    graph
  end

  # Serialize ntstr to a string and compare against regexps
  def serialize(ntstr, base = nil, regexps = [], options = {})
    prefixes = options[:prefixes] || {}
    g = parse(ntstr, :base_uri => base, :prefixes => prefixes)
    @debug = []
    result = RDF::TriG::Writer.buffer(options.merge(:debug => @debug, :base_uri => base, :prefixes => prefixes)) do |writer|
      writer << g
    end
    if $verbose
      require 'cgi'
      #puts CGI.escapeHTML(result)
    end
    
    regexps.each do |re|
      result.should match_re(re, :about => base, :trace => @debug, :inputDocument => ntstr)
    end
    
    result
  end
end