require 'fluent/test'
require 'fluent/plugin/filter_dotted_keys'


class DottedKeysFilter < Test::Unit::TestCase

  def setup
    Fluent::Test.setup
  end

  def driver(conf = '', tag = 'test.dottedkeys.tag', block = true)
    Fluent::Test::FilterTestDriver.new(Fluent::DottedKeysFilter, tag).configure(conf, block)
  end

  def sample_data
    [
      {
        'input' => {
          'a1' => 'a',
          'b' => 'b',
          'c' => 'c'
        },
        'output' => {
          'a1' => 'a',
          'b' => 'b',
          'c' => 'c'
        }
      },
      {
        'input' => {
          'a2' => 'a',
          'b.a' => 'b.a',
          'b.b' => 'b.b'
        },
        'output' => {
          'a2' => 'a',
          'b' => {'a' =>'b.a', 'b' => 'b.b'}
        }
      },
      {
        'input' => {
          'a2a' => 'a2a',
          'b.a' => 'b.a',
          'b.b' => 'b.b',
          'c.a.b.c.d' => 'c.a.b.c.d',
          'c.a.b.c.e' => 'c.a.b.c.e'
        },
        'output' => {
          'a2a' => 'a2a',
          'b' => {'a' =>'b.a', 'b' => 'b.b'},
          'c' => {'a' => {'b' => {'c' => {'d' => 'c.a.b.c.d', 'e' => 'c.a.b.c.e'}}}}
        }
      },
      # {
      #   'input' => {
      #     'a3.b.c.d' => 'a3.b.c.d',
      #     'a3.b' => 'a3.b'
      #   },
      #   'output' => {
      #     'a3' => {'b' => 'a3.b'}
      #   }
      # },
      # {
      #   'input' => {
      #     'a4.b' => 'a4.b',
      #     'a4.b.c.d' => 'a4.b.c.d'
      #   },
      #   'output' => {
      #     'a4' => {'b' => {'c' => {'d' => 'a4.b.c.d'}}}
      #   }
      # },
      {
        'input' => {
          'a5' => {'b' => {'c' => 'a5.b.c'}},
          'a5.b.d.e' => 'a5.b.d.e'
        },
        'output' => {
          'a5' => {'b' => {'c' => 'a5.b.c', 'd' => {'e' => 'a5.b.d.e'}}}
        }
      }
    ]
  end


  def test_configure_defaults
    instance = driver().instance

    assert_equal nil, instance.example_string
    assert_equal false, instance.example_bool
    assert_equal 1, instance.example_integer
  end

  def test_configure_1
    config = %{
      example_string     my_string
      example_bool       false
      example_integer    1234
    }
    instance = driver(config).instance

    assert_equal 'my_string', instance.example_string
    assert_equal false, instance.example_bool
    assert_equal 1234, instance.example_integer
  end

  def test_configure_2
    config = %{
      example_string     another_string
      example_bool       true
      example_integer    0
    }
    instance = driver(config).instance

    assert_equal 'another_string', instance.example_string
    assert_equal true, instance.example_bool
    assert_equal 0, instance.example_integer
  end


  def test_filter_sample_data
    sample_data.each do |item|
      input = item['input']
      output = item['output']

      d = driver()
      begin
        d.emit(input)
        d.run
      rescue ArgumentError => e
        print "Caught an ArgumentError: " + e
        print input
        continue
      end
      records = d.emits
      tag, ts, record = records[0]
      assert_equal(output, record)
    end

    # if you want to iterate through the records, you can also:
    # d.filtered.each { |time, record|
    #   assert_equal(some, comparison)
    # }

  end


end
