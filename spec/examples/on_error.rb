class OnError
  include DataMapper::Resource

  property :id, Serial # see note 1

  is :state_machine, :initial => :red, :column => :state do
    state :red
    state :starting, :enter => :on_starting
    state :green,    :enter => Proc.new { |o| o.log << "G" }
    state :stopping, :enter => :on_stopping

    state :starting_failed
    state :stopping_failed

    event :go do
      transition :from => :red, :via => :starting, :to => :green, :error => :starting_failed
      transition :from => :green, :via => :stopping, :to => :red, :error => :stopping_failed
    end

    event :retry do
      transition :from => :starting_failed, :via => :starting, :to => :green, :error => :starting_failed
      transition :from => :stopping_failed, :via => :stopping, :to => :red, :error => :stopping_failed
    end
  end

  #before :on_error, :log_error

  def log_error
    log << @state_machine_error
  end

  def log; @log ||= [] end

  attr_reader :init
  def initialize(*args)
    (@init ||= []) << :init
    super
  end

  def on_starting
    unless log.include?(:raised)
      log << :raised
      raise "I'm an error!"
    end
  end

  def on_stopping
    # noop
  end
end

OnError.auto_migrate!

