class Radius < Formula
  desc "High-performance and highly configurable RADIUS server"
  homepage "https://freeradius.org/"
  url "https://github.com/FreeRADIUS/freeradius-server/archive/v4.0.x.tar.gz"
  sha256 "fcc9fdffb5a399218e6b34c468a5fee6bcabbced170a158766aa99fec6d08ea2"
  head "https://github.com/FreeRADIUS/freeradius-server.git"

  depends_on "openssl"
  depends_on "talloc"
	depends_on "openldap"
	depends_on "mariadb"
	depends_on "pcre"
	depends_on "pkg-config" => :build

  def install
    ENV.deparallelize

    args = %W[
      --prefix=#{prefix}
      --sbindir=#{bin}
      --localstatedir=#{var}
      --with-openssl-includes=#{Formula["openssl"].opt_include}
      --with-openssl-libraries=#{Formula["openssl"].opt_lib}
      --with-talloc-lib-dir=#{Formula["talloc"].opt_lib}
      --with-talloc-include-dir=#{Formula["talloc"].opt_include}
		  --with-experimental-modules
    ]

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  def post_install
    (var/"run/radiusd").mkpath
    (var/"log/radius").mkpath
  end

  test do
    output = shell_output("#{bin}/smbencrypt homebrew")
    assert_match "77C8009C912CFFCF3832C92FC614B7D1", output
  end
end

