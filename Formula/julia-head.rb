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

  depends_on "tmaone/metap/openlibm" => :build
  depends_on "cmake" => :build
  depends_on "make" => :build
  depends_on "llvm" => :build
  depends_on "openblas" => :build
  depends_on "utf8proc" => :build
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
  depends_on "libxml2" => :build
  depends_on "libedit" => :build
  depends_on "suite-sparse" => :build
  depends_on "mbedtls" => :build

  # Need this as Julia's build process is quite messy with respect to env variables
  env :std
  ARGV << "--HEAD"
  ARGV << "--verbose"

  def install

    ENV['PLATFORM'] = 'darwin'
    ENV['PYTHONPATH'] = ""

    # Build up list of build options
    build_opts = ["prefix=#{prefix}"]
    build_opts << "TAGGED_RELEASE_BANNER=\"homebrew-julia release\""

    # Tell julia about our gfortran
    # (this enables use of gfortran-4.7 from the tap homebrew-dupes/gcc.rb)
    if ENV.has_key? 'FC'
      build_opts << "FC=#{ENV['FC']}"
    end

    # Tell julia about our llvm-config, since it's been named nonstandardly
    build_opts << "LLVM_CONFIG=llvm-config"
    build_opts << "LLVM_VER=6.0.0"

    # Tell julia where the default software base is, mostly for suitesparse
    build_opts << "LOCALBASE=#{prefix}"

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

    mkdir_p "usr/lib"
    mkdir_p "usr/lib/julia"

    ln_s "#{Formula['openblas'].opt_lib}/libopenblas.dylib", "usr/lib/julia/"
    ln_s "#{Formula['arpack'].opt_lib}/libarpack.dylib", "usr/lib/julia/"
    ln_s "#{Formula['pcre2'].lib}/libpcre2-8.dylib", "usr/lib/"
    ln_s "#{Formula['mpfr'].lib}/libmpfr.dylib", "usr/lib/"
    ln_s "#{Formula['gmp'].lib}/libgmp.dylib", "usr/lib/"
    ln_s "#{Formula['libgit2'].lib}/libgit2.dylib", "usr/lib/"
    ln_s "#{Formula['utf8proc'].opt_lib}/libutf8proc.a", "usr/lib/"

    system "make", "-j", "1", *build_opts

    # Install!
    build_opts << "install"
    system "make", *build_opts
  end

  def post_install
    # We add in some custom RPATHs to julia
    rpaths = []

    # Add in generic Homebrew and system paths, as it might not be standard system paths
    rpaths << "#{HOMEBREW_PREFIX}/lib"

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
    <<~EOS.undent
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
