module Test
  module Unit
    class TestCase
      
      class << self
        attr_accessor :current_testbed
        
        def testbed(string, &block)
          self.current_testbed = Testbed.new(string, block)
        end
        
        def verify_that(*arguments)
          Verifier.new(current_testbed, self, *arguments)
        end
        
        def define_test(verifier, testbed)
          define_method(testbed.method_name(*verifier.arguments)) do
            assert_equal(verifier.value, testbed.actual(self, *verifier.arguments))
          end
        end
        
      end
      
    end
    
    
    class Testbed

      attr_accessor :name, :block
      def initialize(name, block)
        @name = name
        @block = block
      end
      
      def method_name(*arguments)
        args = arguments.map do |each|
          if each.blank? then "blank_#{each.class}" else each.inspect end
        end
        "test_#{name.gsub(" ", "_")}_#{args.join('_')}".gsub('"', '')
      end
      
      def actual(inst, *arguments)
        block.bind(inst).call(*arguments)
      end

    end
    
    class Verifier
      
      attr_accessor :testbed, :arguments, :test_class, :value
      
      def initialize(testbed, test_class, *arguments)
        @testbed = testbed
        @test_class = test_class
        @arguments = arguments
      end
      
      def returns(value)
        @value = value
        test_class.define_test(self, testbed)
      end
      
      def is_true
        returns(true)
      end
      
      def is_false
        returns(false)
      end
      
    end
    
  end
end
  