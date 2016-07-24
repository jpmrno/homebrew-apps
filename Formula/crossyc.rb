class Crossyc < Formula
  desc "Cross Compiler. x86_64 GCC & Binutils without libs for OS development"
  homepage "http://gcc.gnu.org"
  url "https://ftpmirror.gnu.org/gcc/gcc-6.1.0/gcc-6.1.0.tar.bz2"
  mirror "https://ftp.gnu.org/gnu/gcc/gcc-6.1.0/gcc-6.1.0.tar.bz2"
  sha256 "09c4c85cabebb971b1de732a0219609f93fc0af5f86f6e437fd8d7f832f1a351"

  option "without-c++", "Build without the c++ compiler"

  depends_on "gmp"
  depends_on "libmpc"
  depends_on "mpfr"
  depends_on "isl"

  resource "binutils" do
    url "https://ftpmirror.gnu.org/binutils/binutils-2.26.1.tar.gz"
    mirror "https://ftp.gnu.org/gnu/binutils/binutils-2.26.1.tar.gz"
    sha256 "dd9c3e37c266e4fefba68e444e2a00538b3c902dd31bf4912d90dca6d830a2a1"
  end

  def install
    # GCC will suffer build errors if forced to use a particular linker.
    ENV.delete "LD"

    resource("binutils").stage do
      args = [
        "--target=x86_64-elf",
        "--prefix=#{prefix}",
        "--disable-nls",
        "--disable-werror",
        "--with-sysroot",
      ]

      mkdir "build" do
        system "../configure", *args
        system "make"
        system "make", "install"
      end

      info.rmtree
    end

    ENV["PATH"] += ":#{bin}"

    languages = %w[c]
    languages << "c++" unless build.without? "c++"

    args = [
      "--target=x86_64-elf",
      "--prefix=#{prefix}",
      "--enable-languages=#{languages.join(",")}",
      "--with-gmp=#{Formula["gmp"].opt_prefix}",
      "--with-mpfr=#{Formula["mpfr"].opt_prefix}",
      "--with-mpc=#{Formula["libmpc"].opt_prefix}",
      "--with-isl=#{Formula["isl"].opt_prefix}",
      "--without-headers",
      "--disable-nls",
      "--disable-werror",
    ]

    mkdir "build" do
      system "../configure", *args
      system "make", "all-gcc"
      system "make", "all-target-libgcc"

      system "make", "install-gcc"
      system "make", "install-target-libgcc"
    end

    man7.rmtree
    info.rmtree
  end
end
