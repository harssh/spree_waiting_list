module Spree
  class StockRequest < ActiveRecord::Base
    belongs_to :product
    belongs_to :variant

    validates :email, :presence => true,
              :format => {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i}

    default_scope { order('created_at desc') }

    scope :notified, lambda { |is_notified| where(:status => is_notified ? 'notified' : 'new') }
    scope :without_variant, -> { where(:variant_id => nil) }

    state_machine :status, :initial => 'new' do
      event :notify do
        transition :from => 'new', :to => 'notified'
      end

      after_transition :to => 'notified', :do => :send_email
    end

    private

    def send_email
      UserMailer.back_in_stock(self).deliver
    end

  end
end
