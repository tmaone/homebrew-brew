class Base16 < Formula
  desc "A command line tool to install base16 templates and set themes globally."
  homepage "https://github.com/AuditeMarlow/base16-manager"
  url "https://github.com/AuditeMarlow/base16-manager.git"

  def install
		system "cp", "base16-manager", "base16"
    bin.install "base16"
  end
end