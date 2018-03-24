class Zlib < Formula
  desc "General-purpose lossless data-compression library"
  homepage "https://zlib.net/"
  url "https://zlib.net/zlib-1.2.11.tar.gz"
  mirror "https://downloads.sourceforge.net/project/libpng/zlib/1.2.11/zlib-1.2.11.tar.gz"
  sha256 "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1"

  depends_on "llvm" => :build
  env :std

  def install
    ENV["CC"] = Formula["llvm"].opt_bin/"clang"
    system "./configure", "--prefix=#{prefix}", "--static"
    system "make", "install"
  end

end
