class StateMachine::AuditTrail::ActiveRecord < StateMachine::AuditTrail::Backend
  def log(object, user, event, from, to, timestamp = Time.now)
    # Let ActiveRecord manage the timestamp for us so it does the 
    # right thing with regards to timezones.
    transition_class.create(foreign_key_field(object) => object.id, :user => user, :event => event, :from => from, :to => to)
  end

  def foreign_key_field(object)
    object.class.base_class.name.foreign_key.to_sym
  end
end
