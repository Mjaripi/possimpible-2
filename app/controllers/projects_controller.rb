class ProjectsController < ApplicationController
  def index
    tier_list_request = ProjectConnector.new
    @response_code = tier_list_request.base_code

    if @response_code == 200
      @all_tiers = tier_list_request.base_response
      @counted_tiers = @all_tiers.count
      @stored_projects = Project.all.count
      @text_tiers = ''
      @all_tiers.each_with_index do |tier, index|
        @text_tiers += tier["name"]
        @text_tiers += " / " unless index == @all_tiers.length()-1
      end
    else
      @text_tiers = tier_list_request.base_message
    end
  end

  def load_projects
    found_tiers = params[:tiers] unless params[:tiers].blank?
    found_tiers.each do |tier|
      tier_value = tier["name"].split('-').first
      tier_name = tier["name"].split('-').last
      # save tier on model if doesn't exist in it.

      project_list_request = ProjectConnector.new(tier: tier["name"])
      all_projects = project_list_request.base_response
      all_projects.each do |project|
        project_request = ProjectConnector.new(tier: tier["name"], project: project["name"])
        puts("///////////#{project_request.project_details_response}")

        # save project on model if doesn't exist in it.
      end
    end
  end
  
  def show_projects; end

end
