# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito_jubla and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_jubla.

module JublaOst
  class Base < ActiveRecord::Base
    self.abstract_class = true

    establish_connection JublaOst::Config.database

    class << self
      def migrate
        # ActiveRecord::Base.transaction do

        sanitize_source

        JublaOst::Region.migrate
        JublaOst::Kurs.migrate

        ActiveRecord::Base.record_timestamps = false
        JublaOst::Person.migrate
        ActiveRecord::Base.record_timestamps = true

        JublaOst::Schar.migrate_advisors
        JublaOst::Kurs.migrate_special_roles
        JublaOst::Person.migrate_updaters
      rescue Exception => e
        # some weird Sqlite3 BusyExceptions on rollback prevent
        # the original message being passed on, so print it here
        puts e.message
        puts e.backtrace.join("\n")
        raise e

        # end
      end

      def cache
        @cache ||= {}
      end

      private

      def combine(separator, *values)
        values.collect(&:presence).compact.join(separator)
      end

      def local_time(val)
        return nil if val.blank?
        utc = val.utc
        Time.zone.local(utc.year, utc.month, utc.day, utc.hour, utc.min, utc.sec)
      end

      def sanitize_source
        sanitize_dates(JublaOst::PersonSchar, 'Eintritt')
        sanitize_dates(JublaOst::PersonSchar, 'Austritt')
        sanitize_dates(JublaOst::Person, 'Geburtstag')
        sanitize_emails
        sanitize_kurse
        sanitize_groups
        remove_duplicate_emails
      end

      def sanitize_dates(clazz, attr)
        range = [0000] + (1900..2013).to_a
        range.each do |year|
          clazz.where("#{attr} LIKE ?", "#{year}-00-00%").
                update_all("#{attr} = '#{year}-01-01'")
        end
      end

      def sanitize_groups
        Schar.find(421).update_column(:Schar, 'Anwärter Camp 2012 - 2')
      end

      def sanitize_kurse
        Kurs.find(459).update_column(:anmeldestart, Date.new(2012, 12, 01))
        Kurs.find(468).update_column(:start, Date.new(2012, 04, 20))
      end

      def sanitize_emails
        Person.where(Email: 'denise17@bluemailch').update_all(Email: 'denise17@bluemail.ch')
        Person.where(Email: 'cludi.waltert@bluewin,ch').update_all(Email: 'cludi.waltert@bluewin.ch')
        Person.where(Email: 'joergst@bluewin').update_all(Email: 'joergst@bluewin.ch')
        Person.where(Email: 'juhu67@bluewin').update_all(Email: 'juhu67@bluewin.ch')
        Person.where(Email: 'benno.kraemer@bluewin').update_all(Email: 'benno.kraemer@bluewin.ch')
        Person.where(Email: 'cma@x-tra').update_all(Email: 'cma@x-tra.ch')
        Person.where(Email: 'm.kilchmann@shinternet').update_all(Email: 'm.kilchmann@shinternet.ch')
        Person.where(Email: 'test@test').update_all(Email: nil)
      end

      def remove_duplicate_emails
        ids = Person.joins('p1 INNER JOIN tPersonen p2 ON p1.email = p2.email AND p1.peid <> p2.peid')
                    .where("p1.email IS NOT NULL AND p1.email <> ''")
                    .pluck('p1.PEID')
        Person.where(PEID: ids).update_all(Email: nil) if ids.present?
        puts "#{ids.size} duplicate emails removed"
      end
    end
  end
end
