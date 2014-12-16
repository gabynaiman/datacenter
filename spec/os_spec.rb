require 'minitest_helper'

describe Datacenter::OS do

  let(:os) { Datacenter::OS.new mock_shell }

  it ('Name') { os.name.must_equal 'GNU/Linux' }
  
  it ('Distribution') { os.distribution.must_equal 'Ubuntu' }
  
  it ('Version') { os.version.must_equal '12.04' }
  
  it ('Kernel') { os.kernel.must_equal '3.5.0-49-generic' }
  
  it ('Platform') { os.platform.must_equal 'x86_64' }

end
