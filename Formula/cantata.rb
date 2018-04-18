# 2012-07/14:jeff
#
# =>        cantata.rb
#
# Homebrew formula for the Cantata MPD client
#
# =>        NOTES
#
# 1. svn checkout http://cantata.googlecode.com/svn/trunk/ cantata-read-only
# from https://github.com/i8degrees/homebrew-formulae/blob/master/Formula/experimental/cantata.rb

require 'formula'

class Cantata < Formula

  url 'https://github.com/CDrummond/cantata.git'
  homepage 'https://github.com/CDrummond/cantata'
  head "https://github.com/CDrummond/cantata.git"
  
  version '2.2.0'

  depends_on 'cmake' => :build
  depends_on 'libmtp'
  depends_on 'ffmpeg'
  depends_on 'qt5'
  depends_on 'speex'
  depends_on 'mpg123'
  depends_on 'taglib'
  depends_on 'taglib-extras'
	depends_on 'zlib'

  def install
		ENV["LDFLAGS"] = "-lz"
    cmake_args = std_cmake_args
    cmake_args << "-DCMAKE_INSTALL_PREFIX=#{prefix}"
    cmake_args << "-DENABLE_DEVICES_SUPPORT=NO"
    cmake_args << "-DENABLE_FFMPEG=YES"
    cmake_args << "-DENABLE_HTTP_SERVER=YES"
    cmake_args << "-DENABLE_HTTP_STREAM_PLAYBACK=YES"
    cmake_args << "-DENABLE_MPG123=YES"
    cmake_args << "-DENABLE_MTP=YES"
    cmake_args << "-DENABLE_REMOTE_DEVICES=YES"
    cmake_args << "-DENABLE_TAGLIB=YES"
    cmake_args << "-DENABLE_TAGLIB_EXTRAS=YES"
    cmake_args << "-DENABLE_UDISKS2=NO"
    cmake_args << "-DENABLE_REMOTE_DEVICES=YES"
    cmake_args << "."

    system "cmake", *cmake_args
    system "make install"

    doc.install ['AUTHORS', 'ChangeLog', 'INSTALL', 'LICENSE', 'README', 'TODO']
  end

  def test
    system "true" # TODO
  end
end
