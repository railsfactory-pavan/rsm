class Event < ApplicationRecord

  include AASM

  aasm :column => 'state' do
    state :sleeping, :initial => true
  end
end
