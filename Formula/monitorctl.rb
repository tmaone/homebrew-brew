class Monitorctl < Formula

  desc "monitorctl"
  homepage "https://github.com/tmaone/monitorctl.git"
  url "https://github.com/tmaone/monitorctl.git", :branch => 'master'
  head "https://github.com/tmaone/monitorctl.git", :branch => 'master'

	version "0.1"

  depends_on "make" => :build

  def install

    ARGV << "--HEAD"
    ARGV << "--verbose"

		ENV['PREFIX'] = "#{prefix}/bin"
    system "mkdir", "-p", "#{prefix}/bin"
    system "make", "install"

  end

  test do
    system "true"
  end
end
