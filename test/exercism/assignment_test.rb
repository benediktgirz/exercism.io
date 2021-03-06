require './test/test_helper'

require 'yaml'
require 'pathname'
require 'exercism/named'
require 'exercism/exercise'
require 'exercism/assignment'

class AssignmentTest < MiniTest::Unit::TestCase

  attr_reader :assignment
  def setup
    @assignment = Assignment.new('fake', 'one', './test/fixtures')
  end

  def test_detect_filenames_ignoring_example_code
    assert_equal ['Fakefile', 'one_test.test'], assignment.filenames.sort
    # also: case insensitive
    obj_c = Assignment.new('objective-c', 'one', './test/fixtures/')
    assert_equal ["OneTest.m"], obj_c.filenames.sort
  end

  def test_detect_perl5_test_file
    one = Assignment.new('perl5', 'one', './test/fixtures')
    assert_equal 'one.t', one.test_file
  end

  def test_detect_files_all_the_way_down
    assignment = Assignment.new('scala', 'one', './test/fixtures')
    assert_equal ['build.sbt', 'src/test/scala/one_test.scala'].sort, assignment.filenames.sort
  end

  def test_load_testsuite
    tests = "assert 'one'\n"
    assert_equal tests, assignment.tests
  end

  def test_files
    expected = {
      "Fakefile" => "Autorun fake code\n",
      "one_test.test" => "assert 'one'\n",
      "README.md" => "THE README"
    }
    assignment.stub(:readme, "THE README") do
      assert_equal expected, assignment.files
    end
  end

  def test_sanity_check_scala_assignment
    assignment = Assignment.new('scala', 'one', './test/fixtures')
    tests = <<-END
import org.scalatest._

class OneTest extends FunSuite with Matchers {
  test ("one") {
    One.value should be (1)
  }
}
END

    build_sbt = <<-END
scalaVersion := "2.10.3"

libaryDependencies += "org.scalatest" %% "scalatest" % "2.0.RC3" % "test"
END
    expected = {
      "build.sbt" => build_sbt,
      "src/test/scala/one_test.scala" => tests,
      "README.md" => "THE README"
    }

    assignment.stub(:readme, "THE README") do
      assert_equal expected, assignment.files
    end
  end

  def test_testfile_is_case_insensitive
    objectivec_assignment = Assignment.new('objective-c', 'one', './test/fixtures/')
    assert_equal "OneTest.m", objectivec_assignment.test_file
    ruby_assignment = Assignment.new('ruby', 'two', './test/fixtures/')
    assert_equal "two_test.rb", ruby_assignment.test_file
  end
end

