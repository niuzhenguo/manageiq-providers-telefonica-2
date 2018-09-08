class ManageIQ::Providers::Telefonica::CloudManager::CloudTenant < ::CloudTenant
  include ManageIQ::Providers::Telefonica::HelperMethods
  has_and_belongs_to_many :miq_templates,
                          :foreign_key             => "cloud_tenant_id",
                          :join_table              => "cloud_tenants_vms",
                          :association_foreign_key => "vm_id",
                          :class_name              => "ManageIQ::Providers::Telefonica::CloudManager::Template"

  has_many :private_networks,
           :class_name => "ManageIQ::Providers::Telefonica::NetworkManager::CloudNetwork::Private"

  def self.raw_create_cloud_tenant(ext_management_system, options)
    tenant = nil
    ext_management_system.with_provider_connection(connection_options) do |service|
      tenant = service.create_tenant(options)
    end
    {:ems_ref => tenant.id, :name => options[:name]}
  rescue => e
    _log.error "tenant=[#{options[:name]}], error: #{e}"
    raise MiqException::MiqCloudTenantCreateError, parse_error_message_from_fog_response(e), e.backtrace
  end

  def raw_update_cloud_tenant(options)
    ext_management_system.with_provider_connection(connection_options) do |service|
      service.update_tenant(ems_ref, options)
    end
  rescue => e
    _log.error "tenant=[#{name}], error: #{e}"
    raise MiqException::MiqCloudTenantUpdateError, parse_error_message_from_fog_response(e), e.backtrace
  end

  def raw_delete_cloud_tenant
    with_notification(:cloud_tenant_delete, :options => {:subject => self}) do
      ext_management_system.with_provider_connection(connection_options) do |service|
        service.delete_tenant(ems_ref)
      end
    end
  rescue => e
    _log.error "tenant=[#{name}], error: #{e}"
    raise MiqException::MiqCloudTenantDeleteError, parse_error_message_from_fog_response(e), e.backtrace
  end

  def self.connection_options
    connection_options = {:service => "Identity", :telefonica_endpoint_type => 'adminURL'}
    connection_options
  end

  def self.display_name(number = 1)
    n_('Cloud Tenant (Telefonica)', 'Cloud Tenants (Telefonica)', number)
  end

  private

  def connection_options
    self.class.connection_options
  end
  private :connection_options
end
