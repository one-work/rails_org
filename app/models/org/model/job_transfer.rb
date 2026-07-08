module Org
  module Model::JobTransfer
    extend ActiveSupport::Concern

    included do
      attr_accessor :department_ancestors
      attribute :state, :string, default: 'init'
      attribute :transfer_on, :date
      attribute :reason_note, :string, limit: 4096

      belongs_to :member
      belongs_to :to_department, class_name: 'Department', optional: true
      belongs_to :to_job_title, class_name: 'JobTitle', optional: true
      belongs_to :from_department, class_name: 'Department', optional: true
      belongs_to :from_job_title, class_name: 'JobTitle', optional: true

      enum :state, {
        init: 'init',
        approved_sl: 'approved sl',
        approved_om: 'approved om',
        rejected: 'rejected'
      }

      validate :validate_select_option
      validates :transfer_on, :reason_note, presence: true

      after_initialize :init_from_member, if: :new_record?
      after_create_commit :send_notification
    end

    def init_from_member
      self.from_office_id = self.member&.office_id
      self.from_department_id = self.member&.department_id
      self.from_job_title_id = self.member&.job_title_id
      self.state = JobTransfer::states[:approved_sl] if self.member&.leading_department
    end

    def approve_config
      {
        approved_sl: member.department&.leader,
        approved_om: member.office&.leader
      }
    end

    def next_operator
      approve_config[next_state_state]
    end

    def next_state_state
      next_state_states.first
    end

    def next_state_states
      next_states(:state)
    end

    def do_trigger(params = {})
      self.trigger_to state: params[:state]

      self.class.transaction do
        self.save!
        to_notification(
          member: self.member,
          title: "Your Job Transfer request has been #{self.state_i18n}",
          body: "Your Job Transfer request has been #{self.state_i18n}.",
          link: url_helpers.my_job_transfers_url(id: self.id),
          cc_emails: cc_emails(self.member.email)
        )
        if self.approved_sl?
          send_notification
        elsif self.approved_om? && transfer_on <= Date.today
          member.update(department_id: self.to_department_id, office_id: self.to_office_id)
        end
      end
    end

    def send_notification
      to = next_operator
      to_notification(
        member: to,
        title: "#{self.member.name} has requested Job Transfer",
        body: "#{self.member.name} has requested Job Transfer.",
        code: self.state,
        link: url_helpers.my_admin_job_transfers_url
      )
    end

    def validate_select_option
      self.errors.add :base, 'Please select the office you want to' if self.to_office.nil?
      self.errors.add :base, 'Please select the department you want to' if self.to_department.nil?
    end

    def cc_emails(to)
      cc = [
        member.office.leader&.email,
        member.department.leader&.email,
        to_office.leader&.email,
        to_department.leader&.email,
        member.email
      ]
      cc.delete(to)
      cc.uniq.compact
    end

  end
end
