module PathHelper
  def fixture_directory_path
    Pathname.new(File.dirname(__FILE__)).join('..', '..', 'spec', 'fixtures').expand_path
  end

  def fixture_path(path)
    fixture_directory_path.join(path)
  end
end
