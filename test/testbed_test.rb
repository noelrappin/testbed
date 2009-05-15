require 'test/unit'
require File.dirname(__FILE__) + '/../lib/testbed'
class TestbedTest < Test::Unit::TestCase
  
  class FakeTestA < Test::Unit::TestCase 
    def test_something; true end
  end
  
  class FakeTestB < Test::Unit::TestCase 
    def test_something; true end
  end
  
  def assert_test_run(method, error_count, failure_count, run_count, assertion_count)
    test = FakeTestA.new(method)
    runner = Test::Unit::UI::Console::TestRunner.new(test, 0)
    result = runner.start
    assert_equal(error_count, result.error_count)
    assert_equal(failure_count, result.failure_count)
    assert_equal(run_count, result.run_count)
    assert_equal(assertion_count, result.assertion_count)
    passed = error_count == 0 && failure_count == 0
    assert_equal(passed, result.passed?)  
  end
  
  def test_creating_a_testbed 
    FakeTestA.testbed("this is a fake testbed"){ |a| a * 2 }
    assert_equal("this is a fake testbed", FakeTestA.current_testbed.name)
    assert_equal(4, FakeTestA.current_testbed.block.call(2))
    FakeTestB.testbed("a different fake testbed") { |a| a * 3 }
    assert_equal("a different fake testbed", FakeTestB.current_testbed.name)
    assert_equal(6, FakeTestB.current_testbed.block.call(2))
    assert_equal("this is a fake testbed", FakeTestA.current_testbed.name)
    assert_equal(4, FakeTestA.current_testbed.block.call(2))
  end
  
  def test_creating_a_verification
    FakeTestA.testbed("this is a fake testbed"){ |a| a * 2 }
    verifier = FakeTestA.verify_that(1)
    assert_equal(FakeTestA, verifier.test_class)
    assert_equal([1], verifier.arguments)
    assert_equal(:test_this_is_a_fake_testbed_1, verifier.testbed.method_name(1))
  end
  
  def test_makes_return_successful
    FakeTestA.testbed("this is a fake testbed"){ |a| a * 2 }
    verifier = FakeTestA.verify_that(1)
    verifier.returns(2)
    assert FakeTestA.public_method_defined?(:test_this_is_a_fake_testbed_1)
    assert_test_run(:test_this_is_a_fake_testbed_1, 0, 0, 1, 1)
  end
  
  def test_makes_return_unsuccessful
    FakeTestA.testbed("this is a fake testbed"){ |a| a * 2 }
    verifier = FakeTestA.verify_that(1)
    verifier.returns(3)
    assert FakeTestA.public_method_defined?(:test_this_is_a_fake_testbed_1)
    assert_test_run(:test_this_is_a_fake_testbed_1, 0, 1, 1, 1)
  end
  
  def test_two_methods
    FakeTestA.testbed("this is a fake testbed"){ |a| a * 2 }
    verifier = FakeTestA.verify_that(1)
    verifier.returns(2)
    verifier = FakeTestA.verify_that(2)
    verifier.returns(2)
    assert_test_run(:test_this_is_a_fake_testbed_1, 0, 0, 1, 1)
    assert_test_run(:test_this_is_a_fake_testbed_2, 0, 1, 1, 1)
  end
    
end
