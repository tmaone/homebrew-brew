class ShairportSync < Formula
  desc "AirTunes emulator that adds multi-room capability"
  homepage "https://github.com/mikebrady/shairport-sync"
  url "https://github.com/mikebrady/shairport-sync/archive/3.1.4.tar.gz"
  sha256 "4c5a2ab40ef49896f5b6e59b20df4f621ebce47ee64d8571336f59820ae66379"
  head "https://github.com/mikebrady/shairport-sync.git", :branch => "development"

  bottle do
    sha256 "6a9a583ac9762accefd763a1da03780b1379dbf195016186543d341baf78151b" => :high_sierra
    sha256 "7295bb44ed4cb087e4ab07d1b146b955982e93e099320bfefb671f2fbeeddfcc" => :sierra
    sha256 "3ffa9e0965500ecfd2a673d99030af823a8b9b55df98b84b634d049150178466" => :el_capitan
  end

  depends_on "pkg-config" => :build
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "openssl"
  depends_on "popt"
  depends_on "libsoxr"
  depends_on "libao"
  depends_on "libdaemon"
  depends_on "libconfig"
  depends_on "pulseaudio"

	ARGV << "--build-from-source"
	ARGV << "--env=std"
	ARGV << "--verbose"


  def install
    system "autoreconf", "-fvi"
    args = %W[
      --with-os=darwin
      --with-ssl=openssl
      --with-dns_sd
      --with-ao
      --with-stdout
      --with-pipe
      --with-soxr
      --with-metadata
      --with-pkg-config
      --with-piddir=#{var}/run
      --sysconfdir=#{etc}/shairport-sync
      --prefix=#{prefix}
    ]
    system "./configure", *args
    system "make", "install"
  end

  def post_install
    (var/"run").mkpath
  end

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
        <key>ProgramArguments</key>
        <array>
            <string>#{opt_bin}/shairport-sync</string>
            <string>--verbose</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
        <key>ProcessType</key>
        <string>Interactive</string>
    </dict>
    </plist>
    EOS
  end

  test do
    output = shell_output("#{bin}/shairport-sync -V", 1)
    assert_match "OpenSSL-ao-stdout-pipe-soxr-metadata", output
  end
end
