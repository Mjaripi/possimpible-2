class ProjectsController < ApplicationController
  def index
    tier_request = ProjectConnector.new
    all_tiers = tier_request.request_projects

    @found_tiers = ''
    all_tiers.each_with_index do |tier, index|
      @found_tiers << tier["name"]
      @found_tiers << " / " unless index == all_tiers.length()-1
    end
  end

  def load_projects; end
  
  def show_projects; end

end
