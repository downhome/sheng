module PathHelper

  def fixture_path(path)
    File.join('spec', 'fixtures', path)
  end
end
