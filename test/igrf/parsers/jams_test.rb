require "test_helper"
require "igrf/parsers/jams"

describe IGRF::Parsers::Jams do
  subject { IGRF::Parsers::Jams }

  before do
    @parser = subject.new(Support::IGRF.workbook)
    @parser.parse

    @jam = @parser.parsed.first
  end

  it "parses an IGRF workbook for the Jams" do
    assert_equal true, @jam[:away]
    assert_equal 1, @jam[:number]
    assert_equal 1, @jam[:period]

    assert_kind_of Array, @jam[:passes]
  end
end