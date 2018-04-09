class Dyldbundler < Formula
  desc "mac dylib bundler"
  homepage "https://github.com/auriamg/macdylibbundler.git"
  head "https://github.com/auriamg/macdylibbundler.git"
	version "0.1"

  depends_on "make" => :build

  # ARGV << "--HEAD"
  # ARGV << "--verbose"

  def install
		inreplace "makefile", "PREFIX=/usr/local", "PREFIX=#{prefix}"
    mkdir_p "#{prefix}/bin"
		system "make", "install"
  end

  test do
    system "true"
  end

end
