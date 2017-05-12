require 'formula'

class Counterpart < Formula
  homepage 'http://jedda.me/counterpart'
  url 'https://github.com/tmaone/Counterpart/archive/master.tar.gz'
 # sha1 '98dbdf7e21f491d8bf7012af0ed05630c57c922b'
	version '1.2.1'
  depends_on 'rsync'

  def install
    (bin).install "counterpart"
  end
end