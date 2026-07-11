module Org
  module Model::Tutorial
    extend ActiveSupport::Concern

    included do
      attribute :state, :string, default: 'init'
      attribute :accepted_status, :string, default: 'normal'
      attribute :verified, :string, default: 'unverified'
      attribute :kind, :string
      attribute :start_on, :date
      attribute :finish_on, :date
      attribute :performance, :string
      attribute :allowance, :integer
      attribute :note, :string, limit: 4096
      attribute :comment, :string, limit: 4096

      belongs_to :member
      belongs_to :tutor, class_name: 'Member', optional: true

      after_initialize if: :new_record? do
        self.state ||= 'init'
        self.start_on ||= self.member&.join_on
      end
      before_save :compute_finish_on, if: -> { start_on_changed? }

      validates :tutor_id, uniqueness: { scope: [:member_id, :kind] }
      #validates :kind, presence: true

      enum :kind, {
        interning: 'interning',
        probation: 'probation',
        probation_2: 'probation_2'
      }

      enum :state, {
        init: 'pending',
        accepted: 'approved',
        rejected: 'rejected'
      }
      enum :accepted_status, {
        very_advance: 'very_advance',
        advance: 'advance',
        normal: 'normal',
        overdue: 'overdue',
        very_overdue: 'very_overdue'
      }
      enum :verified, {
        unverified: 'unverified',
        superior_approved: 'superior_approved',
        admin_approved: 'hr_approved',
        md_approved: 'md_approved'
      }
    end

    def compute_finish_on
      if self.start_on && self.kind == 'interning'
        self.finish_on ||= self.start_on.after(6.months)
      elsif self.start_on
        self.finish_on ||= self.start_on.after(3.months)
      end
    end

  end
end
