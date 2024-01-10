# frozen_string_literal: true

require 'rails/railtie'

module Bp3
  module Actiontext
    class Railtie < Rails::Railtie
      initializer 'bp3.actiontext.railtie.register' do |app|
        app.config.after_initialize do # preload
          module ::ActionText
            class RichText
              include Bp3::Core::Rqid
              include Bp3::Core::Sqnr
              include Bp3::Core::Tenantable
              include Bp3::Core::Ransackable

              configure_tenancy
              use_sqnr_for_ordering
              has_paper_trail

              belongs_to :tenant, optional: true
              belongs_to :workspaces_workspace, class_name: 'Workspaces::Workspace', optional: true

              validates :name, uniqueness: { scope: %w[sites_site_id record_type record_id locale] }

              private

              # override SiteScoped method to use the parent record, if it *is* a site, or
              # if it *has* a site
              def set_sites_site_id
                self.sites_site_id = if record.is_a?(Sites::Site)
                                       record.id
                                     elsif record.respond_to?(:sites_site_id)
                                       record.sites_site_id
                                     end
                return if sites_site_id.present?

                super
              end
            end
          end
        end
      end
    end
  end
end
