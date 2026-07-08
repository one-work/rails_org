module Org
  module Model::Resign
    extend ActiveSupport::Concern

    included do
      attribute :leave_on, :date
      attribute :reason_note, :string
      attribute :handover_note, :string
      attribute :comment, :string

      validates :leave_on, :reason_note, presence: true
      validate :validate_resign_reasons

      belongs_to :member
      has_many :resign_references
      has_many :resign_reasons, through: :resign_references

      enum :state, {
        init: 'init',
        approved: 'approved',
        rejected: 'rejected'
      }, default: 'init'

      after_create_commit :send_notification
    end

    def do_trigger(params = {})
      self.trigger_to(params.slice(:state))

      self.class.transaction do
        self.save!
        to_notification(
          sender: self.member.office.leader,
          member: self.member,
          title: "Your resignation request has been #{self.state_i18n}.",
          body: "Your resignation request has been #{self.state_i18n}.",
          link: Rails.app.url_for(controller: 'org/my/resigns', action: 'show', id: id),
          cc_emails: [
            self.member.office.leader.email
          ],
        )
      end
    end

    def send_notification
      to_notification(
        sender: self.member,
        member: self.member.office.leader,
        body: "#{self.member.name} has requested resignation",
        title: "#{self.member.name} has requested resignation",
        cc_emails: [
          self.member.email
        ],
        link: Rails.app.url_for(controller: 'org/admin/resigns', action: 'show', id: id),
        verbose: true
      )
    end

    def validate_resign_reasons
      self.errors.add :base, 'Please select one reason at least' if self.resign_reasons.empty?
    end

  end
end
