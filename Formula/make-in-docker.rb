class MakeInDocker < Formula
  url      "https://github.com/themalkolm/make-in-docker/archive/v2017.03.15-1.tar.gz"
  version  "2017.03.15-1"
  homepage "https://github.com/themalkolm/make-in-docker"
  head     "https://github.com/themalkolm/make-in-docker.git"
  depends_on "go" => :build

  def install
    gopath = buildpath

    ENV["GOPATH"] = gopath
    ENV.prepend_create_path "PATH", gopath/"bin"

    mkdir_p            gopath/"src/github.com/themalkolm/make-in-docker"
    rm_rf              gopath/"src/github.com/themalkolm/make-in-docker"
    ln_s    buildpath, gopath/"src/github.com/themalkolm/make-in-docker"

    destdir = "dist"
    bindir = "bin"
    mandir = "share"

    system "make", "install", "VERSION=2017.03.15-1", "DESTDIR=#{destdir}", "BINDIR=#{bindir}", "MANDIR=#{mandir}"

    libexec.install Dir["#{destdir}/*"]

    bin.install_symlink  Dir[libexec/bindir/"*"]
    man1.install_symlink Dir[libexec/mandir/"man/man1/*"]
  end
end
