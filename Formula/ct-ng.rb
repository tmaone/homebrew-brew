class ctng < Formula

  desc "Tool for building toolchains"
  homepage "http://crosstool-ng.org"

	#867f9e710d16ea8891ec177f8accf9c576525a1de1bb0795a31a2200f9b029638e2425106e9af5f8232d496f7c029df59e83d31b84757863b398c39c12891dc9  crosstool-ng-1.23.0.tar.xz
  url "http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.23.0.tar.xz"
  sha512 "867f9e710d16ea8891ec177f8accf9c576525a1de1bb0795a31a2200f9b029638e2425106e9af5f8232d496f7c029df59e83d31b84757863b398c39c12891dc9"

  head "https://github.com/crosstool-ng/crosstool-ng"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    # sha256 "3ada31fa193f947f2145794eb2b24f12b0d27106c707685f0e92678ac180d9e0" => :sierra
    # sha256 "1563e4b907a4e290d0b3b4e9c0bbfb840f42eb90b2c1a10c7a6632560d59dd9e" => :el_capitan
    # sha256 "a1a7a286d87ff625b6e5910f962e0248ddd610dcf91ddd3b8923bf4f7476a23d" => :yosemite
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "help2man" => :build
  depends_on "bison" => :build
  depends_on "flex" => :build
  depends_on "gperf" => :build
  depends_on "coreutils" => :build
  depends_on "ncurses"
  depends_on "gnu-sed"
  depends_on "gnu-tar"
  depends_on "texinfo"
  depends_on "wget"
  depends_on "gnu-sed"
  depends_on "gawk"
  depends_on "binutils"
  depends_on "libelf"
  depends_on "grep" => :optional
  depends_on "make" => :optional
  
  env :std

  def install
    args = %W[
      --prefix=#{prefix}
      --exec-prefix=#{prefix}
      --with-objcopy=gobjcopy
      --with-objdump=gobjdump
      --with-readelf=greadelf
      --with-libtool=glibtool
      --with-libtoolize=glibtoolize
      --with-install=ginstall
      --with-sed=gsed
      --with-awk=gawk
    ]

    args << "--with-grep=ggrep" if build.with? "grep"
    args << "--with-make=#{Formula["make"].opt_bin}/gmake" if build.with? "make"
    args << "CFLAGS=-std=gnu89"

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
