require 'formula'

class GitRecurseDownloadStrategy < GitDownloadStrategy
  # We need the .git folder for it's information, so we clone the whole thing
  def stage
    dst = Dir.getwd
    @clone.cd do
      reset
      safe_system 'git', 'clone', '--recurse-submodules', '.', dst
    end
  end
end

class Darwinbuild < Formula

  homepage 'http://darwinbuild.macosforge.org/'

  head do
    # legacy 'https://github.com/macosforge/darwinbuild.git'
    url 'https://github.com/csekel/darwinbuild.git',
      :using => GitRecurseDownloadStrategy, :shallow => false
  end
  #
  # def patches
  #   DATA
  # end

  depends_on :xcode # For working xcodebuild.
  depends_on "cmake"
  depends_on "ninja"

  env :std

  def install

  # ENV['PREFIX'] = "#{HOMEBREW_PREFIX}"
  # ENV['DESTDIR'] = "#{HOMEBREW_PREFIX}"
  # ENV['SRCROOT'] = '.'
  # ENV['OBJROOT'] = '.'
  # ENV['SYMROOT'] = '.'

  # ENV['INSTALL'] = "#{HOMEBREW_FORMULA_PREFIX}"
  # ENV['STAGE'] = "/"

  build_opts = ["PREFIX=#{prefix}"]
  build_opts << "DSTROOT=dist"
  build_opts << "SRCROOT=."
  build_opts << "OBJROOT=obj"
  build_opts << "SYMROOT=sym"

  build_opts << "-configuration"
  build_opts << "Release"

  system "xcodebuild", *build_opts, "-target", "xcbuild", "build"
  system "xcodebuild", *build_opts, "build"

  build_opts << "DSTROOT=#{prefix}"
  system "xcodebuild", *build_opts, "install"

  bin.install "#{prefix}/usr/local/bin/darwinbuild"
  bin.install "#{prefix}/usr/local/bin/darwinmaster"

  man8.install Dir["#{prefix}/share/man//man1/*.1"]

  # sbin.install "cgdisk" if build.with? "cgdisk"
  # sbin.install "sgdisk" if build.with? "sgdisk"
  # sbin.install "fixparts" if build.with? "fixparts"
  #
  # doc.install Dir["*.html"]
  # system "cp", "-rv", ".", "/tmp/test"

  end
#
#   ARGV << "--HEAD"
#   ARGV << "--verbose"
#
#   ENV['PLATFORM'] = 'darwin'
#   ENV['PYTHONPATH'] = ""
#
#   # Build up list of build options
#   build_opts = ["prefix=#{prefix}"]
#   build_opts << "USE_BLAS64=0"
#   build_opts << "TAGGED_RELEASE_BANNER=\"homebrew-julia release\""
#
#   # Tell julia about our gfortran
#   # (this enables use of gfortran-4.7 from the tap homebrew-dupes/gcc.rb)
#   if ENV.has_key? 'FC'
#     build_opts << "FC=#{ENV['FC']}"
#   end
#
#   # Tell julia about our llvm-config, since it's been named nonstandardly
#   build_opts << "LLVM_CONFIG=llvm-config"
#   build_opts << "LLVM_VER=3.9.1"
#   ENV["CPPFLAGS"] += " -DUSE_ORCJIT "
#
#   # Tell julia where the default software base is, mostly for suitesparse
#   build_opts << "LOCALBASE=#{prefix}"
#
#   # Make sure we have space to muck around with RPATHS
#   ENV['LDFLAGS'] += " -headerpad_max_install_names"
#
#   # Make sure Julia uses clang if the environment supports it
#   build_opts << "USECLANG=1" if ENV.compiler == :clang
#   build_opts << "VERBOSE=1" if ARGV.verbose?
#
#   build_opts << "LIBBLAS=-lopenblas"
#   build_opts << "LIBBLASNAME=libopenblas"
#   build_opts << "LIBLAPACK=-lopenblas"
#   build_opts << "LIBLAPACKNAME=libopenblas"
#
#
#
#   # Run julia-provided test suite, copied over in install step
#   if not (share + 'julia/test').exist?
#     err = "Could not find test files directory\n"
#     if build.head?
#       err << "Did you accidentally include --HEAD in the test invocation?"
#     else
#       err << "Did you mean to include --HEAD in the test invocation?"
#     end
#     opoo err
#   else
#     system "#{bin}/julia", "-e", "Base.runtests(\"core\")"
#   end
# end
#
#
#
#     # ENV.delete('CC')
#     # ENV.delete('LD')
#     system "xcodebuild", "-configuration", "Release", "install", "PREFIX=#{prefix}"
#     #, "SYMROOT=build", "DSTROOT=''",
#   end

  # def caveats
  #   head_flag = build.head? ? " --HEAD " : " "
  #   <<-EOS.undent
  #   Documentation and Examples have been installed into:
  #   #{share}/julia
  #
  #   Test suite has been installed into:
  #   #{share}/julia/test
  #
  #   To perform a quick sanity check, run the command:
  #   brew test#{head_flag}-v julia
  #
  #   To crunch through the full test suite, run the command:
  #   #{bin}/julia -e "Base.runtests()"
  #   EOS
  # end

end
#
#
# __END__
# diff --git a/common.mk b/common.mk
# index 424109b..03cf9b9 100644
# --- a/common.mk
# +++ b/common.mk
# @@ -1,8 +1,8 @@
#  ###
#  ### Common makefile variables potentially set by autoconf
#  ###
# -PREFIX?=/usr/local
# -DESTDIR?=$(DSTROOT)
# +PREFIX?=$(INSTALL)
# +DESTDIR?=$(STAGE)
#
#  ### makefile variables normally set by XBS
#  SRCROOT?=.
# @@ -15,9 +15,9 @@ BINDIR=$(DESTDIR)$(PREFIX)/bin
#  DATDIR=$(DESTDIR)$(PREFIX)/share
#  INCDIR=$(DESTDIR)$(PREFIX)/include
#  INSTALL=install
# -INSTALL_EXE_FLAGS=-m 0755 -o root -g wheel
# +INSTALL_EXE_FLAGS=-m 0755 -o $(shell id -u) -g $(shell id -g)
#  INSTALL_DIR_FLAGS=$(INSTALL_EXE_FLAGS)
# -INSTALL_DOC_FLAGS=-m 0644 -o root -g wheel
# +INSTALL_DOC_FLAGS=-m 0644 -o $(shell id -u) -g $(shell id -g)
#
#  SED=/usr/bin/sed
