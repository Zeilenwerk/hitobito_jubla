# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito_jubla and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_jubla.

module HitobitoJubla
  class Wagon < Rails::Engine
    include Wagons::Wagon

    # Set the required application version.
    app_requirement '>= 0'

    # Add a load path for this specific wagon
    config.autoload_paths += %W( #{config.root}/app/abilities
                                 #{config.root}/app/domain
                                 #{config.root}/app/jobs
                               )

    # extend application classes here
    config.to_prepare do
      ### models
      Person.send :include, Jubla::Person
      Group.send  :include, Jubla::Group
      Role.send   :include, Jubla::Role
      Event::Course.send :include, Jubla::Event::Course
      Event::Application.send :include, Jubla::Event::Application
      Event::Kind.send :include, Jubla::Event::Kind

      ### abilities
      EventAbility.send :include, Jubla::EventAbility
      Event::ParticipationAbility.send :include, Jubla::Event::ParticipationAbility
      Event::RoleAbility.send :include, Jubla::Event::RoleAbility
      GroupAbility.send :include, Jubla::GroupAbility
      VariousAbility.send :include, Jubla::VariousAbility

      # load this class after all abilities have been defined
      Ability.store.register Event::Course::ConditionAbility

      # domain
      Export::Csv::Events::List.send :include, Jubla::Export::Csv::Events::List
      Export::Csv::Events::Row.send :include, Jubla::Export::Csv::Events::Row

      ### controllers
      GroupsController.send :include, Jubla::GroupsController
      EventsController.send :include, Jubla::EventsController
      Event::QualificationsController.send :include, Jubla::Event::QualificationsController
      Event::RegisterController.send :include, Jubla::Event::RegisterController

      ### decorators
      Event::ParticipationDecorator.send :include, Jubla::Event::ParticipationDecorator
      EventDecorator.send :include, Jubla::EventDecorator
      PersonDecorator.send :include, Jubla::PersonDecorator

      ### helpers
      # add more active_for urls to main navigation
      NavigationHelper::MAIN[:admin][:active_for] << 'event_camp_kinds'
    end

    initializer 'jubla.add_settings' do |app|
      Settings.add_source!(File.join(paths['config'].existent, 'settings.yml'))
      Settings.reload!
    end

    initializer 'jubla.add_inflections' do |app|
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.irregular 'census', 'censuses'
      end
    end

    private

    def seed_fixtures
      fixtures = root.join('db', 'seeds')
      ENV['NO_ENV'] ? [fixtures] : [fixtures, File.join(fixtures, Rails.env)]
    end
  end
end
