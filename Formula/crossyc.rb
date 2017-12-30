class Crossyc < Formula
  GCC_VERSION = "7.2.0"
  BINUTILS_VERSION = "2.29.1"
  TARGET = "x86_64-elf"

  desc "Cross Compiler. x86_64 Binutils & GCC without libs for OS development"
  homepage "http://gcc.gnu.org"
  version "#{GCC_VERSION}-#{BINUTILS_VERSION}"
  url "https://ftp.gnu.org/gnu/gcc/gcc-#{GCC_VERSION}/gcc-#{GCC_VERSION}.tar.gz"
  mirror "https://ftpmirror.gnu.org/gcc/gcc-#{GCC_VERSION}/gcc-#{GCC_VERSION}.tar.gz"
  sha256 "0153a003d3b433459336a91610cca2995ee0fb3d71131bd72555f2231a6efcfc"

  option "without-gcc", "Build binutils only (without gcc compiler)"
  option "without-libiconv", "Don't use homebrew's libiconv"
  option "with-c++", "Build with c++ support"

  unless build.without? "gcc"
    depends_on "gmp"
    depends_on "libmpc"
    depends_on "mpfr"
    depends_on "isl"
    depends_on "libiconv" => :recommended
  end

  resource "binutils" do
    url "https://ftp.gnu.org/gnu/binutils/binutils-#{BINUTILS_VERSION}.tar.gz"
    mirror "https://ftpmirror.gnu.org/binutils/binutils-#{BINUTILS_VERSION}.tar.gz"
    sha256 "0d9d2bbf71e17903f26a676e7fba7c200e581c84b8f2f43e72d875d0e638771c"
  end

  def install
    # GCC will suffer build errors if forced to use a particular linker.
    ENV.delete "LD"

    resource("binutils").stage do
      args = [
        "--target=#{TARGET}",
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

    unless build.without? "gcc"
      ENV["PATH"] += ":#{bin}"

      languages = %w[c]
      languages << "c++" if build.with? "c++"

      args = [
        "--target=#{TARGET}",
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

      unless build.without? "libiconv"
        args << "--with-libiconv-prefix=#{Formula["libiconv"].opt_prefix}"
      end

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
end
