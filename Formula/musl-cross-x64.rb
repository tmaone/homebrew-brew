class MuslCrossX64 < Formula

  desc "Linux cross compilers based on musl libc"
  homepage "https://github.com/richfelker/musl-cross-make"
  head "https://github.com/just-containers/musl-cross-make.git", :branch => "travis-build"

  #ARGV << "--HEAD"
  #ARGV << "--env=std"
  #ARGV << "--verbose"
  #ARGV << "--debug"

  depends_on "gnu-sed" => :build
  depends_on "make" => :build
	depends_on "gawk" => :build

  resource "linux-4.4.10.tar.xz" do
    url "https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.4.10.tar.xz"
  end

  resource "mpfr-4.0.1.tar.xz" do
    url "http://www.mpfr.org/mpfr-current/mpfr-4.0.1.tar.xz"
  end

  resource "mpc-1.1.0.tar.gz" do
    url "https://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz"
  end

  resource "gmp-6.1.2.tar.xz" do
    url "https://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.xz"
  end

  resource "musl-1.1.19.tar.gz" do
    url "https://www.musl-libc.org/releases/musl-1.1.19.tar.gz"
  end

  resource "binutils-2.30.tar.bz2" do
    url "https://ftp.gnu.org/gnu/binutils/binutils-2.30.tar.bz2"
  end

  resource "config.sub" do
   url "https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=3d5db9ebe860"
  end

  resource "gcc-7.3.0.tar.xz" do
    url "https://ftp.gnu.org/gnu/gcc/gcc-7.3.0/gcc-7.3.0.tar.xz"
  end

  def install
    ENV.deparallelize

    targets = ["x86_64-linux-musl"]

    (buildpath/"resources").mkpath

    resources.each do |resource|
      cp resource.fetch, buildpath/"resources"/resource.name
    end

    system Formula["git"].opt_bin/"git", "clone", "https://github.com/michaelforney/musl-cross-make.git"
    system "cp", "-rv", "musl-cross-make/hashes/gcc-7.3.0.tar.xz.sha1", "hashes/gcc-7.3.0.tar.xz.sha1"
    system "cp", "-rv", "musl-cross-make/patches/gcc-7.3.0", "patches/"

    (buildpath/"config.mak").write <<-EOS
    SOURCES = #{buildpath/"resources"}
    OUTPUT = #{libexec}

    BINUTILS_VER = 2.30
    GCC_VER = 7.3.0
    MUSL_VER = 1.1.19
    GMP_VER = 6.1.2
    MPC_VER = 1.1.0
    MPFR_VER = 4.0.1
    LINUX_VER = 4.4.10

    # Recommended options for faster/simpler build:
    COMMON_CONFIG += --disable-nls
    GCC_CONFIG += --enable-languages=c,c++
    GCC_CONFIG += --disable-libquadmath --disable-decimal-float
    GCC_CONFIG += --disable-multilib
    # Recommended options for smaller build for deploying binaries:
    COMMON_CONFIG += CFLAGS="-g0 -Os" CXXFLAGS="-g0 -Os" LDFLAGS="-s"
    # Keep the local build path out of binaries and libraries:
    COMMON_CONFIG += --with-debug-prefix-map=$(PWD)=

    # https://llvm.org/bugs/show_bug.cgi?id=19650
    ifeq ($(shell $(CXX) -v 2>&1 | grep -c "clang"), 1)
    TOOLCHAIN_CONFIG += CXX="$(CXX) -fbracket-depth=512"
    endif
    EOS

    ENV.prepend_path "PATH", "#{Formula["gnu-sed"].opt_libexec}/gnubin"
    targets.each do |target|
      system Formula["make"].opt_bin/"gmake", "install", "TARGET=#{target}"
    end

    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    (testpath/"hello.c").write <<-EOS.undent
    #include <stdio.h>

    main()
    {
        printf("Hello, world!");
    }
    EOS

    if build.with? "x86_64"
      system "#{bin}/x86_64-linux-musl-cc", (testpath/"hello.c")
    end
  end
end

__END__
diff --git a/Makefile b/Makefile
index 9785bea..2280c11 100644
--- a/Makefile
+++ b/Makefile
@@ -1,9 +1,10 @@

 SOURCES = sources

+
 CONFIG_SUB_REV = 3d5db9ebe860
 BINUTILS_VER = 2.27
-GCC_VER = 6.3.0
+GCC_VER = 7.3.0
 MUSL_VER = 1.1.19
 GMP_VER = 6.1.1
 MPC_VER = 1.0.3
