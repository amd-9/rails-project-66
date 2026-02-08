# frozen_string_literal: true

class OctokitClientStub
  attr_reader :total_count, :items

  def initialize(_)
    @total_count = 1
    @items = [Struct.new(:name, :id, :full_name, :language, :clone_url, :ssh_url)
                    .new('test_repo',
                         1,
                         'Sapmle test repo',
                         'ruby',
                         'https://github.com/test_repo/ruby_repo.git',
                         'git@github.com:test_repo/ruby_repo.git')]
  end

  def search_repos(_)
    Struct.new(:total_count, :items).new(@total_count, @items)
  end

  def repository(_)
    @items.first
  end
end
