module ManageIQ::Providers::Telefonica::CloudManager::Vm::Operations::Guest
  extend ActiveSupport::Concern

  included do
    supports :reboot_guest do
      unsupported_reason_add(:reboot_guest, unsupported_reason(:control)) unless supports_control?
      unsupported_reason_add(:reboot_guest, _("The VM is not powered on")) unless (current_state == "on")
    end

    supports :reset do
      unsupported_reason_add(:reset, unsupported_reason(:control)) unless supports_control?
      unsupported_reason_add(:reset, _("The VM is not powered on")) unless (current_state == "on")
    end

    supports :vm_destroy do
        unsupported_reason_add(:vm_destroy, unsupported_reason(:control)) unless supports_control?
        unsupported_reason_add(:vm_destroy, _("The VM can't be delete")) unless (current_state == "on") || (current_state == "off")
          if (current_state == "on") || (current_state == "off")
            raw_terminate
          end
      end

    supports :lock_guest do
        unsupported_reason_add(:lock_guest, unsupported_reason(:control)) unless supports_control?
        unsupported_reason_add(:lock_guest, _("The VM is not in on, off or unlocked")) unless (current_state == "on") || (current_state == "off")
        if (current_state == "on") || (current_state == "off")
          raw_lock_guest
        end
    end

    supports :unlock_guest do
      unsupported_reason_add(:unlock_guest, unsupported_reason(:control)) unless supports_control?
      unsupported_reason_add(:unlock_guest, _("The VM is not locked")) unless (current_state == "on") || (current_state == "off")
      if (current_state == "on") || (current_state == "off")
        raw_unlock_guest
      end
    end
end

  def raw_reboot_guest
    with_provider_object(&:reboot)
    # Temporarily update state for quick UI response until refresh comes along
    self.update_attributes!(:raw_power_state => "REBOOT")
  end

  def raw_reset
    with_provider_object { |instance| instance.reboot("HARD") }
    # Temporarily update state for quick UI response until refresh comes along
    self.update_attributes!(:raw_power_state => "HARD_REBOOT")
  end

  def raw_lock_guest
    with_provider_object(&:lock)
    # Temporarily update state for quick UI response until refresh comes along
  end

  def raw_unlock_guest
    with_provider_object(&:unlock)
    # Temporarily update state for quick UI response until refresh comes along
  end
end

