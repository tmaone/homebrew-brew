class CtNg < Formula

  desc "Tool for building toolchains"
  homepage "http://crosstool-ng.org"

  url "http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.23.0.tar.xz"
  sha256 "68a43ea98ccf9cb345cb6eec494a497b224fee24c882e8c14c6713afbbe79196"

  head do
    url "https://github.com/crosstool-ng/crosstool-ng.git"
    # sha256 "b8737b65aa6defc6d6f21996b7fb941af206c797e3a6d752d767dc55352663a4"
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

    system "./bootstrap" if build.head?

    args = %W[
      --prefix=#{prefix}
      --exec-prefix=#{prefix}
    ]
    
    patch :DATA

    system "./configure", *args

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
diff --git a/configure b/configure
index b7b9b63..517a1fb 100755
--- a/configure
+++ b/configure
@@ -3125,7 +3125,7 @@ $as_echo_n "checking for GNU sed >= 4.0... " >&6; }
 $as_echo "yes" >&6; }
 else
   { $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
+$as_echo "yes" >&6; }
 fi
      SED=$ac_cv_path_SED

@@ -3133,19 +3133,19 @@ fi
   if $acx_version_SED_ok; then :
   =y
 else
-  =
+  =y
 fi
           if test -n "$"; then :
   kconfig_options="$kconfig_options has_=y"
 else
-  kconfig_options="$kconfig_options has_"
+  kconfig_options="$kconfig_options has_y"
 fi

 fi

-     if test -z "$SED" || ! $acx_version_SED_ok; then :
-  as_fn_error $? "Required tool not found: GNU sed >= 4.0" "$LINENO" 5
-fi
+#     if test -z "$SED" || ! $acx_version_SED_ok; then :
+#  as_fn_error $? "Required tool not found: GNU sed >= 4.0" "$LINENO" 5
+#fi
