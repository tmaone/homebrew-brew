class fish < Formula
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
  depends_on "gettext" => :build
	depends_on "pcre2"
	depends_on "homebrew/core/ncurses"
	depends_on :python3
	depends_on "llvm" => :build
	depends_on "ninja" => :build

	needs :cxx11

	def install

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
      -DWITH_GETTEXT=OFF
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
