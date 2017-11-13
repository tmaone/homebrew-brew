class Mfish < Formula
	desc "User-friendly command-line shell for UNIX-like operating systems"
	homepage "https://fishshell.com"

	head do
		url "https://github.com/fish-shell/fish-shell.git", :shallow => true
	end

	ARGV << "--HEAD"
	ARGV << "--env=std"
	ARGV << "--verbose"

	depends_on "doxygen" => :build
	depends_on "pcre2" => :build
	depends_on "homebrew/core/ncurses" => :build
	depends_on "cmake" => :build
	depends_on "pkg-config" => :build
	depends_on "pcre2"
	depends_on "homebrew/core/ncurses"
	depends_on :python3
	depends_on "llvm" => :build
	depends_on "ninja" => :build

	needs :cxx11

	def install

		# ENV.extend(Stdenv)

		ENV["CC"] = "/usr/local/opt/llvm/bin/clang"
		ENV["CXX"] = "/usr/local/opt/llvm/bin/clang++"
		ENV["LD"] = "/usr/local/opt/llvm/bin/ld.ldd"
		ENV["SED"] = "/usr/bin/sed"
		ENV["RANLIB"] = "/usr/local/opt/llvm/bin/llvm-ranlib"
		ENV["AR"] = "/usr/local/opt/llvm/bin/llvm-ar"
		ENV["CXXFLAGS"] = "-std=c++11"

		args = std_cmake_args + %W[
			-G Ninja
			-DCMAKE_OSX_ARCHITECTURES=x86_64
			-DCMAKE_BUILD_TYPE=Release
			-DCMAKE_INSTALL_PREFIX=#{prefix}
			-DCMAKE_AR=/usr/local/opt/llvm/bin/llvm-ar
			-DCMAKE_RANLIB=/usr/local/opt/llvm/bin/llvm-ranlib
			-Dextra_completionsdir=#{HOMEBREW_PREFIX}/share/fish/vendor_completions.d
			-Dextra_functionsdir=#{HOMEBREW_PREFIX}/share/fish/vendor_functions.d
			-Dextra_confdir=#{HOMEBREW_PREFIX}/share/fish/vendor_conf.d
		]

		mkdir "build" do
			system "cmake", "..", *args
			system "ninja"
			system "ninja", "install"
    end
		# system "autoreconf", "--no-recursive" if build.head?
		# In Homebrew's 'superenv' sed's path will be incompatible, so
		# the correct path is passed into configure here.
		# args = %W[
		# 	--prefix=#{prefix}
		# 	--with-extra-functionsdir=#{HOMEBREW_PREFIX}/share/fish/vendor_functions.d
		# 	--with-extra-completionsdir=#{HOMEBREW_PREFIX}/share/fish/vendor_completions.d
		# 	--with-extra-confdir=#{HOMEBREW_PREFIX}/share/fish/vendor_conf.d
		# 	CC=/usr/local/opt/llvm/bin/clang
		# 	CXX=/usr/local/opt/llvm/bin/clang++
		# 	LD=/usr/local/opt/llvm/bin/ld.ldd
		# 	SED=/usr/bin/sed
		# ]
    #
		# system "./configure", *args
		# system "make", "install"
	end

	def caveats; <<~EOS
		You will need to add:
			#{HOMEBREW_PREFIX}/bin/fish
		to /etc/shells.

		Then run:
			chsh -s #{HOMEBREW_PREFIX}/bin/fish
		to make fish your default shell.
		EOS
	end

	def post_install
		(pkgshare/"vendor_functions.d").mkpath
		(pkgshare/"vendor_completions.d").mkpath
		(pkgshare/"vendor_conf.d").mkpath
	end

	test do
		system "#{bin}/fish", "-c", "echo"
	end
end
