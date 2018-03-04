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
    url "http://prereleases.llvm.org/6.0.0/rc3/llvm-6.0.0rc3.src.tar.xz"
    sha256 "8af454fc8b2c1b12b5ea06b192d9cd601623ac19fdebea95c6f1cf37d3c91c83"

    resource "clang" do
      url "http://prereleases.llvm.org/6.0.0/rc3/cfe-6.0.0rc3.src.tar.xz"
      sha256 "03a1ef6afd35057f38ea6882f9e5c41c47de95bf626e9ef53a5efecf4611bddb"
    end

    resource "clang-extra-tools" do
      url "http://prereleases.llvm.org/6.0.0/rc3/clang-tools-extra-6.0.0rc3.src.tar.xz"
      sha256 "8ecea22b939cc2581cab25752f5635208dd8ab37d5c742bba040eacb10cd6763"
    end

    resource "compiler-rt" do
      url "http://prereleases.llvm.org/6.0.0/rc3/compiler-rt-6.0.0rc3.src.tar.xz"
      sha256 "9bd30c7cf2f815751ad0e10b216925b0d9760f11d84e79948e5703cbb9ea65d3"
    end

    # Only required to build & run Compiler-RT tests on macOS, optional otherwise.
    # https://clang.llvm.org/get_started.html
    resource "libcxx" do
      url "http://prereleases.llvm.org/6.0.0/rc3/libcxx-6.0.0rc3.src.tar.xz"
      sha256 "4a479c45fce60f4029fe88fcac4c18f6fad7a5bfdca16057f78d23547adf76b7"
    end

    resource "libcxxabi" do
      url "http://prereleases.llvm.org/6.0.0/rc3/libcxxabi-6.0.0rc3.src.tar.xz"
      sha256 "19d86438483980787d753a6c3ba84a8d4b278ddde0d2487133997716d4e1a112"
    end

    resource "libunwind" do
      url "http://prereleases.llvm.org/6.0.0/rc3/libunwind-6.0.0rc3.src.tar.xz"
      sha256 "aa4981ddd54c6c7d8dbdf83756eda65f1cc07f86a6eb36623bb4fb9b6d11269c"
    end

    resource "lld" do
      url "http://prereleases.llvm.org/6.0.0/rc3/lld-6.0.0rc3.src.tar.xz"
      sha256 "28796f5066f9c1ffcb06eec7c3b269417173ddf57c43f0f55876ce3144fcdf9a"
    end

    resource "lldb" do
      url "http://prereleases.llvm.org/6.0.0/rc3/lldb-6.0.0rc3.src.tar.xz"
      sha256 "f407c517bec1ab233aeeb9f0e6f2e25387125f870f6d560190af855f759ff301"

      # Fixes "error: no type named 'pid_t' in the global namespace"
      # https://github.com/Homebrew/homebrew-core/issues/17839
      # Already fixed in upstream trunk
      patch do
        url "https://github.com/llvm-mirror/lldb/commit/324f93b5e30.patch?full_index=1"
        sha256 "f23fc92c2d61bf6c8bc6865994a75264fafba6ae435e4d2f4cc8327004523fb1"
      end
    end

    resource "openmp" do
      url "http://prereleases.llvm.org/6.0.0/rc3/openmp-6.0.0rc3.src.tar.xz"
      sha256 "b3e828599c836eb131d61b90d5fda794918157015934ebb128ac569dc1b1fad1"
    end

    resource "polly" do
      url "http://prereleases.llvm.org/6.0.0/rc3/polly-6.0.0rc3.src.tar.xz"
      sha256 "562b4836461274662e9fadc3e718ad863c51114323362cb088c1bffd0cfd2d2d"
    end
  end

  bottle do
    cellar :any
    rebuild 1
    sha256 "61c8f073f3fc25971ead1a106f4db95db08b4ba0cd1eb7df7c40f6a2ee74dfbb" => :high_sierra
    sha256 "da1ffc015d980daaa72affabbadfa4b1b821989f50ea14f5fea7d799eee018e8" => :sierra
    sha256 "54c1d217622fd298186bad4af680d2ac3aafc237948d581ad1ecb221bc293b38" => :el_capitan
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

  keg_only :provided_by_macos

  option "without-compiler-rt", "Do not build Clang runtime support libraries for code sanitizers, builtins, and profiling"
  option "without-libcxx", "Do not build libc++ standard library"
  option "with-toolchain", "Build with Toolchain to facilitate overriding system compiler"
  option "with-lldb", "Build LLDB debugger"
  option "with-python", "Build bindings against custom Python"
  option "with-shared-libs", "Build shared instead of static libraries"
  option "without-libffi", "Do not use libffi to call external functions"

  # https://llvm.org/docs/GettingStarted.html#requirement
  depends_on "libffi" => :recommended

  # for the 'dot' tool (lldb)
  depends_on "graphviz" => :optional

  depends_on "ocaml" => :optional
  if build.with? "ocaml"
    depends_on "opam" => :build
    depends_on "pkg-config" => :build
  end

  if MacOS.version <= :snow_leopard
    depends_on "python"
  else
    depends_on "python" => :optional
  end
  depends_on "cmake" => :build

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

  def build_libcxx?
    build.with?("libcxx") || !MacOS::CLT.installed?
  end

  def install
    # Apple's libstdc++ is too old to build LLVM
    ENV.libcxx if ENV.compiler == :clang

    if build.with? "python"
      ENV.prepend_path "PATH", Formula["python"].opt_libexec/"bin"
    end

    (buildpath/"tools/clang").install resource("clang")
    (buildpath/"tools/clang/tools/extra").install resource("clang-extra-tools")
    (buildpath/"projects/openmp").install resource("openmp")
    (buildpath/"projects/libcxx").install resource("libcxx")
    (buildpath/"projects/libcxxabi").install resource("libcxxabi")
    (buildpath/"projects/libunwind").install resource("libunwind")
    (buildpath/"tools/lld").install resource("lld")
    (buildpath/"tools/polly").install resource("polly")

    if build.with? "lldb"
      if build.with? "python"
        pyhome = `python-config --prefix`.chomp
        ENV["PYTHONHOME"] = pyhome
        pylib = "#{pyhome}/lib/libpython2.7.dylib"
        pyinclude = "#{pyhome}/include/python2.7"
      end
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

    # if build.with? "compiler-rt"
      (buildpath/"projects/compiler-rt").install resource("compiler-rt")

      # compiler-rt has some iOS simulator features that require i386 symbols
      # I'm assuming the rest of clang needs support too for 32-bit compilation
      # to work correctly, but if not, perhaps universal binaries could be
      # limited to compiler-rt. llvm makes this somewhat easier because compiler-rt
      # can almost be treated as an entirely different build from llvm.
      ENV.permit_arch_flags
    # end

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
    args << "-DLLVM_CREATE_XCODE_TOOLCHAIN=ON"
    args << "-DLLVM_BUILD_LLVM_DYLIB=ON"
    args << "-DLLVM_ENABLE_LIBCXX=ON"

    if build.with?("lldb") && build.with?("python")
      args << "-DLLDB_RELOCATABLE_PYTHON=ON"
      args << "-DPYTHON_LIBRARY=#{pylib}"
      args << "-DPYTHON_INCLUDE_DIR=#{pyinclude}"
    end

    args << "-DLLVM_ENABLE_FFI=ON"
    args << "-DFFI_INCLUDE_DIR=#{Formula["libffi"].opt_lib}/libffi-#{Formula["libffi"].version}/include"
    args << "-DFFI_LIBRARY_DIR=#{Formula["libffi"].opt_lib}"

    mktemp do
      if build.with? "ocaml"
        args << "-DLLVM_OCAML_INSTALL_PATH=#{lib}/ocaml"
        ENV["OPAMYES"] = "1"
        ENV["OPAMROOT"] = Pathname.pwd/"opamroot"
        (Pathname.pwd/"opamroot").mkpath
        system "opam", "init", "--no-setup"
        system "opam", "config", "exec", "--",
               "opam", "install", "ocamlfind", "ctypes"
        system "opam", "config", "exec", "--",
               "cmake", "-G", "Unix Makefiles", buildpath, *(std_cmake_args + args)
      else
        system "cmake", "-G", "Unix Makefiles", buildpath, *(std_cmake_args + args)
      end
      system "make"
      system "make", "install"
      system "make", "install-xcode-toolchain" if build.with? "toolchain"
    end

    (share/"clang/tools").install Dir["tools/clang/tools/scan-{build,view}"]
    (share/"cmake").install "cmake/modules"
    inreplace "#{share}/clang/tools/scan-build/bin/scan-build", "$RealBin/bin/clang", "#{bin}/clang"
    bin.install_symlink share/"clang/tools/scan-build/bin/scan-build", share/"clang/tools/scan-view/bin/scan-view"
    man1.install_symlink share/"clang/tools/scan-build/man/scan-build.1"

    # install llvm python bindings
    (lib/"python2.7/site-packages").install buildpath/"bindings/python/llvm"
    (lib/"python2.7/site-packages").install buildpath/"tools/clang/bindings/python/clang"
  end

  def caveats
    if build_libcxx?
      <<~EOS
        To use the bundled libc++ please add the following LDFLAGS:
          LDFLAGS="-L#{opt_lib} -Wl,-rpath,#{opt_lib}"
      EOS
    end
  end

  test do
    assert_equal prefix.to_s, shell_output("#{bin}/llvm-config --prefix").chomp

    (testpath/"omptest.c").write <<~EOS
      #include <stdlib.h>
      #include <stdio.h>
      #include <omp.h>

      int main() {
          #pragma omp parallel num_threads(4)
          {
            printf("Hello from thread %d, nthreads %d\\n", omp_get_thread_num(), omp_get_num_threads());
          }
          return EXIT_SUCCESS;
      }
    EOS

    system "#{bin}/clang", "-L#{lib}", "-fopenmp", "-nobuiltininc",
                           "-I#{lib}/clang/#{version}/include",
                           "omptest.c", "-o", "omptest"
    testresult = shell_output("./omptest")

    sorted_testresult = testresult.split("\n").sort.join("\n")
    expected_result = <<~EOS
      Hello from thread 0, nthreads 4
      Hello from thread 1, nthreads 4
      Hello from thread 2, nthreads 4
      Hello from thread 3, nthreads 4
    EOS
    assert_equal expected_result.strip, sorted_testresult.strip

    (testpath/"test.c").write <<~EOS
      #include <stdio.h>

      int main()
      {
        printf("Hello World!\\n");
        return 0;
      }
    EOS

    (testpath/"test.cpp").write <<~EOS
      #include <iostream>

      int main()
      {
        std::cout << "Hello World!" << std::endl;
        return 0;
      }
    EOS

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
