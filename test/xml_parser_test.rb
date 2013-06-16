require 'test_helper'

class XmlParserTest < Test::Unit::TestCase
  context "simple graph: start event -> task -> task -> end event" do
    setup do
      xml = <<-XML
        <?xml version="1.0" encoding="MacRoman" standalone="yes"?>
        <definitions xmlns="http://www.omg.org/spec/BPMN/20100524/MODEL" xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI" xmlns:dc="http://www.omg.org/spec/DD/20100524/DC" xmlns:di="http://www.omg.org/spec/DD/20100524/DI" xmlns:tns="http://sourceforge.net/bpmn/definitions/_1370180922498" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:yaoqiang="http://bpmn.sourceforge.net" exporter="Yaoqiang BPMN Editor" exporterVersion="2.1.28" expressionLanguage="http://www.w3.org/1999/XPath" id="_1370180922498" name="" targetNamespace="http://sourceforge.net/bpmn/definitions/_1370180922498" typeLanguage="http://www.w3.org/2001/XMLSchema" xsi:schemaLocation="http://www.omg.org/spec/BPMN/20100524/MODEL http://bpmn.sourceforge.net/schemas/BPMN20.xsd">
          <process id="PROCESS_1" isClosed="false" isExecutable="true" processType="None">
            <startEvent id="_2" isInterrupting="true" name="Start Event" parallelMultiple="false">
              <outgoing>_6</outgoing>
            </startEvent>
            <task completionQuantity="1" id="_3" isForCompensation="false" name="Parse" startQuantity="1">
              <incoming>_6</incoming>
              <outgoing>_7</outgoing>
            </task>
            <task completionQuantity="1" id="_4" isForCompensation="false" name="Visualize" startQuantity="1">
              <incoming>_7</incoming>
              <outgoing>_8</outgoing>
            </task>
            <endEvent id="_5" name="End Event">
              <incoming>_8</incoming>
            </endEvent>
            <sequenceFlow id="_6" sourceRef="_2" targetRef="_3"/>
            <sequenceFlow id="_7" sourceRef="_3" targetRef="_4"/>
            <sequenceFlow id="_8" sourceRef="_4" targetRef="_5"/>
          </process>
          <bpmndi:BPMNDiagram documentation="background=#FFFFFF;count=1;horizontalcount=1;orientation=0;width=597.6;height=842.4;imageableWidth=587.6;imageableHeight=832.4;imageableX=5.0;imageableY=5.0" id="Yaoqiang_Diagram-_1" name="New Diagram">
            <bpmndi:BPMNPlane bpmnElement="PROCESS_1">
              <bpmndi:BPMNShape bpmnElement="_2" id="Yaoqiang-_2">
                <dc:Bounds height="32.0" width="32.0" x="101.0" y="161.0"/>
                <bpmndi:BPMNLabel>
                  <dc:Bounds height="32.0" width="32.0" x="0.0" y="0.0"/>
                </bpmndi:BPMNLabel>
              </bpmndi:BPMNShape>
              <bpmndi:BPMNShape bpmnElement="_3" id="Yaoqiang-_3">
                <dc:Bounds height="55.0" width="85.0" x="195.0" y="150.0"/>
                <bpmndi:BPMNLabel>
                  <dc:Bounds height="55.0" width="85.0" x="0.0" y="0.0"/>
                </bpmndi:BPMNLabel>
              </bpmndi:BPMNShape>
              <bpmndi:BPMNShape bpmnElement="_4" id="Yaoqiang-_4">
                <dc:Bounds height="55.0" width="85.0" x="330.0" y="150.0"/>
                <bpmndi:BPMNLabel>
                  <dc:Bounds height="55.0" width="85.0" x="0.0" y="0.0"/>
                </bpmndi:BPMNLabel>
              </bpmndi:BPMNShape>
              <bpmndi:BPMNShape bpmnElement="_5" id="Yaoqiang-_5">
                <dc:Bounds height="32.0" width="32.0" x="477.0" y="160.0"/>
                <bpmndi:BPMNLabel>
                  <dc:Bounds height="32.0" width="32.0" x="0.0" y="0.0"/>
                </bpmndi:BPMNLabel>
              </bpmndi:BPMNShape>
              <bpmndi:BPMNEdge bpmnElement="_8" id="Yaoqiang-_8" sourceElement="_4" targetElement="_5">
                <di:waypoint x="415.0" y="177.5"/>
                <di:waypoint x="477.0" y="176.0"/>
                <bpmndi:BPMNLabel>
                  <dc:Bounds height="0.0" width="0.0" x="0.0" y="0.0"/>
                </bpmndi:BPMNLabel>
              </bpmndi:BPMNEdge>
              <bpmndi:BPMNEdge bpmnElement="_7" id="Yaoqiang-_7" sourceElement="_3" targetElement="_4">
                <di:waypoint x="280.0" y="177.5"/>
                <di:waypoint x="330.0" y="177.5"/>
                <bpmndi:BPMNLabel>
                  <dc:Bounds height="0.0" width="0.0" x="0.0" y="0.0"/>
                </bpmndi:BPMNLabel>
              </bpmndi:BPMNEdge>
              <bpmndi:BPMNEdge bpmnElement="_6" id="Yaoqiang-_6" sourceElement="_2" targetElement="_3">
                <di:waypoint x="133.0" y="177.0"/>
                <di:waypoint x="195.0" y="177.5"/>
                <bpmndi:BPMNLabel>
                  <dc:Bounds height="0.0" width="0.0" x="0.0" y="0.0"/>
                </bpmndi:BPMNLabel>
              </bpmndi:BPMNEdge>
            </bpmndi:BPMNPlane>
          </bpmndi:BPMNDiagram>
        </definitions>
      XML

      @graph = Bpmn::Utilities::XmlParser.new(xml).parse
    end

    should "build connections between nodes" do
      connections = @graph.get_elements(type: :connector)

      assert_equal 3, connections.count
      assert_equal %w(_6 _7 _8), connections.map(&:ref_id)
      assert_equal %w(_2 _3 _4), connections.map { |c| c.start_node.ref_id }
      assert_equal %w(_3 _4 _5), connections.map { |c| c.end_node.ref_id }
    end

    should "define entry nodes" do
      entry_node = @graph.entry_nodes.first

      assert_equal 1, @graph.entry_nodes.count
      assert_equal Bpmn::Graph::StartEvent, entry_node.class
      assert_equal '_2', entry_node.ref_id
    end

    should "define end nodes" do
      end_node = @graph.end_nodes.first

      assert_equal 1, @graph.end_nodes.count
      assert_equal Bpmn::Graph::EndEvent, end_node.class
      assert_equal '_5', end_node.ref_id
    end

    should "extract graph's dimensions" do
      position = @graph.representation.position

      assert_equal 587.6, position[:height]
      assert_equal 832.4, position[:width]
    end

    should "place nodes in the right place" do
      # <dc:Bounds height="32.0" width="32.0" x="101.0" y="161.0"/>
      representation = @graph.lookup_element('_2', type: :node).representation
      assert_equal({ height: 32.0, width: 32.0, left: 101.0, top: 161.0 }, representation.position)
      assert_equal "Start Event", representation.name

      # <dc:Bounds height="55.0" width="85.0" x="195.0" y="150.0"/>
      representation = @graph.lookup_element('_3', type: :node).representation
      assert_equal({ height: 55.0, width: 85.0, left: 195.0, top: 150.0 }, representation.position)
      assert_equal "Parse", representation.name

      # etc.
    end
  end

  context "parse different elements" do
    should "create SubProcess with two tasks" do
      xml = <<-XML
        <definitions>
          <process>
            <subProcess completionQuantity="1" id="_3" isForCompensation="false" name="Sub-Process" startQuantity="1" triggeredByEvent="false">
              <task completionQuantity="1" id="_6" isForCompensation="false" name="A" startQuantity="1"/>
              <task completionQuantity="1" id="_7" isForCompensation="false" name="B" startQuantity="1"/>
            </subProcess>
          </process>
        </definitions>
      XML

      @graph = Bpmn::Utilities::XmlParser.new(xml).parse

      assert_equal 1, @graph.entry_nodes.count

      sub_process = @graph.entry_nodes.first

      assert_equal Bpmn::Graph::SubProcess, sub_process.class
      assert_nil sub_process.representation
      assert_equal %w(_6 _7), sub_process.entry_nodes.map(&:ref_id)
      assert_equal sub_process.entry_nodes, sub_process.end_nodes
    end
  end
end