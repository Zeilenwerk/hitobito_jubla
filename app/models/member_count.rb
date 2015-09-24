# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito_jubla and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_jubla.

class MemberCount < ActiveRecord::Base

  belongs_to :flock, class_name: 'Group::Flock'
  belongs_to :state, class_name: 'Group::State'

  validates_by_schema
  validates :born_in, uniqueness: { scope: [:flock_id, :year] }
  validates :leader_f, :leader_m, :child_f, :child_m,
            numericality: { greater_than_or_equal_to: 0, allow_nil: true }


  def total
    leader + child
  end

  def leader
    leader_f.to_i + leader_m.to_i
  end

  def child
    child_f.to_i + child_m.to_i
  end

  def f
    leader_f.to_i + child_f.to_i
  end

  def m
    leader_m.to_i + child_m.to_i
  end

  class << self

    def total_by_states(year)
      totals(year).group(:state_id)
    end

    def total_by_flocks(year, state)
      totals(year).
      where(state_id: state.id).
      group(:flock_id)
    end

    def total_for_federation(year)
      totals(year).group(:year).first
    end

    def total_for_flock(year, flock)
      totals(year).
      where(flock_id: flock.id).
      group(:flock_id).
      first
    end

    def details_for_federation(year)
      details(year)
    end

    def details_for_state(year, state)
      details(year).where(state_id: state.id)
    end

    def details_for_flock(year, flock)
      details(year).where(flock_id: flock.id)
    end

    def totals(year)
      select('state_id, ' \
             'flock_id, ' \
             'born_in, ' \
             'SUM(leader_f) AS leader_f, ' \
             'SUM(leader_m) AS leader_m, ' \
             'SUM(child_f) AS child_f, ' \
             'SUM(child_m) AS child_m').
      where(year: year)
    end

    private


    def details(year)
      totals(year).
      group(:born_in).
      order(:born_in)
    end
  end

end
