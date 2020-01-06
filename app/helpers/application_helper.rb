module ApplicationHelper

  def common_languages(repos)
    languages_array = []
    repos.each do |repo|
      repo.languages.nodes.each do |language|
        languages_array.push language.name
      end
    end
    puts "======#{languages_array.inspect}"
    languages_hash = Hash.new(0)
    languages_array.each { |name| languages_hash[name] += 1 }
    return languages_hash.sort_by { |_, v| -v }
  end
end
