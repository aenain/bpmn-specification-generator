$: << File.join(__dir__, 'lib')
require 'bpmn'

xml = File.read(ARGV.first)
graph = Bpmn::Utilities::XmlParser.new(xml).parse
graph = Bpmn::Utilities::PatternExtractor.new(graph).extract
specification = Bpmn::Utilities::SpecificationGenerator.new(graph).generate

puts specification.to_s