class Flatroom < Formula
  desc "System-wide room correction for macOS: FIR convolution, no virtual driver"
  homepage "https://github.com/taguirrer/flatroom"
  url "https://github.com/taguirrer/flatroom/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "SHA256_PLACEHOLDER"
  license "GPL-3.0-only"
  head "https://github.com/taguirrer/flatroom.git", branch: "main"

  depends_on macos: :tahoe

  def install
    system "swift", "build", "--disable-sandbox", "-c", "release", "--product", "Flatroom"
    contents = prefix/"Flatroom.app/Contents"
    (contents/"MacOS").install ".build/release/Flatroom"
    contents.install "Resources/Flatroom-Info.plist" => "Info.plist"
    # Signs with a "Flatroom Dev" certificate if you have one (keeps permissions across updates), else ad-hoc.
    system "scripts/sign.sh", prefix/"Flatroom.app"
  end

  def caveats
    <<~EOS
      Link the app into your Applications folder and open it:
        ln -sf #{opt_prefix}/Flatroom.app ~/Applications/
        open ~/Applications/Flatroom.app

      Then make or import a filter: https://github.com/taguirrer/flatroom#make-a-filter
    EOS
  end

  test do
    assert_path_exists prefix/"Flatroom.app/Contents/MacOS/Flatroom"
    system "codesign", "--verify", prefix/"Flatroom.app"
  end
end
