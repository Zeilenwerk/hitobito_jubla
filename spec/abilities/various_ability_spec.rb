# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito_jubla and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_jubla.

require 'spec_helper'

describe VariousAbility do

  let(:user) { role.person }
  let(:group) { role.group }

  subject { Ability.new(user.reload) }

  describe 'qualification' do

    let(:qualification) { Fabricate(:qualification, person: person) }

    describe 'FederalBoard Member' do
      let(:role) { Fabricate(Group::FederalBoard::Member.name.to_sym, group: groups(:federal_board)) }

      context 'on StateAgency Member' do
        let(:person) { Fabricate(Group::StateAgency::Leader.name.to_sym, group: groups(:be_agency)).person }

        it 'can create and destroy' do
          is_expected.to be_able_to(:create, qualification)
          is_expected.to be_able_to(:destroy, qualification)
        end
      end

      context 'on FederalBoard Member' do
        let(:person) { Fabricate(Group::FederalBoard::Member.name.to_sym, group: groups(:federal_board)).person }

        it 'can create and destroy' do
          is_expected.to be_able_to(:create, qualification)
          is_expected.to be_able_to(:destroy, qualification)
        end
      end
    end

    describe 'StateAgency Member' do
      let(:role) { Fabricate(Group::StateAgency::Leader.name.to_sym, group: groups(:be_agency)) }

      context 'on StateAgency Member' do
        let(:person) { Fabricate(Group::StateAgency::Leader.name.to_sym, group: groups(:be_agency)).person }

        it 'can create and destroy' do
          is_expected.to be_able_to(:create, qualification)
          is_expected.to be_able_to(:destroy, qualification)
        end
      end

      context 'on FederalBoard Member' do
        let(:person) { Fabricate(Group::FederalBoard::Member.name.to_sym, group: groups(:federal_board)).person }

        it 'cannot create and destroy' do
          is_expected.not_to be_able_to(:create, qualification)
          is_expected.not_to be_able_to(:destroy, qualification)
        end
      end

      context 'on Flock Leader' do
        let(:person) { Fabricate(Group::Flock::Leader.name.to_sym, group: groups(:bern)).person }

        it 'can create and destroy' do
          is_expected.to be_able_to(:create, qualification)
          is_expected.to be_able_to(:destroy, qualification)
        end
      end
    end

    describe 'Flock Leader' do
      let(:role) { Fabricate(Group::Flock::Leader.name.to_sym, group: groups(:bern)) }

      context 'on StateAgency Member' do
        let(:person) { Fabricate(Group::StateAgency::Leader.name.to_sym, group: groups(:be_agency)).person }

        it 'cannot create and destroy' do
          is_expected.not_to be_able_to(:create, qualification)
          is_expected.not_to be_able_to(:destroy, qualification)
        end
      end

      context 'on Camp Leader' do
        let(:person) { Fabricate(Group::Flock::CampLeader.name.to_sym, group: groups(:bern)).person }

        it 'cannot create and destroy' do
          is_expected.not_to be_able_to(:create, qualification)
          is_expected.not_to be_able_to(:destroy, qualification)
        end
      end
    end

  end

  describe 'event_course_conditions' do
    let(:course_condition) { group.course_conditions.build }

    context 'FederalBoard Member' do
      let(:role) { Fabricate(Group::FederalBoard::Member.name.to_sym, group: groups(:federal_board)) }

      context 'on Federation' do
        let(:group) { groups(:ch) }

        it 'can index and manage' do
          is_expected.to be_able_to(:index_event_course_conditions, group)
          is_expected.to be_able_to(:manage_event_course_conditions, course_condition)
        end
      end

      context 'on State' do
        let(:group) { groups(:be) }

        it 'can index and manage' do
          is_expected.to be_able_to(:index_event_course_conditions, group)
          is_expected.to be_able_to(:manage_event_course_conditions, course_condition)
        end
      end

    end

    context 'StateAgency Leader' do
      let(:role) { Fabricate(Group::StateAgency::Leader.name.to_sym, group: groups(:be_agency)) }

      context 'on Federation' do
        let(:group) { groups(:ch) }

        it 'cannot index and manage' do
          is_expected.not_to be_able_to(:index_event_course_conditions, group)
          is_expected.not_to be_able_to(:manage_event_course_conditions, course_condition)
        end
      end

      context 'on State' do
        let(:group) { groups(:be) }

        it 'can index and manage' do
          is_expected.to be_able_to(:index_event_course_conditions, group)
          is_expected.to be_able_to(:manage_event_course_conditions, course_condition)
        end
      end

    end

  end



end
