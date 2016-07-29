class Grub < Formula
  desc "Grub2 for OS development"
  homepage "https://www.gnu.org/software/grub"
  url "git://git.savannah.gnu.org/grub.git"
  version "2.00"

  depends_on "automake" => :build
  depends_on "autogen" => :build
  depends_on "autoconf" => :build
  depends_on "flex"
  depends_on "jpmrno/apps/crossyc"

  resource "objconv" do
    url "http://www.agner.org/optimize/objconv.zip"
    sha256 "1aa3171a8f0ebba7902b413857b178df2b079cbc31bfb95b196ba7a685c227ba"
  end

  def install
    resource("objconv").stage do
      system "unzip", "source.zip"
      system "#{ENV.cxx} -o objconv -O2 *.cpp"
      bin.install "objconv"
    end

    ENV["PATH"] += ":#{bin}"

    system "./autogen.sh"

    args = [
      "--target=x86_64-elf",
      "--prefix=#{prefix}",
      "LDFLAGS=-L#{Formula["flex"].opt_prefix}/lib",
      "CPPFLAGS=-I#{Formula["flex"].opt_prefix}/include",
      "TARGET_CC=#{Formula["crossyc"].bin}/x86_64-elf-gcc",
      "TARGET_OBJCOPY=#{Formula["crossyc"].bin}/x86_64-elf-objcopy",
      "TARGET_STRIP=#{Formula["crossyc"].bin}/x86_64-elf-strip",
      "TARGET_NM=#{Formula["crossyc"].bin}/x86_64-elf-nm",
      "TARGET_RANLIB=#{Formula["crossyc"].bin}/x86_64-elf-ranlib",
      "--disable-werror",
    ]

    mkdir "build" do
      system "../configure", *args
      system "make"
      system "make", "install"
    end

    etc.rmtree
  end
end
