class Grub < Formula
  desc "GNU GRUB is a Multiboot boot loader."
  homepage "https://www.gnu.org/software/grub/index.html"
  url "ftp://ftp.gnu.org/gnu/grub/grub-2.02.tar.xz"
  version "2.02"
  sha256 "810b3798d316394f94096ec2797909dbf23c858e48f7b3830826b8daa06b7b0f"

  head "git://git.savannah.gnu.org/grub.git"

  # ARGV << "--HEAD"
	#ARGV << "--verbose"

  option "with-mkfont", "build and install the 'grub-mkfont' utility"
  option "with-themes", "build and install GRUB themes"
  option "with-lzma", "enable liblzma integration"
  # option "with-zfs", "enable libzfs integration"

  depends_on "tmaone/metap/objconv" => :build
  depends_on "autoconf" if build.head?

  if build.with? "mkfont"
    depends_on "freetype" => :build
  end

  if build.with? "themes"
    depends_on "freetype" => :build
  end

  if build.with? "lzma"
    depends_on "xz" => :build
  end

  #if build.with? "zfs"
  #  depends_on cask: 'openzfs'
  #end

  def install
    system "./autogen.sh" if build.head?
    ENV.deparallelize

    build_opts = ["prefix=#{prefix}"]
    build_opts << "--enable-grub-mkfont" if build.with? "mkfont"
    build_opts << "--enable-grunb-themes" if build.with? "themes"
    build_opts << "--enable-liblzma" if build.with? "lzma"
    build_opts << "--enable-libzfs" if build.with? "zfs"

    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          *build_opts
    system "make", "install"
  end

  test do
    system "true"
  end
end
