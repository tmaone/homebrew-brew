class Sparsehash < Formula
  desc "Extremely memory-efficient hash_map implementation"
  homepage "https://github.com/sparsehash/sparsehash"
  url "https://github.com/sparsehash/sparsehash.git"

  head do

    url "https://github.com/sparsehash/sparsehash.git"

    resource "sparsepp" do
      url "https://github.com/greg7mdp/sparsepp.git"
    end

  end

  def install


    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"

  end


end
