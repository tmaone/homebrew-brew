class Kitty < Formula
  desc "A modern, hackable, featureful, OpenGL based terminal emulator"
  homepage "https://github.com/kovidgoyal/kitty"
  revision 1
  head "https://github.com/kovidgoyal/kitty.git", :using => :git

  depends_on "python3"
  depends_on "glfw"
  depends_on "pkg-config" => :build
	depends_on "harfbuzz" => :build
	depends_on "libpng" => :build

  def install
    unless build.head?
      odie "Only HEAD build is supported at time"
    end

    system "python3", "setup.py", "linux-package",
                                  "--prefix=#{prefix}"
  end

  test do
  end
end
