class Afsctool < Formula
  desc "Utility for manipulating HFS+ compressed files"
  homepage "https://brkirch.wordpress.com/afsctool/"
  url "https://github.com/RJVB/afsctool.git"
  version "1.6.9"
  sha256 ""
  #revision 2

  head do
    url "https://github.com/RJVB/afsctool.git"
    resource "sparsehash" do
      url "https://github.com/sparsehash/sparsehash.git"
    end
  end

  env :std
  ARGV << "--HEAD"
  ARGV << "--verbose"

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "zlib" => :build
  depends_on "llvm" => :build

  ENV["CC"] = Formula["llvm"].opt_bin/"clang"
  ENV["CXX"] = Formula["llvm"].opt_bin/"clang++"

  def install

    resource("sparsehash").stage do
      system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}", "CC=#{Formula["llvm"].opt_bin/"clang"}", "CXX=#{Formula["llvm"].opt_bin/"clang++"}"
      system "make", "install"
    end

    ENV.append_path "PKG_CONFIG_LIBDIR", "#{prefix}/lib/pkgconfig"

    mktemp do
      
      system "cmake", "-G", "Ninja", buildpath, *(std_cmake_args)
      system "ninja"
      system "ninja", "install"
    end

  end

  test do
    path = testpath/"foo"
    path.write "some text here."
    system "#{bin}/afsctool", "-c", path
    system "#{bin}/afsctool", "-v", path
  end

end
