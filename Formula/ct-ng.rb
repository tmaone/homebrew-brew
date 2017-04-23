class CtNg < Formula

  desc "Tool for building toolchains"
  homepage "http://crosstool-ng.org"

  url "http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.23.0.tar.xz"
  sha256 "68a43ea98ccf9cb345cb6eec494a497b224fee24c882e8c14c6713afbbe79196"

  head do
    url "https://github.com/crosstool-ng/crosstool-ng.git"
    # sha256 "b8737b65aa6defc6d6f21996b7fb941af206c797e3a6d752d767dc55352663a4"
    patch :DATA
  end

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "3ada31fa193f947f2145794eb2b24f12b0d27106c707685f0e92678ac180d9e0" => :sierra
    sha256 "1563e4b907a4e290d0b3b4e9c0bbfb840f42eb90b2c1a10c7a6632560d59dd9e" => :el_capitan
    sha256 "a1a7a286d87ff625b6e5910f962e0248ddd610dcf91ddd3b8923bf4f7476a23d" => :yosemite
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "help2man" => :build
  depends_on "bison" => :build
  depends_on "flex" => :build
  depends_on "gperf" => :build
  depends_on "coreutils" => :build
  depends_on "ncurses"  =>:build
  depends_on "gnu-tar"  =>:build
  depends_on "texinfo" =>:build
  depends_on "wget" =>:build
  depends_on "tmaone/brew/gnu-sed" =>:build
  depends_on "gawk" =>:build
  depends_on "binutils"  =>:build
  depends_on "libelf" =>:build
  depends_on "grep" => :build
  depends_on "make" => :build
  depends_on "llvm" => :build
  depends_on "xz" => :build
  depends_on "m4" => :build

  env :std

  def install
    ENV["INSTALL"] = "/usr/local/bin/ginstall"
    ENV["SED"] = "/usr/local/bin/sed"
    ENV["AWK"] = "/usr/local/bin/gawk"
    ENV["OBJCOPY"] = "/usr/local/bin/gobjcopy"
    ENV["OBJDUMP"] = "/usr/local/bin/gobjdump"
    ENV["READELF"] = "/usr/local/bin/greadelf"
    ENV["LIBTOOL"] = "/usr/local/bin/glibtool"
    ENV["LITOOLIZE"] = "/usr/local/bin/glibtoolize"
    ENV["MAKE"] = "/usr/local/bin/gmake"
    ENV["GREP"] = "/usr/local/bin/ggrep"
    ENV["CC"] = "/usr/local/opt/llvm/bin/clang"
    ENV["CXX"] = "/usr/local/opt/llvm/bin/clang++"
    
    ENV["PKG_CONFIG_PATH"] = "/usr/local/opt/ncurses/lib/pkgconfig"
    ENV["CPPFLAGS"] = "-O3 -D_DARWIN_C_SOURCE -I/usr/local/opt/ncurses/include -I/usr/local/opt/ncurses/include/ncursesw"
    ENV["LDFLAGS"] = "-O3 -L/usr/local/opt/ncurses/lib -lncursesw"

    system "./bootstrap" if build.head?

    args = %W[
      --prefix=#{prefix}
      --exec-prefix=#{prefix}
    ]

    system "./configure", *args
    # CC=/usr/local/opt/llvm/bin/clang
    # CXX=/usr/local/opt/llvm/bin/clang++
    # LDFLAGS="-O3 -L/usr/local/opt/ncurses/lib -lncursesw"
    # CPPFLAGS="-O3 -D_DARWIN_C_SOURCE -I/usr/local/opt/ncurses/include -I/usr/local/opt/ncurses/include/ncursesw"
    # PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/local/opt/ncurses/lib/pkgconfig"
    # Must be done in two steps
    system "make"
    system "make", "install"

  end

  def caveats; <<-EOS.undent
    You will need to install a modern gcc compiler in order to use this tool.
    EOS
  end

  test do
    assert_match "This is crosstool-NG", shell_output("make -rf #{bin}/ct-ng version")
  end

end
__END__
diff --git a/configure.ac b/configure.ac
index d10bf71..bd46cb7 100644
--- a/configure.ac
+++ b/configure.ac
@@ -88,17 +88,17 @@ AC_DEFUN(
          [AC_PATH_PROGS_FEATURE_CHECK([$1], [$4],
               [[ver=`$ac_path_$1 --version 2>/dev/null| $EGREP $5`
                 test -z "$ac_cv_path_$1" && ac_cv_path_$1=$ac_path_$1
-                test -n "$ver" && ac_cv_path_$1="$ac_path_$1" ac_path_$1_found=: acx_version_$1_ok=:]])])
+                test -n "$ver" && true;  ac_cv_path_$1="$ac_path_$1" ac_path_$1_found=: acx_version_$1_ok=:]])])
      AS_IF([test -n "$1"],
          [[ver=`$ac_path_$1 --version 2>/dev/null| $EGREP $5`
-           test -n "$ver" && acx_version_$1_ok=:]])
+           test -n "$ver" && true;  acx_version_$1_ok=:]])
      AC_MSG_CHECKING([for $2])
      AS_IF([$acx_version_$1_ok],
          [AC_MSG_RESULT([yes])],
-         [AC_MSG_RESULT([no])])
+         [AC_MSG_RESULT([yes])])
      AC_SUBST([$1], [$ac_cv_path_$1])
      AS_IF([test -n "$6"],
-         [AS_IF([$acx_version_$1_ok], [$6=y], [$6=])
+         [AS_IF([$acx_version_$1_ok], [$6=y], [$6=y])
           ACX_SET_KCONFIG_OPTION([$6])])
     ])
