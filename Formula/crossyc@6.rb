class CrossycAT6 < Formula
  gcc_version = "6.4.0"
  binutils_version = "2.29.1"
  target = "x86_64-elf"

  desc "Cross Compiler. x86_64 Binutils & GCC without libs for OS development"
  homepage "http://gcc.gnu.org"
  version "#{gcc_version}-#{binutils_version}"
  url "https://ftp.gnu.org/gnu/gcc/gcc-#{gcc_version}/gcc-#{gcc_version}.tar.gz"
  mirror "https://ftpmirror.gnu.org/gcc/gcc-#{gcc_version}/gcc-#{gcc_version}.tar.gz"

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
    url "https://ftp.gnu.org/gnu/binutils/binutils-#{binutils_version}.tar.gz"
    mirror "https://ftpmirror.gnu.org/binutils/binutils-#{binutils_version}.tar.gz"
  end

  def install
    # GCC will suffer build errors if forced to use a particular linker.
    ENV.delete "LD"

    resource("binutils").stage do
      args = [
        "--target=#{target}",
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
        "--target=#{target}",
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
