class Event < ApplicationRecord
  attr_accessor :on_run, :on_stop, :time_used

  include AASM

  aasm :column => 'state' do
    state :sleeped, initial: true, :after_enter => [:notify_user, :not_in_database]
    state :on_run, before_enter: Proc.new { notify_user && lived_in_database }, :guard => :run_day_whole?
    state :drafted, :after_enter => :lived_in_database
    state :published, :after_enter => :saved_in_database
    state :unpublished, :after_enter => :not_in_database
    state :archived, :after_enter => :saved_in_database

    after_all_transitions :log_status_all_transitions

    event :whole_day do
      transitions :from => :sleeped, :to => :on_run do
        guard do
          run_day_whole?
        end
      end
    end

    event :stop_if_not_whole_day do
      transitions :from => :sleeped, :to => :on_run, :guard => :not_whole_day?
    end

    event :on_run, :after => :notify_user do
      before do
        log('Preparing to run')
      end
      transitions from: [:sleeping], to: :on_run, :after => Proc.new {|*args| set_process(*args) }
    end

    event :draft, :after => :notify_user do
      transitions from: [:on_run], to: :drafted
    end

    event :publish, :after => :notify_user do
      transitions from: [:drafted], to: :published
    end

    event :unpublish, :after => :notify_user do
      transitions from: [:published], to: :on_run
    end

    event :archive, :after => :notify_user do
      transitions from: [:published, :on_run, :sleeped], to: :archived
    end
  end

  def log_status_all_transitions
    puts "changing from #{aasm.from_state} to #{aasm.to_state} (event: #{aasm.current_event})"
  end

  def log_status_running
    @on_run = true
    puts "changing from #{aasm.from_state} to #{aasm.to_state} (event: #{aasm.current_event})"
  end

  def log_status_drafting
    @on_run = true
    puts "changing from #{aasm.from_state} to #{aasm.to_state} (event: #{aasm.current_event})"
  end

  def log_status_publishing
    @on_run = true
    puts "changing from #{aasm.from_state} to #{aasm.to_state} (event: #{aasm.current_event})"
  end

  def set_process(name)
    logger.info "from #{aasm.from_state} to #{aasm.to_state}"
  end

  def not_in_database
    @on_stop = true
    puts "triggered #{aasm.current_event}"
  end

  def lived_in_database
    @on_run = true
    puts "#{aasm.current_event} lived in database"
  end

  def notify_user
    puts "notify #{aasm.current_event}"
  end

  def saved_in_database
    puts "saved in database #{aasm.current_event}"
  end

  def set_process(name)
    logger.info "seting process #{aasm.from_state} to #{aasm.to_state}"
  end

  def run_day_whole?
    false
  end

  def not_whole_day?(status)
    status == :all_day
  end

  def duration_event
   start = Time.now
   block.call
   event.time_used += Time.now - start
 end
end

class LogRunTime
  def initialize(event, args = {})
    @event = job
  end
  def call
    log "Job was running for #{x} seconds"
  end
end

class EvnetActivity
  def call
    run_day_whole? && unless not_whole_day?
    end
  end
end
