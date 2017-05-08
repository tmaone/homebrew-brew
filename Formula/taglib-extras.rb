# 2012-07/14:jeff
#
# =>        taglib-extras.rb
#
# Homebrew formula for the taglib-extras package
# from https://github.com/i8degrees/homebrew-formulae/blob/master/Formula/experimental/taglib-extras.rb

require 'formula'

class TaglibExtras < Formula
  url 'svn://anonsvn.kde.org/home/kde/trunk/kdesupport/taglib-extras'
  homepage 'https://websvn.kde.org/trunk/kdesupport/taglib-extras/'

  depends_on 'cmake' => :build
  depends_on 'taglib'
	depends_on 'zlib'

  def install
		ENV["LDFLAGS"] = "-lz"
    cmake_args = std_cmake_args
    cmake_args << "-DCMAKE_INSTALL_PREFIX=#{prefix}"
    cmake_args << "."

    system "cmake", *cmake_args
		system "make", "install"

    doc.install ['AUTHORS', 'COPYING.LGPL', 'ChangeLog']
  end

  def test
    system "true" # TODO
  end
end