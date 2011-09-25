module StateMachine::AuditTrail::TransitionAuditing
  attr_accessor :transition_class_name, :user

  def store_audit_trail(options = {})
    state_machine = self
    state_machine.user = options[:user]
    state_machine.transition_class_name = (options[:to] || default_transition_class_name).to_s

    state_machine.after_transition do |object, transition|
      state_machine.audit_trail.log(object, state_machine.user, transition.event, transition.from, transition.to)
    end

    state_machine.owner_class.after_create do |object|
      if !object.send(state_machine.attribute).nil?
        state_machine.audit_trail.log(object, state_machine.user, nil, nil, object.send(state_machine.attribute))
      end
    end
  end

  def audit_trail
    @transition_auditor ||= StateMachine::AuditTrail.create(transition_class)
  end

  def user=(user)
    @user = user
  end

  def user
    @user
  end

  private

  def transition_class
    @transition_class ||= transition_class_name.constantize
  end

  def default_transition_class_name
    "#{owner_class.name}#{attribute.to_s.camelize}Transition"
  end
end
