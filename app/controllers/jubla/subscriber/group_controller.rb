# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito_jubla and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_jubla.

module Jubla::Subscriber::GroupController
  extend ActiveSupport::Concern

  included do
    alias_method_chain :candidate_groups, :sisters
  end

  def candidate_groups_with_sisters
    @group.sister_groups_with_descendants
  end

end