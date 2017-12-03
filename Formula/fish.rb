class Fish < Formula
	desc "User-friendly command-line shell for UNIX-like operating systems"
	homepage "https://fishshell.com"

	head do
		url "https://github.com/fish-shell/fish-shell.git", :shallow => true
		depends_on "autoconf" => :build
		depends_on "automake" => :build
		depends_on "cmake" => :build
		depends_on "doxygen" => :build
		depends_on "llvm" => :build
		depends_on "ninja" => :build
		depends_on "homebrew/core/ncurses" => :build
		depends_on "pcre2" => :build
		depends_on "pkg-config" => :build
		depends_on :python3 => :build
	end

	ARGV << "--HEAD"
	# ARGV << "--env=std"
	ARGV << "--verbose"

	depends_on "pcre2"
	depends_on "homebrew/core/ncurses"
	depends_on :python3

	needs :cxx11

	def install

		ENV["SED"] = "/usr/bin/sed"
		ENV["CXXFLAGS"] = "-std=c++11"

		ENV["CC"] = "/usr/local/opt/llvm/bin/clang"
		ENV["CXX"] = "/usr/local/opt/llvm/bin/clang++"
		ENV["LD"] = "/usr/local/opt/llvm/bin/ld.ldd"
		ENV["RANLIB"] = "/usr/local/opt/llvm/bin/llvm-ranlib"
		ENV["AR"] = "/usr/local/opt/llvm/bin/llvm-ar"
		ENV["OBJDUMP"] = "/usr/local/opt/llvm/bin/llvm-objdump"
		ENV["NM"] = "/usr/local/opt/llvm/bin/llvm-nm"
		# -DCMAKE_RANLIB=/usr/local/opt/llvm/bin/llvm-ranlib
		# -DCMAKE_AR=/usr/local/opt/llvm/bin/llvm-ar

		args = std_cmake_args + %W[
			-G Ninja
			-DCMAKE_OSX_ARCHITECTURES=x86_64
			-DCMAKE_BUILD_TYPE=Release
			-DWITH_GETTEXT=OFF
			-DCMAKE_INSTALL_PREFIX=#{prefix}
			-DCMAKE_RANLIB=#{ENV["RANLIB"]}
			-DCMAKE_AR=#{ENV["AR"]}
			-DCMAKE_OBJDUMP=#{ENV["OBJDUMP"]}
			-DCMAKE_NM=#{ENV["NM"]}
			-DSED=#{ENV["SED"]}
			-DCMAKE_EXPORT_COMPILE_COMMANDS=ON
			-Dextra_completionsdir=#{HOMEBREW_PREFIX}/share/fish/vendor_completions.d
			-Dextra_functionsdir=#{HOMEBREW_PREFIX}/share/fish/vendor_functions.d
			-Dextra_confdir=#{HOMEBREW_PREFIX}/share/fish/vendor_conf.d
		]

		mkdir "build" do
			system "cmake", "..", *args
			system "ninja"
			system "ninja", "doc"
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
