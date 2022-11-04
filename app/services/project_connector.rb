# app/services/project_connector.rb
class ProjectConnector
  def initialize(tier: nil, project: nil)
    @tier = tier
    @project = project
    @url = 'https://api.github.com/repos/florinpop17/app-ideas/contents/Projects/'
  end

  def request_projects
    @url << "/#{@tier}" unless @tier.nil?
    @url << "/#{@project}" unless @project.nil?

    # REVISAR Typhoeus
    raw_response = Typhoeus::Request.new(
      @url,
      method: :get,
      header: {
        Authorization: "Bearer #{ENV["GITHUB_TOKEN"]}"
      }
    ).run
    response = raw_response.body
    JSON.parse(response)
  end

end