# app/services/project_connector.rb
class ProjectConnector
  BASE_URL = 'https://api.github.com/repos/florinpop17/app-ideas/contents/Projects'.freeze
  API_KEY = ENV['GITHUB_TOKEN'].freeze

  def initialize(tier: nil, project: nil)
    @tier = tier
    @project = project
  end

  def request_projects
    url = "#{BASE_URL}"
    url << "/#{@tier}" unless @tier.nil?
    url << "/#{@project}" unless @project.nil?

    request = Typhoeus::Request.new(
      url,
      method: :get,
      headers: {
        'Accept' => 'application/vnd.github+json',
        'Authorization' => "Bearer #{API_KEY}"
      }
    )

    raw_response = request.run
    raw_body = raw_response.options[:response_body]
    raw_header = raw_response.options[:response_headers]

    raw_body.include?(raw_header) ? JSON.parse(raw_body[raw_header.length()..]) : JSON.parse(raw_response.body)
  end
end
