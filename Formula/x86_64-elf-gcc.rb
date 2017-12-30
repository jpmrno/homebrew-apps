class X8664ElfGcc < Formula
  GCC_VERSION = "7.2.0"
  TARGET = "x86_64-elf"

  desc "Cross Compiler. x86_64 Binutils & GCC without libs for OS development"
  homepage "https://gcc.gnu.org"
  url "https://ftp.gnu.org/gnu/gcc/gcc-#{GCC_VERSION}/gcc-#{GCC_VERSION}.tar.gz"
  mirror "https://ftpmirror.gnu.org/gcc/gcc-#{GCC_VERSION}/gcc-#{GCC_VERSION}.tar.gz"
  sha256 "0153a003d3b433459336a91610cca2995ee0fb3d71131bd72555f2231a6efcfc"

  option "without-libiconv", "Don't use homebrew's libiconv"
  option "with-c++", "Build with c++ support"

  depends_on "jpmrno/apps/x86_64-elf-binutils"
  depends_on "gmp"
  depends_on "libmpc"
  depends_on "mpfr"
  depends_on "isl"
  depends_on "libiconv" => :recommended

  def install
    # GCC will suffer build errors if forced to use a particular linker.
    ENV.delete "LD"

    languages = %w[c]
    languages << "c++" if build.with? "c++"

    args = [
      "--target=#{TARGET}",
      "--prefix=#{prefix}",
      "--program-prefix=#{TARGET}-",
      "--program-suffix=-#{version.to_s.slice(/\d/)}",
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
