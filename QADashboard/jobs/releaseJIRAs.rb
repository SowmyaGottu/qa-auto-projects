require 'net/http'
require 'json'
require 'time'
require 'open-uri'
require 'cgi'
require 'openssl'
require "base64"
require 'yaml'

# NOT ABLE TO MAKE IT WORK
yamlFile = "./conf/jiraConfig.yaml"
if File.exist?(yamlFile)
  JIRA_USER_CONFIG = YAML.load(File.new(yamlFile, "r").read)
else
  JIRA_USER_CONFIG = {
    jira_url: "https://chromeriver.atlassian.net",
    username: "qa.automation@chromewallet.com",
    password: "r3dr8nger",
    filterName: "43786", #ReleaseFilter
    filterName1: "43788", #ReleaseFilter1
    filterName2: "43789", #ReleaseFilter2
    filterName3: "43501", #TalendJIRAs
    filterName4: "43790"  #ReleaseFikter3
  }
end

def translate_status_to_id(status)
  statuses = {
    'success' => '5',
    'Ready For Prod' => '5',
    'Ready for Testing' => '4',
    'Ready For Testing' => '4',
    'Resolved' => '3',
    'In Progress' => '2',
    'New' => '2',
    'Reopened' => '1'
  }
  statuses[status] || '2'
end

def translate_status_to_class(status)
  statuses = {
    'success' => 'passed',
    'Ready For Prod' => 'passed',
    'Ready For Testing' => 'ready',
    'Ready for Testing' => 'ready',
    'Reopened' => 'failed',
    #'In Progress' => 'pending'
    'Resolved' => 'pending'
    #'New' => 'progress'
  }
  statuses[status] || 'progress'
end

def update_builds(project)
  data = {
    repo: "#{project['jira']}",
    branch: "",
    status: "#{translate_status_to_id(project['status'])}",
    widget_class: "#{translate_status_to_class(project['status'])}",
    avatar_url: "#{project['avatar']}"
  }
  return data
end

def getFilter(url, username, password, filterName)
  uri = URI.parse("#{url}/rest/api/2/filter/#{filterName}")
  http = Net::HTTP.new(uri.host, uri.port)

  if uri.scheme == 'https'
    http.use_ssl =
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # read into this
  end
  request = Net::HTTP::Get.new(uri.request_uri)
  request["Content-Type"] = "application/json"
  if !username.nil? && !username.empty?
    request.basic_auth(username, password)
  end
  response = JSON.parse(http.request(request).body)
  response['jql']
end

def getQAFromFilter(url, username, password, jqlString, startIndex)
  jql = CGI.escape(jqlString)
  #print jqlString
  uri = URI.parse("#{url}/rest/api/2/search?startAt=#{startIndex}&fields=customfield_10400&maxResults=499&jql=#{jql}")
  http = Net::HTTP.new(uri.host, uri.port)

  if uri.scheme == 'https'
    http.use_ssl =
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # read into this
  end
  request = Net::HTTP::Get.new(uri.request_uri)
  if !username.nil? && !username.empty?
    request.basic_auth(username, password)
  end
  JSON.parse(http.request(request).body)
end

def getIssuesFromFilter(url, username, password, jqlString, startIndex)
  jql = CGI.escape(jqlString)
  #print jqlString
  fullURL  = "#{url}/rest/api/2/search?startAt=#{startIndex}&maxResults=499&jql=#{jql}"
  #print fullURL
  uri = URI.parse(fullURL)
  http = Net::HTTP.new(uri.host, uri.port)

  if uri.scheme == 'https'
    http.use_ssl =
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # read into this
  end
  request = Net::HTTP::Get.new(uri.request_uri)
  if !username.nil? && !username.empty?
    request.basic_auth(username, password)
  end
  JSON.parse(http.request(request).body)
end

def getIssues()
  _filter = getFilter(JIRA_USER_CONFIG[:jira_url], JIRA_USER_CONFIG[:username], JIRA_USER_CONFIG[:password], JIRA_USER_CONFIG[:filterName])
  _issues = getIssuesFromFilter(JIRA_USER_CONFIG[:jira_url], JIRA_USER_CONFIG[:username], JIRA_USER_CONFIG[:password], _filter, 0)
  a = _issues['issues']
  count = _issues['maxResults']
  while _issues['maxResults'] < _issues['total']
    _issues = getIssuesFromFilter(JIRA_USER_CONFIG[:jira_url], JIRA_USER_CONFIG[:username], JIRA_USER_CONFIG[:password], _filter, count)
    count = _issues['startAt']
    a = a + _issues['issues']
    #print count
    if _issues['startAt'] + _issues['maxResults'] > _issues['total']
      break
    else
        count = _issues['startAt'] + _issues['maxResults']
    end
  end
  a
end

def getIssues1()
  _filter = getFilter(JIRA_USER_CONFIG[:jira_url], JIRA_USER_CONFIG[:username], JIRA_USER_CONFIG[:password], JIRA_USER_CONFIG[:filterName3])
  _issues = getIssuesFromFilter(JIRA_USER_CONFIG[:jira_url], JIRA_USER_CONFIG[:username], JIRA_USER_CONFIG[:password], _filter, 0)
  a = _issues['issues']
  count = _issues['maxResults']
  while _issues['maxResults'] < _issues['total']
    _issues = getIssuesFromFilter(JIRA_USER_CONFIG[:jira_url], JIRA_USER_CONFIG[:username], JIRA_USER_CONFIG[:password], _filter, count)
    count = _issues['startAt']
    a = a + _issues['issues']
    #print count
    if _issues['startAt'] + _issues['maxResults'] > _issues['total']
      break
    else
        count = _issues['startAt'] + _issues['maxResults']
    end
  end
  a
end

def getQAs()
  _filter = getFilter(JIRA_USER_CONFIG[:jira_url], JIRA_USER_CONFIG[:username], JIRA_USER_CONFIG[:password], JIRA_USER_CONFIG[:filterName1])
  _issues = getQAFromFilter(JIRA_USER_CONFIG[:jira_url], JIRA_USER_CONFIG[:username], JIRA_USER_CONFIG[:password], _filter, 0)
  a = _issues['issues']
  count = _issues['maxResults']
  while _issues['maxResults'] < _issues['total']
    _issues = getIssuesFromFilter(JIRA_USER_CONFIG[:jira_url], JIRA_USER_CONFIG[:username], JIRA_USER_CONFIG[:password], _filter, count)
    count = _issues['startAt']
    a = a + _issues['issues']
    #print count
    if _issues['startAt'] + _issues['maxResults'] > _issues['total']
      break
    else
        count = _issues['startAt'] + _issues['maxResults']
    end
  end
  a
end

def getQAs2()
  _filter = getFilter(JIRA_USER_CONFIG[:jira_url], JIRA_USER_CONFIG[:username], JIRA_USER_CONFIG[:password], JIRA_USER_CONFIG[:filterName2])
  _issues = getQAFromFilter(JIRA_USER_CONFIG[:jira_url], JIRA_USER_CONFIG[:username], JIRA_USER_CONFIG[:password], _filter, 0)
  a = _issues['issues']
  count = _issues['maxResults']
  while _issues['maxResults'] < _issues['total']
    _issues = getIssuesFromFilter(JIRA_USER_CONFIG[:jira_url], JIRA_USER_CONFIG[:username], JIRA_USER_CONFIG[:password], _filter, count)
    count = _issues['startAt']
    a = a + _issues['issues']
    #print count
    if _issues['startAt'] + _issues['maxResults'] > _issues['total']
      break
    else
        count = _issues['startAt'] + _issues['maxResults']
    end
  end
  a
end

def getQAs3()
  _filter = getFilter(JIRA_USER_CONFIG[:jira_url], JIRA_USER_CONFIG[:username], JIRA_USER_CONFIG[:password], JIRA_USER_CONFIG[:filterName3])
  _issues = getQAFromFilter(JIRA_USER_CONFIG[:jira_url], JIRA_USER_CONFIG[:username], JIRA_USER_CONFIG[:password], _filter, 0)
  a = _issues['issues']
  count = _issues['maxResults']
  while _issues['maxResults'] < _issues['total']
    _issues = getIssuesFromFilter(JIRA_USER_CONFIG[:jira_url], JIRA_USER_CONFIG[:username], JIRA_USER_CONFIG[:password], _filter, count)
    count = _issues['startAt']
    a = a + _issues['issues']
    #print count
    if _issues['startAt'] + _issues['maxResults'] > _issues['total']
      break
    else
        count = _issues['startAt'] + _issues['maxResults']
    end
  end
  a
end

def getQAs4()
  _filter = getFilter(JIRA_USER_CONFIG[:jira_url], JIRA_USER_CONFIG[:username], JIRA_USER_CONFIG[:password], JIRA_USER_CONFIG[:filterName4])
  _issues = getQAFromFilter(JIRA_USER_CONFIG[:jira_url], JIRA_USER_CONFIG[:username], JIRA_USER_CONFIG[:password], _filter, 0)
  a = _issues['issues']
  count = _issues['maxResults']
  while _issues['maxResults'] < _issues['total']
    _issues = getIssuesFromFilter(JIRA_USER_CONFIG[:jira_url], JIRA_USER_CONFIG[:username], JIRA_USER_CONFIG[:password], _filter, count)
    count = _issues['startAt']
    a = a + _issues['issues']
    #print count
    if _issues['startAt'] + _issues['maxResults'] > _issues['total']
      break
    else
        count = _issues['startAt'] + _issues['maxResults']
    end
  end
  a
end

def requestImage(d_url)
  username = JIRA_USER_CONFIG[:username]
  password = JIRA_USER_CONFIG[:password]
  query = CGI::parse(URI::parse(d_url).query)
  #url = query['d'][0]
  url = d_url
  url = URI.unescape(url)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)

  if uri.scheme == 'https'
    http.use_ssl =
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # read into this
  end
  request = Net::HTTP::Get.new(uri.request_uri)
  if !username.nil? && !username.empty?
    request.basic_auth(username, password)
  end
  response = http.request(request).body
  "data:image/png;base64, "+Base64.encode64(response)
end

def parseIssues()
  issues = getIssues()
  issues = issues + getIssues1()
  issuesArray = Array.new
  issueHash = Hash.new

  issues.each do |issue|
    issueHash['jira'] = issue['key']
    issueHash['status'] = issue['fields']['status']['name']
    
    if !(issue['fields']['customfield_12400']).nil?
      issueHash['avatar'] = requestImage(issue['fields']['customfield_12400'][0]['avatarUrls']['48x48'])
    else
      issueHash['avatar'] = "https://cdn4.iconfinder.com/data/icons/48x48-free-object-icons/48/Pets.png"
    end
    
    if !(issue['fields']['customfield_10400']).nil?
        if issue['fields']['project']['name'] == 'Synapse'
            issueHash['qa'] = 'TAL-'+ issue['fields']['customfield_10400']['displayName']
        else
            issueHash['qa'] = issue['fields']['customfield_10400']['displayName']
        end
    else
      if issue['fields']['project']['name'] == 'Chrome River Tools'
        issueHash['qa'] = 'T Unassigned'
      elsif issue['fields']['project']['name'] == 'Synapse'
        issueHash['qa'] = 'TAL-Unassigned'
      elsif issue['fields']['project']['name'] == 'Mercury'
        issueHash['qa'] = 'Unassigned (M)'
      else
        issueHash['qa'] = 'Unassigned'
      end
    end
    issuesArray.push issueHash
    issueHash = Hash.new
  end
  issuesArray
end

def parseQA()
  issues = getQAs()
  issuesArray = Array.new
  #issueHash = Hash.new

  issues.each do |issue|
    if !(issue['fields']['customfield_10400']).nil?
      issuesArray.push issue['fields']['customfield_10400']['displayName']
    else
      issuesArray.push 'Unassigned (M)'
    end
    #issuesArray.push issueHash
    #issueHash = Hash.new
  end
  issuesArray = issuesArray.uniq
  issuesArray = issuesArray.sort
end

def parseQA2()
  issues = getQAs2()
  issuesArray = Array.new
  #issueHash = Hash.new

  issues.each do |issue|
    if !(issue['fields']['customfield_10400']).nil?
      issuesArray.push issue['fields']['customfield_10400']['displayName']
    else
      issuesArray.push 'T Unassigned'
    end
    #issuesArray.push issueHash
    #issueHash = Hash.new
  end
  issuesArray = issuesArray.uniq
  issuesArray = issuesArray.sort
end

def parseQA3()
  issues = getQAs3()
  issuesArray = Array.new
  #issueHash = Hash.new

  issues.each do |issue|
    if !(issue['fields']['customfield_10400']).nil?
      issuesArray.push issue['fields']['customfield_10400']['displayName']
    else
      issuesArray.push 'Unassigned'
    end
    #issuesArray.push issueHash
    #issueHash = Hash.new
  end
  issuesArray = issuesArray.uniq
  issuesArray = issuesArray.sort
end

def parseQA4()
  issues = getQAs4()
  issuesArray = Array.new
  #issueHash = Hash.new

  issues.each do |issue|
    if !(issue['fields']['customfield_10400']).nil?
      issuesArray.push issue['fields']['customfield_10400']['displayName']
    else
      issuesArray.push 'Unassigned'
    end
    #issuesArray.push issueHash
    #issueHash = Hash.new
  end
  issuesArray = issuesArray.uniq
  issuesArray = issuesArray.sort
end

def filterResults()
  projects = parseIssues()
  qaHash = Hash.new {|h,k| h[k]=[]}
  items = projects.map{ |p|
    qaHash[p['qa']] << update_builds(p)
  }
  qaHash
end

SCHEDULER.every '300s', :first_in => 0  do
    _items = filterResults()
    _items.each { |h,k|
      send_event(h, { items: k.sort_by { |hsh| hsh[:status] } })
    }
end