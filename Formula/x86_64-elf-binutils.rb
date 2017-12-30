class X8664ElfBinutils < Formula
  BINUTILS_VERSION = "2.29.1"
  TARGET = "x86_64-elf"

  desc "Cross Compiler. x86_64 Binutils for OS development"
  homepage "https://www.gnu.org/software/binutils/"
  url "https://ftp.gnu.org/gnu/binutils/binutils-#{BINUTILS_VERSION}.tar.gz"
  mirror "https://ftpmirror.gnu.org/binutils/binutils-#{BINUTILS_VERSION}.tar.gz"
  sha256 "0d9d2bbf71e17903f26a676e7fba7c200e581c84b8f2f43e72d875d0e638771c"

  def install
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

    man7.rmtree
    info.rmtree
  end
end
