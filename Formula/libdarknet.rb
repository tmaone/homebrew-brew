class Libdarknet < Formula
  desc "Convolutional Neural Networks"
  homepage "http://pjreddie.com/darknet/"
  head "https://github.com/OrKoN/darknet.git"

  depends_on "pkg-config" => :run
  depends_on "opencv@2" => :build

  def install
    system "make", "PREFIX=#{prefix}"
    system "make", "PREFIX=#{prefix}", "install"
  end

  test do
    system "true"
  end
end
