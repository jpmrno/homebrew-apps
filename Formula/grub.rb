class Grub < Formula
  desc "Grub2 for OS development"
  homepage "https://www.gnu.org/software/grub"
  url "ftp://ftp.gnu.org/gnu/grub/grub-2.00.tar.gz"
  sha256 ""

  depends_on "automake"
  depends_on "autoconf"
  depends_on "jpmrno/apps/crossyc"

  resource "objconv" do
    url "http://www.agner.org/optimize/objconv.zip"
    sha256 ""
  end

  def install
    resource("objconv").stage do
      g++ -o objconv -O2 src/*.cpp
      bin.install "objconv"
    end

    ENV["PATH"] += ":#{bin}"

    ./autogen.sh

    args = [
      "--target=x86_64-elf",
      "--prefix=#{prefix}",
      "TARGET_CC=x86_64-elf-gcc",
      "TARGET_OBJCOPY=x86_64-elf-objcopy",
      "TARGET_STRIP=x86_64-elf-strip",
      "TARGET_NM=x86_64-elf-nm",
      "TARGET_RANLIB=x86_64-elf-ranlib",
      "--disable-werror",
    ]

    mkdir "build" do
      system "../configure", *args
      system "make"
      system "make", "install"
    end
  end
end
