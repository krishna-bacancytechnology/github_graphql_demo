require "graphql/client/railtie"
require "graphql/client/http"
class GraphqlFetchData

  def initialize(request_type)
    @request_type = request_type
  end
  
  def call
    return query(list_query)
  end

  def generate_csv
    data = query(csv_list)
    attributes = %w(Name Languages Created_at)
    CSV.generate({headers: attributes}) do |csv|
      data.organization.repositories.nodes.each do |repo|
        csv << [
          repo.name,
          repo.languages.nodes.collect(&:name).join(', '),
          repo.created_at
        ]
      end
    end
  end

  HTTPAdapter = GraphQL::Client::HTTP.new("https://api.github.com/graphql") do
    def headers(context)
      unless token = context[:access_token] || Application.secrets.github_access_token
        # $ GITHUB_ACCESS_TOKEN=abc123 bin/rails server
        #   https://help.github.com/articles/creating-an-access-token-for-command-line-use
        fail "Missing GitHub access token"
      end

      {
        "Authorization" => "Bearer #{token}"
      }
    end
  end
  
  Client = GraphQL::Client.new(
    schema: Rails.root.join("db/schema.json").to_s,
    execute: HTTPAdapter
  )
  Rails.application.configure do
    config.graphql.client = Client
  end


  def list_query
    lists = Client.parse <<-'GRAPHQL'
      {
        organization(login: "google") {
          repositories(privacy: PUBLIC, first: 100) {
            nodes {
              id
              name
              url
              createdAt
              languages(first: 10) {
                nodes {
                  name
                }
                totalCount
              }
            }
            edges {
              cursor
            }
            pageInfo{
              hasNextPage
            }
            totalCount
          }
        }
      }
    GRAPHQL
    
    return lists
  end


  def csv_list
    csv_query = Client.parse <<-'GRAPHQL'
      {
        organization(login: "google") {
          repositories(privacy: PUBLIC, first: 100) {
            nodes {
              name
              createdAt
              languages(first: 10) {
                nodes {
                  name
                }
                totalCount
              }
            }
          }
      }
    }
    GRAPHQL

    return csv_query
  end
  
  def query(definition)
    response = Client.query(definition, variables: {}, context: { access_token: Rails.application.secrets.github_access_token })

    return response.data
  end

end