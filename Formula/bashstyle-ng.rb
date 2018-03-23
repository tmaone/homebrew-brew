class BashstyleNg < Formula
  include Language::Python::Virtualenv

  desc "BashStyle-NG: spice up your BASH. ...and readline, vim, nano... "
  homepage "http://nanolx.org/nanolx/bashstyle-ng"
  url "https://github.com/Nanolx/bashstyle-ng/archive/master.tar.gz"
  version "10.0"
  # sha256 :no_check # "cadb68d50fccf58a41fa17270ddb41e66b09cfb2a5876e755c6178c3049d0d7e"

  # fatal false

  depends_on "gtk+3"
  depends_on "gtk-mac-integration"
  depends_on "gobject-introspection"
  depends_on "gettext"
  depends_on "coreutils"
  depends_on "texinfo"
  depends_on "gawk"
  depends_on "ffmpeg"
  depends_on "dpkg"
  depends_on "flex"
  depends_on "tree"
  depends_on "lsusb"
  depends_on "wget"
  depends_on "gnu-sed"
  depends_on "ghostscript"
  depends_on "xmlindent"

  depends_on "python3"
  # depends_on "python-gettext" => :python
  # depends_on "configobj" => :python
  # depends_on "shutil" => :python

  resource "python-gettext" do
   url "https://pypi.python.org/packages/80/a7/a4a5cf3aa9500dbb09b48dae6d4d9581883dd90ae7a84cbb2d3448410114/python-gettext-3.0.zip"
   sha256 "f40540324edc600e33df7aaf840aec7a4021d3b0615830918c231eb1d7163456"
  end

  resource "configobj" do
   url "https://pypi.python.org/packages/64/61/079eb60459c44929e684fa7d9e2fdca403f67d64dd9dbac27296be2e0fab/configobj-5.0.6.tar.gz"
   sha256 "a2f5650770e1c87fb335af19a9b7eb73fc05ccf22144eb68db7d00cd2bcb0902"
  end

  def install
    ENV["GIRPATH"] = "/usr/local/lib/girepository-1.0"
    ENV["PATH"] = "#{HOMEBREW_PREFIX}/opt/gnu-sed/bin:#{ENV["PATH"]}:#{HOMEBREW_PREFIX}/share/android-sdk/build-tools/25.0.2"
    ENV["PYTHONPATH"] = "/usr/local/lib/python3.6/site-packages"
    ENV["EUID"] = "0"
    # Remove unrecognized options if warned by configure
    venv = virtualenv_create(libexec, "python3")
    venv.pip_install resources
    # venv.link_scripts(bin) { venv.pip_install buildpath }
    # venv.pip_install resources
    # system "cmake", ".", *std_cmake_args
    # system "./configure", "--python=/usr/local/opt/python3/bin/python3"
    system "./configure", "--prefix=#{prefix}", "--pcdir=#{prefix}/share/pkgconfig", "--datadir=#{prefix}/share", "--bindir=#{prefix}/bin", "--docdir=#{prefix}/share/doc/", "--mandir=#{prefix}/share/man/"
    inreplace ".configure/results" do |s|
      s.gsub! "/usr/share", "/usr/local/Cellar/bashstyle-ng/10.0/share"
    end
    system "./make", "build" # if this fails, try separate make/make install steps
    system "./make", "install" # if this fails, try separate make/make install steps
  end
  
  def post_install
    system "#{Formula["gtk+3"].opt_bin}/gtk3-update-icon-cache", "-f", "-t", "#{HOMEBREW_PREFIX}/share/icons/hicolor"
    system "#{Formula["shared-mime-info"].opt_bin}/update-mime-database", "#{HOMEBREW_PREFIX}/share/mime"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test bashstyle-ng`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
