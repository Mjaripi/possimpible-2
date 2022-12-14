# app/services/project_connector.rb

class ProjectConnector
  BASE_URL = 'https://api.github.com/repos/florinpop17/app-ideas/contents/Projects'.freeze
  API_KEY = ENV['GITHUB_TOKEN'].freeze

  # Initialize the object
  # After setting the @tier and @project calls the "request_project" to get the API response.
  #
  # @params tier[string]: Tier folder name to be searched on the API
  # @params project[string]: Project file name to be searched on the API
  def initialize(tier: nil, project: nil)
    @tier = tier
    @project = project
    @message = nil
    @code = nil
    @response = request_projects
  end

  # Method that returns the response of the API
  #
  # @returns response[hash]: Contains the request body response parsed on a hash.
  def base_response = @response
  
  # Method that returns the execution status code of the API call 
  def base_code = @code

  # Method that returns the execution status message of the API call
  def base_message = @message

  # Method that parse the @response variable when a project details is searched on the API
  # It's expected to process a 4-5 part document, separated by "\n## " for the main sections 
  #
  # @returns parsed_response[hash]: Contains the parsed @response to be stored on the model and shown in the page.
  def project_details_response
    return "Project not defined" if @project.nil?

    splited_project_details = Base64.decode64(@response["content"]).split("\n## ")

    raw_name_details = splited_project_details[0].split("\n")
    raw_stories = splited_project_details[1]
    raw_optional = ( splited_project_details[2].include?('Bonus features') ? splited_project_details[2] : nil )
    raw_resources = splited_project_details[-2]
    raw_examples = splited_project_details[-1]

    name = raw_name_details.first.gsub('# ','')
    details = ''
    raw_name_details[4..].each do |line|
      details += (line.blank? ? "\n\n" : "#{line}\n")
    end

    stories = ( raw_stories.include?("\n### ") ? parse_complex_checklist(raw_stories) : parse_simple_checklist(raw_stories) )
    unless raw_optional.nil?
      optional = ( raw_optional.include?("\n### ") ? parse_complex_checklist(raw_optional) : parse_simple_checklist(raw_optional) )
    end
    resources = parse_links(raw_resources)
    examples = parse_links(raw_examples)

    return parsed_project_details = {
      name: name,
      details: details,
      stories: stories,
      optional: optional,
      resources: resources,
      examples: examples
    }
  end

  private

  # Creates request to the Github API to get the repo content. 
  # It's expected to search the "app-ideas" based on the @tier and @project params
  # given when the object is created.
  #
  # @returns response[hash]: Contains the request body response parsed on a hash. 
  def request_projects
    url = "#{BASE_URL}"
    url += "/#{@tier}" unless @tier.nil?
    url += "/#{@project}" unless @project.nil?

    request = Typhoeus::Request.new(
      url,
      method: :get,
      headers: {
        'Accept' => 'application/vnd.github+json',
        'Authorization' => "Bearer #{API_KEY}"
      }
    )

    raw_response = request.run
    @code = raw_response.code
    @message = raw_response.return_message

    if @code == 200
      raw_body = raw_response.options[:response_body]
      raw_header = raw_response.options[:response_headers]

      raw_body.include?(raw_header) ? JSON.parse(raw_body[raw_header.length()..]) : JSON.parse(raw_response.body)
    end
  end

  # Parse the "Useful links and resources" or "Example project" to clean it's content and leave only the links
  #
  # @params link_list[string array]: Contains the contents of the "Useful links and resources" or "Example project" section in an array
  # @returns all_links[string array]: Contains an array with only the links and it's descriptions
  def parse_links(raw_link_list)
    all_links = []
    code_snips = []
    link_list = raw_link_list.include?("\n```\n") ? parse_link_with_code_snip(raw_link_list) : raw_link_list.split("\n")

    link_list[2..].each do |raw_link|
      next if raw_link.blank?

      if raw_link.include?('http')
        link = raw_link.split('[').last[..-2].split('](')
        all_links << "#{link.first} \\ #{link.last}"
      else
        all_links << raw_link
      end
    end
    all_links
  end

  #
  def parse_link_with_code_snip(raw_link_list)
    code_snips = []

    while raw_link_list.include?("\n```\n")
      init_index = raw_link_list.index("\n```\n") + 5
      end_index = raw_link_list[init_index..].index("\n```\n") + init_index

      code_snips << raw_link_list[init_index..end_index].gsub('    ', '\t')
      raw_link_list = raw_link_list[0..(init_index - 5)] + "\n[c]\n" + raw_link_list[(end_index + 5)..-1]
    end

    link_list = raw_link_list.split("\n")
    link_list.each do |list|
      next unless list == "[c]"
      
      #CHECK! update element on link_list array
      list = code_snips.first
      code_snips.shift
    end
  end

  # Parse a simple checklist from the "User Stories" or "Bonus features" separated by "\n## ".
  #
  # @params raw_checklist[string]: Contains the hole contents of the "User Stories" or "Bonus features" section
  # If used from "parse_complex_checklist" @raw_checklist corresponds to a sublist
  # @returns all_checklists[string array]: Contains an array with the checklist parsed in clean strings
  def parse_simple_checklist(raw_checklist)
    all_checklists = []
    split_raw_list = raw_checklist.split("\n")
    split_raw_list[1..].each do |list|
      next if list.blank?

      if list.include?('[ ]')
        all_checklists << list.split('[ ]').last[1..]
      else
        if all_checklists.length() == 0
          all_checklists << "[@] #{list}"
        else
          all_checklists[all_checklists.length()-1] += ( all_checklists[all_checklists.length()-1][-1] == " " ? list : " #{list}" )
        end
      end
    end
    all_checklists
  end

  # Parse a simple checklist from the "User Stories" or "Bonus features" separated by "\n## "
  # Uses the ":parse_simple_checklist" to parse the sublist which is separated by "\n### "
  #
  # @params raw_checklist[string]: Contains the hole contents of the "User Stories" or "Bonus features" section
  # @returns all_checklists[string array]: Contains an array with the checklist parsed in clean strings
  def parse_complex_checklist(raw_checklist)
    all_checklists = []
    split_raw_list = raw_checklist.split("\n### ")
    split_raw_list[1..].each do |list|
      all_checklists << "[@]#{list.split("\n")[0]}"
      all_checklists += parse_simple_checklist(list)
    end
    all_checklists
  end
end
