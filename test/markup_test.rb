$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'murlsh'

require 'test/unit'

class MarkupTest < Test::Unit::TestCase

  def attr_check(name, value, s)
    assert_match(/#{name}="#{value}"/, s)
  end

  def test_javascript_single
    m = Murlsh::Markup.new()
    m.javascript('test.js')
    assert_equal(
      '<script type="text/javascript" src="test.js"></script>', m.target!)
  end

  def test_javascript_multiple
    m = Murlsh::Markup.new()
    m.javascript(['test1.js', 'test2.js'])
    assert_equal(
        '<script type="text/javascript" src="test1.js"></script><script type="text/javascript" src="test2.js"></script>',
      m.target!)
  end

  def test_javascript_single_prefix
    m = Murlsh::Markup.new()
    m.javascript('test.js', :prefix => 'http://static.com/js/')
    assert_equal(
      '<script type="text/javascript" src="http://static.com/js/test.js"></script>',
      m.target!)
  end

  def test_javascript_multiple_prefix
    m = Murlsh::Markup.new()
    m.javascript(['test1.js', 'test2.js'], :prefix => 'js/')
    assert_equal(
        '<script type="text/javascript" src="js/test1.js"></script><script type="text/javascript" src="js/test2.js"></script>',
      m.target!)
  end

  def test_murlsh_img_prefix
    m = Murlsh::Markup.new()
    m.murlsh_img(:src => 'foo.png', :prefix => 'http://static.com/img/')
    assert_equal('<img src="http://static.com/img/foo.png"/>', m.target!)
  end

  def test_murlsh_img_size_one
    m = Murlsh::Markup.new()
    m.murlsh_img(:src => 'foo.png', :size => 32)
    [
      %w{height 32},
      %w{src foo.png},
      %w{width 32},
    ].each { |t| attr_check(*t.push(m.target!)) }
  end

  def test_murlsh_img_size_two
    m = Murlsh::Markup.new()
    m.murlsh_img(:src => 'foo.png', :size => [100, 200])
    [
      %w{height 200},
      %w{src foo.png},
      %w{width 100},
    ].each { |t| attr_check(*t.push(m.target!)) }
  end

  def test_murlsh_img_size_text
    m = Murlsh::Markup.new()
    m.murlsh_img(:src => 'foo.png', :text => 'test')
    [
      %w{alt test},
      %w{src foo.png},
      %w{title test},
    ].each { |t| attr_check(*t.push(m.target!)) }
  end

end