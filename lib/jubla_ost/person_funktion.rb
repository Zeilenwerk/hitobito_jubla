# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito_jubla and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_jubla.

module JublaOst
  class PersonFunktion < Base
    self.table_name = 'tmPersFunkt'
    self.primary_key = 'PEFUid'

    class << self

      def migrate_person_roles(current, legacy)
        person_schars = find_person_schars(legacy.PEID)
        unhandled_schars = person_schars.keys

        if legacy.read_attribute_before_type_cast('aktiv') != 3 # verstorben
          create_person_funktion_roles(current, legacy, person_schars, unhandled_schars)
          create_person_schar_roles(current, person_schars, unhandled_schars)
        else
          create_alumnus_roles_for_dead(current, unhandled_schars)
        end
      end

      private

      def create_person_funktion_roles(current, legacy, person_schars, unhandled_schars)
        where(PEID: legacy.PEID).where('SCID IS NOT NULL').each do |person_funktion|
          scid = person_funktion.SCID
          funktion = Funktion.all[person_funktion.FUID]
          if person_schar = person_schars[scid]
            create_role(current, scid, person_schar, funktion)
            unhandled_schars.delete(scid)
          else
            # person_funktion without person_schar
            if group = find_group(current, scid)
              create_alumnus_role(current, group, build_role(group, funktion).class.label, Time.zone.now)
            end
          end
        end
      end

      def create_person_schar_roles(current, person_schars, unhandled_schars)
        unhandled_schars.each do |scid|
          create_role(current, scid, person_schars[scid], nil)
        end
      end

      def create_alumnus_roles_for_dead(current, unhandled_schars)
        unhandled_schars.each do |scid|
          if group = find_group(current, scid)
            create_alumnus_role(current, group, 'Verstorben', current.updated_at)
          end
        end
      end

      def find_person_schars(peid)
        PersonSchar.where(PEID: peid).where('SCID IS NOT NULL').each_with_object({}) do |entry, memo|
          memo[entry.SCID] = entry
        end
      end

      def find_group(current, scid)
        if group_id = Schar.cache[scid]
          Group.find(group_id)
        elsif !Schar::IGNORED.include?(scid)
          puts "No Schar with id=#{scid} found while migrating roles of #{current}"
        end
      end

      def create_role(current, scid, person_schar, funktion)
        if group = find_group(current, scid)
          role = build_role(group, funktion)
          assign_attributes(role, current, group, person_schar)
          role.save!
        end
      end

      def build_role(group, funktion)
        role_class = Funktion::Mappings[group.class][funktion]
        if role_class.nil?
          Funktion::Mappings[group.class][nil].new(label: funktion.label)
        else
          role_class.new
        end
      end

      def assign_attributes(role, current, group, person_schar)
        role.person = current
        role.group = group
        if person_schar
          role.label ||= person_schar.Jobs.presence
          role.created_at = person_schar.Eintritt
          if person_schar.Austritt
            role.deleted_at = person_schar.Austritt
            create_alumnus_role(role.person, role.group, role.class.label, role.deleted_at)
          end
        end
        role.created_at ||= current.created_at
        role.updated_at = role.created_at
        # roles of deleted groups are always deleted as well
        role.deleted_at ||= group.deleted_at
      end

      def create_alumnus_role(person, group, label, date)
        unless person.roles.where(group_id: group.id, type: Jubla::Role::Alumnus.sti_name).exists?
          alumnus = Jubla::Role::Alumnus.new
          alumnus.person = person
          alumnus.group = group
          alumnus.created_at = alumnus.updated_at = date
          alumnus.label = label
          alumnus.save!
        end
      end
    end
  end
end
