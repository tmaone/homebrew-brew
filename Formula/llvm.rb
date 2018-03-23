class CodesignRequirement < Requirement
  fatal true

  satisfy(:build_env => false) do
    FileUtils.mktemp do
      FileUtils.cp "/usr/bin/false", "llvm_check"
      quiet_system "/usr/bin/codesign", "-f", "-s", "lldb_codesign", "--dryrun", "llvm_check"
    end
  end

  def message
    <<~EOS
    lldb_codesign identity must be available to build with LLDB.
    See: https://llvm.org/svn/llvm-project/lldb/trunk/docs/code-signing.txt
    EOS
  end
end

class Llvm < Formula
  desc "Next-gen compiler infrastructure"
  homepage "https://llvm.org/"

  stable do
    url "https://releases.llvm.org/6.0.0/llvm-6.0.0.src.tar.xz"
    sha256 "1ff53c915b4e761ef400b803f07261ade637b0c269d99569f18040f3dcee4408"

    resource "clang" do
      url "https://releases.llvm.org/6.0.0/cfe-6.0.0.src.tar.xz"
      sha256 "e07d6dd8d9ef196cfc8e8bb131cbd6a2ed0b1caf1715f9d05b0f0eeaddb6df32"
    end

    resource "clang-extra-tools" do
      url "https://releases.llvm.org/6.0.0/clang-tools-extra-6.0.0.src.tar.xz"
      sha256 "053b424a4cd34c9335d8918734dd802a8da612d13a26bbb88fcdf524b2d989d2"
    end

    resource "compiler-rt" do
      url "https://releases.llvm.org/6.0.0/compiler-rt-6.0.0.src.tar.xz"
      sha256 "d0cc1342cf57e9a8d52f5498da47a3b28d24ac0d39cbc92308781b3ee0cea79a"
    end

    # Only required to build & run Compiler-RT tests on macOS, optional otherwise.
    # https://clang.llvm.org/get_started.html
    resource "libcxx" do
      url "https://releases.llvm.org/6.0.0/libcxx-6.0.0.src.tar.xz"
      sha256 "70931a87bde9d358af6cb7869e7535ec6b015f7e6df64def6d2ecdd954040dd9"
    end

    resource "libcxxabi" do
      url "http://releases.llvm.org/6.0.0/libcxxabi-6.0.0.src.tar.xz"
      sha256 "91c6d9c5426306ce28d0627d6a4448e7d164d6a3f64b01cb1d196003b16d641b"
    end

    resource "libunwind" do
      url "https://releases.llvm.org/6.0.0/libunwind-6.0.0.src.tar.xz"
      sha256 "256c4ed971191bde42208386c8d39e5143fa4afd098e03bd2c140c878c63f1d6"
    end

    resource "lld" do
      url "https://releases.llvm.org/6.0.0/lld-6.0.0.src.tar.xz"
      sha256 "6b8c4a833cf30230c0213d78dbac01af21387b298225de90ab56032ca79c0e0b"
    end

    resource "lldb" do
      url "https://releases.llvm.org/6.0.0/lldb-6.0.0.src.tar.xz"
      sha256 "46f54c1d7adcd047d87c0179f7b6fa751614f339f4f87e60abceaa45f414d454"
    end

    resource "openmp" do
      url "https://releases.llvm.org/6.0.0/openmp-6.0.0.src.tar.xz"
      sha256 "7c0e050d5f7da3b057579fb3ea79ed7dc657c765011b402eb5bbe5663a7c38fc"
    end

    resource "polly" do
      url "https://releases.llvm.org/6.0.0/polly-6.0.0.src.tar.xz"
      sha256 "47e493a799dca35bc68ca2ceaeed27c5ca09b12241f87f7220b5f5882194f59c"
    end

    resource "binary" do
      url "http://releases.llvm.org/6.0.0/clang+llvm-6.0.0-x86_64-apple-darwin.tar.xz"
      sha256 "0ef8e99e9c9b262a53ab8f2821e2391d041615dd3f3ff36fdf5370916b0f4268"
    end

  end

  bottle do
    cellar :any
    sha256 "6e8c461f99e8b2725bb9c34d7fc548490f1e74f162f75f3670e0bd759dcbd473" => :high_sierra
    sha256 "3603e0a48860d079c9cdf32c6f65f87758bbfca4ab9aa6e2eb8b4d47a7751688" => :sierra
    sha256 "2ce6aed36aab360b9ec09c094727c76c6620bcf201802f5d5d59035c7e6c80f2" => :el_capitan
  end

  head do

    url "https://llvm.org/git/llvm.git"

    resource "clang" do
      url "https://llvm.org/git/clang.git"
    end

    resource "clang-extra-tools" do
      url "https://llvm.org/git/clang-tools-extra.git"
    end

    resource "compiler-rt" do
      url "https://llvm.org/git/compiler-rt.git"
    end

    resource "libcxx" do
      url "https://llvm.org/git/libcxx.git"
    end

    resource "libcxxabi" do
      url "https://llvm.org/git/libcxxabi.git"
    end

    resource "libunwind" do
      url "https://llvm.org/git/libunwind.git"
    end

    resource "lld" do
      url "https://llvm.org/git/lld.git"
    end

    resource "lldb" do
      url "https://llvm.org/git/lldb.git"
    end

    resource "openmp" do
      url "https://llvm.org/git/openmp.git"
    end

    resource "polly" do
      url "https://llvm.org/git/polly.git"
    end

  end

  # keg_only :provided_by_macos

  option "with-toolchain", "Build with Toolchain to facilitate overriding system compiler"
  option "with-shared-libs", "Build shared instead of static libraries"
  option "with-lldb", "Build lldb"
  option "with-binary", "Fetch binary release from LLVM"

  depends_on "cmake" => :build
  depends_on "libffi" => :build
  depends_on "pkg-config" => :build
  depends_on "graphviz"
  depends_on "python" => :build
  depends_on "ninja" => :build

  if build.with? "lldb"
    depends_on "swig" if MacOS.version >= :lion
    depends_on CodesignRequirement
  end

  # According to the official llvm readme, GCC 4.7+ is required
  fails_with :gcc_4_0
  fails_with :gcc
  ("4.3".."4.6").each do |n|
    fails_with :gcc => n
  end

  def install

    if !build.with? "binary"

      # Apple's libstdc++ is too old to build LLVM
      ENV.libcxx if ENV.compiler == :clang
      ENV.permit_arch_flags
      ENV.prepend_path "PATH", Formula["python"].opt_bin/"bin"

      (buildpath/"tools/clang").install resource("clang")
      (buildpath/"tools/clang/tools/extra").install resource("clang-extra-tools")
      (buildpath/"projects/openmp").install resource("openmp")
      (buildpath/"projects/libcxx").install resource("libcxx")
      (buildpath/"projects/libcxxabi").install resource("libcxxabi")
      (buildpath/"projects/libunwind").install resource("libunwind")
      (buildpath/"tools/lld").install resource("lld")
      (buildpath/"tools/polly").install resource("polly")
      (buildpath/"projects/compiler-rt").install resource("compiler-rt")

      if build.with? "lldb"
        pyhome = `python-config --prefix`.chomp
        ENV["PYTHONHOME"] = pyhome
        pylib = "#{pyhome}/lib/libpython3.6.dylib"
        pyinclude = "#{pyhome}/include/python3.6m"
        (buildpath/"tools/lldb").install resource("lldb")

        # Building lldb requires a code signing certificate.
        # The instructions provided by llvm creates this certificate in the
        # user's login keychain. Unfortunately, the login keychain is not in
        # the search path in a superenv build. The following three lines add
        # the login keychain to ~/Library/Preferences/com.apple.security.plist,
        # which adds it to the superenv keychain search path.
        mkdir_p "#{ENV["HOME"]}/Library/Preferences"
        username = ENV["USER"]
        system "security", "list-keychains", "-d", "user", "-s", "/Users/#{username}/Library/Keychains/login.keychain"
      end

      args = %w[
        -DLLVM_OPTIMIZED_TABLEGEN=ON
        -DLLVM_INCLUDE_DOCS=OFF
        -DLLVM_ENABLE_RTTI=ON
        -DLLVM_ENABLE_EH=ON
        -DLLVM_INSTALL_UTILS=ON
        -DWITH_POLLY=ON
        -DLINK_POLLY_INTO_TOOLS=ON
        -DLLVM_TARGETS_TO_BUILD=all
      ]

      args << "-DLIBOMP_ARCH=x86_64"
      args << "-DLLVM_BUILD_EXTERNAL_COMPILER_RT=ON"
      args << "-DLLVM_CREATE_XCODE_TOOLCHAIN=OFF"
      args << "-DLLVM_BUILD_LLVM_DYLIB=OFF"
      args << "-DLLVM_ENABLE_LIBCXX=ON"
      args << "-DLLVM_ENABLE_LIBCXXABI=ON"
      args << "-DLLVM_ENABLE_ASSERTIONS=OFF"
      args << "-DLLVM_ENABLE_THREADS=ON"

      if build.with?("lldb") && build.with?("python")
        args << "-DLLDB_RELOCATABLE_PYTHON=ON"
        args << "-DPYTHON_LIBRARY=#{pylib}"
        args << "-DPYTHON_INCLUDE_DIR=#{pyinclude}"
        args << "-DPYTHON_EXECUTABLE=/usr/local/bin/python"
      end

      args << "-DLLVM_ENABLE_FFI=ON"
      args << "-DFFI_INCLUDE_DIR=#{Formula["libffi"].opt_lib}/libffi-#{Formula["libffi"].version}/include"
      args << "-DFFI_LIBRARY_DIR=#{Formula["libffi"].opt_lib}"

      mktemp do
        system "cmake", "-G", "Ninja", buildpath, *(std_cmake_args + args)
        system "ninja"
        system "ninja", "install"
        # system "ninja", "install-xcode-toolchain"
      end

      (share/"clang/tools").install Dir["tools/clang/tools/scan-{build,view}"]
      (share/"cmake").install "cmake/modules"
      inreplace "#{share}/clang/tools/scan-build/bin/scan-build", "$RealBin/bin/clang", "#{bin}/clang"
      bin.install_symlink share/"clang/tools/scan-build/bin/scan-build", share/"clang/tools/scan-view/bin/scan-view"
      man1.install_symlink share/"clang/tools/scan-build/man/scan-build.1"

      # install llvm python bindings
      (lib/"python3.6/site-packages").install buildpath/"bindings/python/llvm"
      (lib/"python3.6/site-packages").install buildpath/"tools/clang/bindings/python/clang"
    end

  else

    resource("binary").stage do
       cp_r Dir["*"], prefix
    end

  end

  def caveats
    <<~EOS
    To use the bundled libc++ please add the following LDFLAGS:
    LDFLAGS="-L#{opt_lib} -Wl,-rpath,#{opt_lib}"
    EOS
  end

  test do
    # Testing Command Line Tools
    if MacOS::CLT.installed?
      libclangclt = Dir["/Library/Developer/CommandLineTools/usr/lib/clang/#{MacOS::CLT.version.to_i}*"].last { |f| File.directory? f }

      system "#{bin}/clang++", "-v", "-nostdinc",
      "-I/Library/Developer/CommandLineTools/usr/include/c++/v1",
      "-I#{libclangclt}/include",
      "-I/usr/include", # need it because /Library/.../usr/include/c++/v1/iosfwd refers to <wchar.h>, which CLT installs to /usr/include
      "test.cpp", "-o", "testCLT++"
      assert_includes MachO::Tools.dylibs("testCLT++"), "/usr/lib/libc++.1.dylib"
      assert_equal "Hello World!", shell_output("./testCLT++").chomp

      system "#{bin}/clang", "-v", "-nostdinc",
      "-I/usr/include", # this is where CLT installs stdio.h
      "test.c", "-o", "testCLT"
      assert_equal "Hello World!", shell_output("./testCLT").chomp
    end

    # Testing Xcode
    if MacOS::Xcode.installed?
      libclangxc = Dir["#{MacOS::Xcode.toolchain_path}/usr/lib/clang/#{DevelopmentTools.clang_version}*"].last { |f| File.directory? f }

      system "#{bin}/clang++", "-v", "-nostdinc",
      "-I#{MacOS::Xcode.toolchain_path}/usr/include/c++/v1",
      "-I#{libclangxc}/include",
      "-I#{MacOS.sdk_path}/usr/include",
      "test.cpp", "-o", "testXC++"
      assert_includes MachO::Tools.dylibs("testXC++"), "/usr/lib/libc++.1.dylib"
      assert_equal "Hello World!", shell_output("./testXC++").chomp

      system "#{bin}/clang", "-v", "-nostdinc",
      "-I#{MacOS.sdk_path}/usr/include",
      "test.c", "-o", "testXC"
      assert_equal "Hello World!", shell_output("./testXC").chomp
    end

    # link against installed libc++
    # related to https://github.com/Homebrew/legacy-homebrew/issues/47149
    if build_libcxx?
      system "#{bin}/clang++", "-v", "-nostdinc",
      "-std=c++11", "-stdlib=libc++",
      "-I#{MacOS::Xcode.toolchain_path}/usr/include/c++/v1",
      "-I#{libclangxc}/include",
      "-I#{MacOS.sdk_path}/usr/include",
      "-L#{lib}",
      "-Wl,-rpath,#{lib}", "test.cpp", "-o", "test"
      assert_includes MachO::Tools.dylibs("test"), "#{opt_lib}/libc++.1.dylib"
      assert_equal "Hello World!", shell_output("./test").chomp
    end

  end

end
