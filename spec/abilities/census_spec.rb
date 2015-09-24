# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito_jubla and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_jubla.

require 'spec_helper'

describe Ability do

  let(:user) { role.person }
  let(:group) { role.group }
  let(:flock) { groups(:bern) }

  subject { Ability.new(user.reload) }

  describe 'FederalBoard Member' do
    let(:role) { Fabricate(Group::FederalBoard::Member.name.to_sym, group: groups(:federal_board)) }

    it 'may update member counts' do
      is_expected.to be_able_to(:update_member_counts, flock)
    end

    it 'may create member counts' do
      is_expected.to be_able_to(:create_member_counts, flock)
    end

    it 'may approve population' do
      is_expected.to be_able_to(:approve_population, flock)
    end

    it 'may view census for flock' do
      is_expected.to be_able_to(:evaluate_census, flock)
    end

    it 'may view census for state' do
      is_expected.to be_able_to(:evaluate_census, flock.state)
    end

    it 'may view census for federation' do
      is_expected.to be_able_to(:evaluate_census, group)
    end

    it 'may remind census for state' do
      is_expected.to be_able_to(:remind_census, flock.state)
    end
  end

  describe 'State Agency Leader' do
    let(:role) { Fabricate(Group::StateAgency::Leader.name.to_sym, group: groups(:be_agency)) }

    it 'may update member counts' do
      is_expected.to be_able_to(:update_member_counts, flock)
    end

    it 'may create member counts' do
      is_expected.to be_able_to(:create_member_counts, flock)
    end

    it 'may approve population' do
      is_expected.to be_able_to(:approve_population, flock)
    end

    it 'may view census for flock' do
      is_expected.to be_able_to(:evaluate_census, flock)
    end

    it 'may view census for state' do
      is_expected.to be_able_to(:evaluate_census, flock.state)
    end

    it 'may view census for federation' do
      is_expected.to be_able_to(:evaluate_census, groups(:ch))
    end

    it 'may remind census for state' do
      is_expected.to be_able_to(:remind_census, flock.state)
    end

    context 'for other state' do
      let(:role) { Fabricate(Group::StateAgency::Leader.name.to_sym, group: groups(:no_agency)) }

      it 'may not update member counts' do
        is_expected.not_to be_able_to(:update_member_counts, flock)
      end

      it 'may not approve population' do
        is_expected.not_to be_able_to(:approve_population, flock)
      end

      it 'may view census for flock' do
        is_expected.to be_able_to(:evaluate_census, flock)
      end

      it 'may not remind census' do
        is_expected.not_to be_able_to(:remind_census, flock.state)
      end
    end
  end


  describe 'Flock Leader' do
    let(:role) { Fabricate(Group::Flock::Leader.name.to_sym, group: groups(:bern)) }

    it 'may not update member counts' do
      is_expected.not_to be_able_to(:update_member_counts, flock)
    end

    it 'may create member counts' do
      is_expected.to be_able_to(:create_member_counts, flock)
    end

    it 'may approve population' do
      is_expected.to be_able_to(:approve_population, flock)
    end

    it 'may view census for flock' do
      is_expected.to be_able_to(:evaluate_census, flock)
    end

    it 'may view census for state' do
      is_expected.to be_able_to(:evaluate_census, flock.state)
    end

    it 'may view census for federation' do
      is_expected.to be_able_to(:evaluate_census, groups(:ch))
    end

    it 'may not remind census for state' do
      is_expected.not_to be_able_to(:remind_census, flock.state)
    end
  end
end
