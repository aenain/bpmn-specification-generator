$: << File.join(__dir__, 'lib')
require 'bpmn'

model_file = ARGV.first
rules_file = ARGV.count > 1 ? ARGV[1] : "config/rules.yml"

model = File.read(model_file)
rules = File.read(rules_file)

begin
  graph = Bpmn::Utilities::XmlParser.new(model).parse
  graph = Bpmn::Utilities::PatternExtractor.new(graph).extract
  rule_definitions = Bpmn::Utilities::RuleParser.new(rules).parse
  specification = Bpmn::Utilities::SpecificationGenerator.new(graph, rule_definitions).generate

  puts specification.to_s
rescue Bpmn::Specification::MissingSpecification, Bpmn::Utilities::PatternExtractor::NotFullyMatched => e
  puts e
end