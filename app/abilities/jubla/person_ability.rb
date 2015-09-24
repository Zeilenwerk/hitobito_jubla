# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito_jubla and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_jubla.

module Jubla::PersonAbility
  extend ActiveSupport::Concern

  included do
    STATES = %w(application_open application_closed assignment_closed completed)

    on(Person) do
      permission(:layer_and_below_full).may(:update).
        non_restricted_in_same_layer_or_visible_below_or_accessible_participations
    end
  end

  def non_restricted_in_same_layer_or_visible_below_or_accessible_participations
    non_restricted_in_same_layer_or_visible_below || accessible_participations
  end

  def accessible_participations
    events_with_valid_states.any? do |event|
      (user_context.permission_layer_ids(:layer_and_below_full) & event.group_ids).present?
    end
  end

  private

  def events_with_valid_states
    subject.
      event_participations.
      includes(:event).
      collect(&:event).
      select { |event| STATES.include?(event.state) }
  end
end
