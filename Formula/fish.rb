class Fish < Formula

  desc "User-friendly command-line shell for UNIX-like operating systems"
  homepage "https://fishshell.com"

  url "https://github.com/fish-shell/fish-shell/releases/download/2.7.1/fish-2.7.1.tar.gz"
  mirror "https://fishshell.com/files/2.7.1/fish-2.7.1.tar.gz"
  sha256 "e42bb19c7586356905a58578190be792df960fa81de35effb1ca5a5a981f0c5a"

  ARGV << "--HEAD"
  ARGV << "--verbose"
  # ARGV << "--env=std"

  head do
    url "https://github.com/fish-shell/fish-shell.git", :shallow => false
    depends_on "cmake" => :build
    depends_on "llvm" => :build
    depends_on "ninja" => :build
    depends_on "doxygen" => :build
  end

  depends_on "pcre2"
  depends_on "homebrew/core/ncurses"
  depends_on "llvm"

  needs :cxx11

  def install

    ENV["SED"] = "/usr/bin/sed"
    ENV["CXXFLAGS"] = "-I/usr/local/opt/llvm/include -std=c++11"
    ENV["CFLAGS"] = "-I/usr/local/opt/llvm/include"
    ENV["LDFLAGS"] = "-L/usr/local/opt/llvm/lib"
    ENV["CC"] = "/usr/local/opt/llvm/bin/clang"
    ENV["CXX"] = "/usr/local/opt/llvm/bin/clang++"
    ENV["LD"] = "/usr/local/opt/llvm/bin/ld"
    ENV["RANLIB"] = "/usr/local/opt/llvm/bin/llvm-ranlib"
    ENV["AR"] = "/usr/local/opt/llvm/bin/llvm-ar"
    ENV["OBJDUMP"] = "/usr/local/opt/llvm/bin/llvm-objdump"
    ENV["NM"] = "/usr/local/opt/llvm/bin/llvm-nm"

    args = std_cmake_args + %W[
      -G Ninja
      -DCMAKE_OSX_ARCHITECTURES=x86_64
      -DCMAKE_BUILD_TYPE=Release
      -DWITH_GETTEXT=OFF
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DCMAKE_RANLIB=#{ENV["RANLIB"]}
      -DCMAKE_AR=#{ENV["AR"]}
      -DCMAKE_OBJDUMP=#{ENV["OBJDUMP"]}
      -DCMAKE_NM=#{ENV["NM"]}
      -DPCRE2_INCLUDE_DIR=#{HOMEBREW_PREFIX}/opt/pcre2/include
      -DPCRE2_LIB=#{HOMEBREW_PREFIX}/opt/pcre2/lib/libpcre2-32.dylib
      -DSED=#{ENV["SED"]}
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
      -Dextra_completionsdir=#{HOMEBREW_PREFIX}/share/fish/vendor_completions.d
      -Dextra_functionsdir=#{HOMEBREW_PREFIX}/share/fish/vendor_functions.d
      -Dextra_confdir=#{HOMEBREW_PREFIX}/share/fish/vendor_conf.d
    ]

    mkdir "build" do
      system "cmake", "..", *args
      system "ninja"
      system "ninja", "doc"
      system "ninja", "install"
    end

  end

  def post_install
    (pkgshare/"vendor_functions.d").mkpath
    (pkgshare/"vendor_completions.d").mkpath
    (pkgshare/"vendor_conf.d").mkpath
  end

  test do
    system "#{bin}/fish", "-c", "echo"
  end

end
