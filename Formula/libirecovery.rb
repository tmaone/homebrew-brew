require 'formula'

class Libirecovery < Formula
  homepage 'https://github.com/libimobiledevice/libirecovery.git'
  head 'https://github.com/libimobiledevice/libirecovery.git', :branch => 'master'

  depends_on 'autoconf' => :build
  depends_on 'automake' => :build
  depends_on 'libtool' => :build
  depends_on 'pkg-config' => :build
  depends_on 'libusb'

  def install
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end
  
end