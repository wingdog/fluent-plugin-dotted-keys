require 'fluent/test'
require 'fluent/plugin/filter_dotted_keys'
require 'benchmark'

class BenchmarkDottedKeysFilter < Test::Unit::TestCase

  def setup
    Fluent::Test.setup
    @num_iterations = 10000
  end

  def driver(conf = '', tag = 'test.dottedkeys.tag', block = true)
    Fluent::Test::FilterTestDriver.new(Fluent::DottedKeysFilter, tag).configure(conf, block)
  end

  def sample_data
    {
      '4x0x0x0' => {
        'some_string' => 'string_value',
        'some_int' => 42,
        'some_float' => 1.5,
        'some_bool' => true
      },
      '2x2x2x1' => {
        'some_string' => 'string_value',
        'some_int' => 42,
        'some.float' => 1.5,
        'anot.bool' => true
      },
      '2x2x1x1' => {
        'some_string' => 'string_value',
        'some_int' => 42,
        'some.float' => 1.5,
        'some.bool' => true
      },
      '2x2x1x6' => {
        'some_string' => 'string_value',
        'some_int' => 42,
        'some.float' => 1.5,
        'some.really.deep.item.goes.here' => true
      }
    }

  end


  def test_benchmark_transform_methods

    Benchmark.bm() do |bm|
      instance = driver().instance

      sample_data.each do | key, record |
        bm.report("transform_v0_#{key}") {
          @num_iterations.times { instance.transform_v0( nil, nil, record ) }
        }

        bm.report("transform_v1_#{key}") {
          @num_iterations.times { instance.transform_v1( nil, nil, record ) }
        }

        bm.report("transform_v2_#{key}") {
          @num_iterations.times { instance.transform_v2( nil, nil, record ) }
        }
      end
    end

  end


end
