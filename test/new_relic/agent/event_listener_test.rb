require File.expand_path(File.join(File.dirname(__FILE__),'..','..','test_helper'))

class EventListenerTest < Test::Unit::TestCase

  def setup
    @events = NewRelic::Agent::EventListener.new

    @called = false
    @called_with = nil

    @check_method = Proc.new do |*args|
      @called = true
      @called_with = args
    end
  end

  def test_notifies
    @events.subscribe(:before_call, &@check_method)
    @events.notify(:before_call, :env => "env")

    assert_was_called
    assert_equal([{:env => "env"}], @called_with)
  end

  def test_failure_during_notify_doesnt_block_other_hooks
    @events.subscribe(:after_call) { raise "Boo!" }
    @events.subscribe(:after_call, &@check_method)

    @events.notify(:after_call)

    assert_was_called
  end

  def test_runaway_events
    @events.runaway_threshold = 0
    expects_logging(:debug, includes("my_event"))
    @events.subscribe(:my_event) {}
  end


  def assert_was_called
    assert @called, "Event wasn't called"
  end

end

