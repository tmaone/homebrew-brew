require 'formula'

class GitNoDepthDownloadStrategy < GitDownloadStrategy
  # We need the .git folder for it's information, so we clone the whole thing
  def stage
    dst = Dir.getwd
    @clone.cd do
      reset
      safe_system 'git', 'clone', '--depth', '1', '.', dst
    end
  end
end

class JuliaHead < Formula
  homepage 'http://julialang.org'

  head do
    url 'https://github.com/JuliaLang/julia.git',
      :using => GitNoDepthDownloadStrategy, :shallow => true
  end

  bottle :unneeded

  depends_on "cmake" => :build
  depends_on "make" => :build
  depends_on "llvm" => :build
  depends_on "openblas" => :build
  depends_on "tmaone/metap/openlibm" => :build
  depends_on "utf8proc"
  depends_on "curl" => :build
  depends_on "pcre2" => :build
  depends_on "gmp" => :build
  depends_on "fftw" => :build
  depends_on "gcc" => :build
  depends_on "mpfr" => :build
  depends_on "libgit2" => :build
  depends_on "libssh2" => :build
  depends_on "arpack" => :build
  depends_on "lapack" => :build
  depends_on "suite-sparse" => :build
  depends_on "mbedtls" => :build

  # Need this as Julia's build process is quite messy with respect to env variables
  env :std

  # Options that can be passed to the build process
  option "system-libm", "Use system's libm instead of openlibm"

  # # Here we build up a list of patches to be applied
  # def patches
  #   patch_list = []
  #   # patch :DATA
  #   # This patch ensures that suitesparse libraries are installed
  #   patch_list << "https://gist.githubusercontent.com/timxzl/c6f474fa387382267723/raw/2ecb0270d83f0a167358ff2a396cd6004e1b02a0/Makefile.diff"
  #   patch_list << :DATA
  #   return patch_list
  # end

  def install
    ENV['PLATFORM'] = 'darwin'
    ENV['PYTHONPATH'] = ""

    # Build up list of build options
    build_opts = ["prefix=#{prefix}"]
    build_opts << "USE_BLAS64=0"
    build_opts << "TAGGED_RELEASE_BANNER=\"homebrew-julia release\""

    # Tell julia about our gfortran
    # (this enables use of gfortran-4.7 from the tap homebrew-dupes/gcc.rb)
    if ENV.has_key? 'FC'
      build_opts << "FC=#{ENV['FC']}"
    end

    # Tell julia about our llvm-config, since it's been named nonstandardly
    build_opts << "LLVM_CONFIG=llvm-config"
    build_opts << "LLVM_VER=6.0.0"
    # ENV["CPPFLAGS"] += " -DUSE_ORCJIT "

    # Tell julia where the default software base is, mostly for suitesparse
    build_opts << "LOCALBASE=#{prefix}"

    # Make sure we have space to muck around with RPATHS
    ENV['LDFLAGS'] += " -L/usr/local/opt/llvm/lib -L/usr/local/lib -L/usr/lib -headerpad_max_install_names"
    ENV['CPPFLAGS'] += "  -I/usr/local/opt/llvm/include"
    ENV['CFLAGS'] += " -I/usr/local/opt/llvm/include"

    ENV['CC'] = "/usr/local/opt/llvm/bin/clang"
    ENV['CXX'] = "/usr/local/opt/llvm/bin/clang++"
    # ENV["LD"] = "/usr/local/opt/llvm/bin/ld"
    ENV["RANLIB"] = "/usr/local/opt/llvm/bin/llvm-ranlib"
    ENV["AR"] = "/usr/local/opt/llvm/bin/llvm-ar"
    ENV["OBJDUMP"] = "/usr/local/opt/llvm/bin/llvm-objdump"
    ENV["NM"] = "/usr/local/opt/llvm/bin/llvm-nm"


    # Make sure Julia uses clang if the environment supports it
    build_opts << "USECLANG=1" if ENV.compiler == :clang
    build_opts << "VERBOSE=1" # if ARGV.verbose?

    build_opts << "LIBBLAS=-lopenblas"
    build_opts << "LIBBLASNAME=libopenblas"
    build_opts << "LIBLAPACK=-lopenblas"
    build_opts << "LIBLAPACKNAME=libopenblas"

    # Kudos to @ijt for these lines of code
    ['FFTW', 'GLPK', 'GMP', 'LLVM', 'PCRE', 'BLAS', 'LAPACK', 'SUITESPARSE', 'ARPACK', 'MPFR', 'LIBGIT2', 'LIBUNWIND', 'OPENLIBM', 'MBEDTLS', 'LIBSSH2', 'CURL'].each do |dep|
      build_opts << "USE_SYSTEM_#{dep}=1"
    end

    # build_opts << "USE_SYSTEM_LIBM=1" if build.include? "system-libm"
    # build_opts << "USE_SYSTEM_LIBM=1" # if build.include? "system-libm"

    # If we're building a bottle, cut back on fancy CPU instructions
    # build_opts << "MARCH=core2" if build.bottle?

    # call makefile to grab suitesparse libraries
    # system "make", "-j", "1" ,"-C", "contrib", "-f", "repackage_system_suitesparse4.make", *build_opts

    # Sneak in the fftw libraries, as julia doesn't know how to load dylibs from any place other than
    # julia's usr/lib directory and system default paths yet; the build process fixes that after the
    # install step, but the bootstrapping process requires the use of the fftw libraries before then
    # ['', 'f', '_threads', 'f_threads'].each do |ext|
    #   ln_s "#{Formula['fftw'].lib}/libfftw3#{ext}.dylib", "usr/lib/"
    # end
    # # Do the same for openblas, pcre, mpfr, and gmp
    # ln_s "#{Formula['openblas-julia'].opt_lib}/libopenblas.dylib", "usr/lib/"
    # ln_s "#{Formula['arpack-julia'].opt_lib}/libarpack.dylib", "usr/lib/"
    # ln_s "#{Formula['pcre2'].lib}/libpcre2-8.dylib", "usr/lib/"
    # ln_s "#{Formula['mpfr'].lib}/libmpfr.dylib", "usr/lib/"
    # ln_s "#{Formula['gmp'].lib}/libgmp.dylib", "usr/lib/"
    # ln_s "#{Formula['openblas-julia'].opt_lib}/libopenblas.dylib", "usr/lib/"
    # ln_s "#{Formula['libgit2'].lib}/libgit2.dylib", "usr/lib/"

    mkdir_p "usr/lib"

    ln_s "#{Formula['utf8proc'].opt_lib}/libutf8proc.a", "usr/lib/"

    build_opts << "release"
    build_opts << "debug"
    system "make", "-j", "1", *build_opts
    build_opts.pop
    build_opts.pop

    # Install!
    build_opts << "install"
    system "make", *build_opts
  end

  def post_install
    # We add in some custom RPATHs to julia
    rpaths = []

    # # Add in each key-only formula to the rpaths list
    # ['arpack-julia', 'suite-sparse-julia', 'openblas-julia'].each do |formula|
    #   rpaths << "#{Formula[formula].opt_lib}"
    # end

    # Add in generic Homebrew and system paths, as it might not be standard system paths
    rpaths << "#{HOMEBREW_PREFIX}/lib"

    # # Only add this in if we're < 10.8, because after that libxstub makes our lives miserable
    # if MacOS.version < :mountain_lion
    #   rpaths << "/usr/X11/lib"
    # end

    # Add those rpaths to the binaries
    rpaths.each do |rpath|
      Dir["#{bin}/julia*"].each do |file|
        chmod 0755, file
        quiet_system "install_name_tool", "-add_rpath", rpath, file
        chmod 0555, file
      end
    end

    # Change the permissions of lib/julia/sys.{dylib,ji} so that build_sysimg.jl can edit them
    Dir["#{lib}/julia/sys*.{dylib,ji}"].each do |file|
      chmod 0644, file
    end
  end

  def test
    # Run julia-provided test suite, copied over in install step
    if not (share + 'julia/test').exist?
      err = "Could not find test files directory\n"
      if build.head?
        err << "Did you accidentally include --HEAD in the test invocation?"
      else
        err << "Did you mean to include --HEAD in the test invocation?"
      end
      opoo err
    else
      system "#{bin}/julia", "-e", "Base.runtests(\"core\")"
    end
  end

  def caveats
    head_flag = build.head? ? " --HEAD " : " "
    <<-EOS.undent
    Documentation and Examples have been installed into:
    #{share}/julia

    Test suite has been installed into:
    #{share}/julia/test

    To perform a quick sanity check, run the command:
    brew test#{head_flag}-v julia

    To crunch through the full test suite, run the command:
    #{bin}/julia -e "Base.runtests()"
    EOS
  end
end

__END__
# diff --git a/deps/Versions.make b/deps/Versions.make
# index 0486758d2b..bc38c89160 100644
# --- a/deps/Versions.make
# +++ b/deps/Versions.make
# @@ -6,7 +6,7 @@ ARPACK_VER = 3.3.0
#  FFTW_VER = 3.3.6-pl1
#  SUITESPARSE_VER = 4.4.5
#  UNWIND_VER = 1.1-julia2
# -OSXUNWIND_VER = 0.0.3
# +OSXUNWIND_VER = master
#  GMP_VER = 6.1.2
#  MPFR_VER = 3.1.5
#  PATCHELF_VER = 0.9
#
# diff --git a/deps/checksums/libosxunwind-0.0.3.tar.gz/sha512 b/deps/checksums/libosxunwind-0.0.3.tar.gz/sha512
# index 27de36c88d..7ad8f59dc4 100644
# --- a/deps/checksums/libosxunwind-0.0.3.tar.gz/sha512
# +++ b/deps/checksums/libosxunwind-0.0.3.tar.gz/sha512
# @@ -1 +1 @@
# -64c57c297b6b3779ed7d675d3ebcf471247b0d15bb560fce631afd82229adb352d438cf71509ab076610c6867bcc9ee359cf609c0257e53bea431235ff1da349
# +e0f5e3aeaa5c13610e5542c3b2400467986ea0303dc523f4a48533764f368399c5d8a87caade221b2b415783adfcd7fb6b6dcac1f38dd8a5f10beb090b2994a4
#
# diff --git a/deps/unwind.mk b/deps/unwind.mk
# index 845086d95a..518086859d 100644
# --- a/deps/unwind.mk
# +++ b/deps/unwind.mk
# @@ -75,7 +75,7 @@ check-unwind: $(BUILDDIR)/libunwind-$(UNWIND_VER)/build-checked
#  OSXUNWIND_FLAGS := ARCH="$(ARCH)" CC="$(CC)" FC="$(FC)" AR="$(AR)" OS="$(OS)" USECLANG=$(USECLANG) USEGCC=$(USEGCC) CFLAGS="$(CFLAGS) -ggdb3 -O0" CXXFLAGS="$(CXXFLAGS) -ggdb3 -O0" SFLAGS="-ggdb3" LDFLAGS="$(LDFLAGS) -Wl,-macosx_version_min,10.7"
#
#  $(SRCDIR)/srccache/libosxunwind-$(OSXUNWIND_VER).tar.gz: | $(SRCDIR)/srccache
# -	$(JLDOWNLOAD) $@ https://github.com/JuliaLang/libosxunwind/archive/v$(OSXUNWIND_VER).tar.gz
# +	$(JLDOWNLOAD) $@ https://github.com/JuliaLang/libosxunwind/archive/master.tar.gz
#
#  $(BUILDDIR)/libosxunwind-$(OSXUNWIND_VER)/source-extracted: $(SRCDIR)/srccache/libosxunwind-$(OSXUNWIND_VER).tar.gz
#  	$(JLCHECKSUM) $<
