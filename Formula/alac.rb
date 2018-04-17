class Alac < Formula
  desc "Apple Lossless Codec and Utility with Autotools"
  homepage "https://github.com/mikebrady/alac"
  url "https://github.com/mikebrady/alac/archive/0.0.7.tar.gz"
  sha256 "5a2b059869f0d0404aa29cbde44a533ae337979c11234041ec5b5318f790458e"

	depends_on "autoconf" => :build
	depends_on "libtool" => :build
	depends_on "automake" => :build

  def install
    system "autoreconf", "-fi"
    system "./configure", "--prefix=#{prefix}"
		system "make"
		system "make", "install"
  end

  test do
    sample = test_fixtures("test.m4a")
    assert_equal "file type: mp4a\n", shell_output("#{bin}/alac -t #{sample}", 100)
  end
end

