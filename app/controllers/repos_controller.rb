class ReposController < ApplicationController

  def index

    respond_to do |format|
      format.html do
        data = GraphqlFetchData.new( request_type: "list" ).call
       
        @repositories = data.organization.repositories
      end
      format.csv do
        data = GraphqlFetchData.new( request_type: "csv" ).generate_csv
         send_data data, filename: "google_repositories_#{Time.now().to_i}.csv"
      end
    end

  end


  private

    def generate_csv(repositories)
      attributes = %w(Name Languages Total_Languages Created_at)
      CSV.generate({headers: attributes}) do |csv|
        repositories.nodes.each do |repo|
          csv << [
            repo.name,
            repo.languages.nodes.collect(&:name).join(', '),
            repo.languages.total_count,
            repo.created_at
          ]
        end
      end
    end


end
