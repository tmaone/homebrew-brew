class Objconv < Formula
  desc "Convert, modify, dump, and disassemble object files"
  homepage "http://www.agner.org/optimize/"
  head "http://www.agner.org/optimize/objconv.zip"

  #ARGV << "--HEAD"
	#ARGV << "--verbose"
  
  def install
    system "unzip", "source.zip"
    system "/bin/bash", "build.sh"
    bin.install "objconv"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      const char* my_string = "A test string";
      int main(void) { return 0; }
    EOS
    system ENV.cc, "test.c", "-o", "test"
    assert (testpath/"test").exist?, "#{ENV.cc} output failed"

    system "#{bin}/objconv", "-fasm", "test"
    assert (testpath/"test.asm").exist?, "test.asm should exist"
  end
end
