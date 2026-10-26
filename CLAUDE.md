# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

bp3-actiontext adapts `actiontext` for BP3 (persuavis/black_phoebe_3), a multi-site multi-tenant Rails
application. It makes `ActionText::RichText` a BP3 record: request-tracked, sequenced, tenant-scoped,
searchable and audited.

## Commands

The gems run on Ruby 3.4.6 (`.ruby-version`). Prefix commands with `~/.rvm/bin/rvm 3.4.6 do` when the
shell is not already on it; a missing `rspec` means the wrong Ruby, not a missing bundle.

- `bundle exec rake` - specs and RuboCop (the default task)
- `bundle exec rspec spec/path/to/file_spec.rb[:LINE]` - one file or example
- `bundle exec rubocop` / `bundle exec rubocop -a`
- `bin/setup`, `bin/console`, `rake install`

## Architecture

`lib/bp3/actiontext/railtie.rb` reopens `ActionText::RichText` in an `after_initialize` block and:

- includes `Bp3::Core::Rqid`, `Sqnr`, `Tenantable` and `Ransackable` (gem bp3-core), then calls
  `configure_tenancy` and `use_sqnr_for_ordering`
- calls `has_paper_trail`, so the application must have paper_trail loaded
- validates `name` unique per `sites_site_id`, `record_type`, `record_id` and `locale` (Mobility stores one
  rich text per locale)
- overrides `Tenantable#set_sites_site_id` to take the site from the parent record: the record itself when
  it is a site, else its `sites_site_id`, falling back to the request state only when neither gives one
- overrides `Tenantable#set_tenant_id` the same way but never falls back to the request state: tenant is
  optional for rich text, and a request's tenant is not necessarily the record's

**Configuration** (`lib/bp3/actiontext.rb`): `Bp3::Actiontext.site_class_name`, `.tenant_class_name` and
`.workspace_class_name`, set in the application's `config/initializers/bp3-actiontext.rb` to
`'Sites::Site'`, `'Tenant'` and `'Workspaces::Workspace'`; `.site_class` and friends constantize and cache.

## Testing

The spec only checks the version; the Railtie needs a Rails application with a database to exercise. Try a
change against the application (black_phoebe_3) by putting this repo's `lib` ahead of the bundled gem.

## Code Style

- RuboCop (`.rubocop.yml`): target Ruby 3.2.2, NewCops, rubocop-rake and rubocop-rspec; AbcSize 26,
  MethodLength 15, BlockLength 66, ModuleLength 150; `Lint/ConstantDefinitionInBlock` and `Lint/Void`
  are off for `lib/bp3/**/railtie.rb`, where classes are reopened inside a block
- Every file starts with `# frozen_string_literal: true`
- American English; no trailing whitespace on any added or modified line

## Release

Bump `lib/bp3/actiontext/version.rb` and add a `CHANGELOG.md` entry. `rake release` tags, pushes and
publishes to rubygems.org; leave releasing and committing to the user.
