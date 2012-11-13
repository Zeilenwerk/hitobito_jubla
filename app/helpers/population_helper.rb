module PopulationHelper

  def person_edit_link(person)
    link_to(icon(:edit), 
            edit_group_person_path(person, group_id: @group.id, 
                                   return_url: population_group_path(@group.id)),
            title: 'Bearbeiten', alt: 'Bearbeiten')
  end

  def person_data_complete?(person)
    %w[birthday gender].each do |a|
      return false if person.send(a).blank?
    end
    true
  end

  def badge_invalid
    simple_format('<span class="badge badge-important"><i class="icon-exclamation-sign icon-white"></i></span>')
  end

end
