class Pbzx < Formula
  desc "pbzx"
  homepage "https://github.com/NiklasRosenstein/pbzx"
  url "https://codeload.github.com/NiklasRosenstein/pbzx/zip/master"
  head "https://github.com/NiklasRosenstein/pbzx.git"
	version "0.1"

	patch :p1, :DATA
  def install
    system "clang", "-llzma", "-lxar", "-I/usr/local/include", "pbzx.c", "-o", "pbzx"
    system "mkdir", "-p", "#{prefix}/bin"
    system "cp", "pbzx", "#{prefix}/bin/pbzx"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test pbzx`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "true"
  end
end

__END__
diff --git a/pbzx.c b/pbzx.c
index d01ef35..bd1d066 100644
--- a/pbzx.c
+++ b/pbzx.c
@@ -38,12 +38,13 @@ struct options {
     bool noxar;    /* The input data is not a XAR archive but the pbzx Payload. */
     bool help;     /* Print usage with details and exit. */
     bool version;  /* Print version and exit. */
+    const char * filename;
 };

 /* Prints usage information and exit. Optionally, displays an error message and
  * exits with an error code. */
 static void usage(char const* error) {
-    fprintf(stderr, "usage: pbzx [-v] [-h] [-n] [-] [filename]\n");
+    fprintf(stderr, "usage: pbzx [-v] [-h] [-n] <-|filename>\n");
     if (error) {
         fprintf(stderr, "error: %s\n", error);
         exit(EINVAL);
@@ -70,20 +71,18 @@ static void version() {
 /* Parses command-line flags into the #options structure and adjusts the
  * argument count and values on the fly to remain only positional arguments. */
 static void parse_args(int* argc, char const** argv, struct options* opts) {
-    for (int i = 0; i < *argc; ++i) {
-        /* Skip arguments that are not flags. */
-        if (argv[i][0] != '-') continue;
+
+    opts->filename = NULL;
+
+    for (int i = 1; i < *argc; ++i) {
+
+        if (argv[i][0] != '-' && !opts->filename) opts->filename = argv[i];
         /* Match available arguments. */
-        if      (strcmp(argv[i], "-")  == 0) opts->stdin = true;
+        else if (strcmp(argv[i], "-")  == 0) opts->stdin = true;
         else if (strcmp(argv[i], "-n") == 0) opts->noxar = true;
         else if (strcmp(argv[i], "-h") == 0) opts->help = true;
         else if (strcmp(argv[i], "-v") == 0) opts->version = true;
-        else usage("unrecognized flag");
-        /* Move all remaining arguments to the front. */
-        for (int j = 0; j < (*argc-1); ++j) {
-            argv[j] = argv[j+1];
-        }
-        (*argc)--;
+
     }
 }

@@ -200,17 +199,23 @@ static inline size_t cpio_out(char *buffer, size_t size) {

 int main(int argc, const char** argv) {
     /* Parse and validate command-line flags and arguments. */
+
     struct options opts = {0};
+    char const* filename = NULL;
+
     parse_args(&argc, argv, &opts);
+
     if (opts.version) version();
     if (opts.help) usage(NULL);
-    if (!opts.stdin && argc < 2)
+    if (opts.stdin) {
+        fprintf(stderr, "reading <stdin>\n");
+    } else if (opts.filename) {
+        fprintf(stderr, "reading \"%s\"\n", opts.filename);
+        filename = opts.filename;
+    } else {
         usage("missing filename argument");
-    else if ((!opts.stdin && argc > 2) || (opts.stdin && argc > 1))
-        usage("unhandled positional argument(s)");
+    }

-    char const* filename = NULL;
-    if (argc >= 2) filename = argv[1];

     /* Open a stream to the payload. */
     struct stream stream;
