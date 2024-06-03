# frozen_string_literal: true

require 'rails/railtie'

module Bp3
  module Actiontext
    class Railtie < Rails::Railtie
      initializer 'bp3.actiontext.railtie.register' do |app|
        app.config.after_initialize do
          ::ActionText::RichText # preload
          module ::ActionText
            class RichText
              include Bp3::Core::Rqid
              include Bp3::Core::Sqnr
              include Bp3::Core::Tenantable
              include Bp3::Core::Ransackable

              configure_tenancy
              use_sqnr_for_ordering
              has_paper_trail

              validates :name, uniqueness: { scope: %w[sites_site_id record_type record_id locale] }

              private

              # override Tenantable#set_sites_site_id to use the parent record, if available
              def set_sites_site_id
                self.sites_site_id = if record.is_a?(Bp3::Actiontext.site_class)
                                       record.id
                                     elsif record.respond_to?(:sites_site_id)
                                       record.sites_site_id
                                     end
                return if sites_site_id.present?

                super
              end

              # override Tenantable#set_tenant_id to use the parent record, if available
              def set_tenant_id
                self.tenant_id = if record.is_a?(Bp3::Actiontext.tenant_class)
                                   record.id
                                 elsif record.respond_to?(:tenant_id)
                                   record.tenant_id
                                 end
                return if tenant_id.present?

                super
              end

              # override Tenantable#set_workspaces_workspace_id to use the parent record, if available
              def set_workspaces_workspace_id
                self.workspaces_workspace_id = if record.is_a?(Bp3::Actiontext.workspace_class)
                                                 record.id
                                               elsif record.respond_to?(:workspaces_workspace_id)
                                                 record.workspaces_workspace_id
                                               end
                return if workspaces_workspace_id.present?

                super
              end
            end
          end
        end
      end
    end
  end
end
