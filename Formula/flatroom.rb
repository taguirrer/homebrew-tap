class Flatroom < Formula
  desc "System-wide room correction for macOS: FIR convolution, no virtual driver"
  homepage "https://github.com/taguirrer/flatroom"
  url "https://github.com/taguirrer/flatroom/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "bc257d202b7ea534d85415d2e38bd34b5fb37076e842cbf9b595e86054d5310b"
  license "GPL-3.0-only"
  head "https://github.com/taguirrer/flatroom.git", branch: "main"

  depends_on macos: :tahoe

  def install
    system "swift", "build", "--disable-sandbox", "-c", "release", "--product", "Flatroom"
    contents = prefix/"Flatroom.app/Contents"
    (contents/"MacOS").install ".build/release/Flatroom"
    contents.install "Resources/Flatroom-Info.plist" => "Info.plist"
    # Homebrew's sandbox hides the login keychain, so this signs ad-hoc; caveats explain how to re-sign.
    system "scripts/sign.sh", prefix/"Flatroom.app"
  end

  def caveats
    <<~EOS
      Link the app into your Applications folder and open it:
        mkdir -p ~/Applications
        ln -sf #{opt_prefix}/Flatroom.app ~/Applications/
        open ~/Applications/Flatroom.app

      Homebrew builds can't reach your keychain, so Flatroom is signed ad-hoc and macOS asks
      for its permissions again after every upgrade. If you made a "Flatroom Dev" code-signing
      certificate (see the README), sign with it after each install or upgrade to keep them:
        codesign --force --sign "Flatroom Dev" #{opt_prefix}/Flatroom.app

      Then make or import a filter: https://github.com/taguirrer/flatroom#make-a-filter
    EOS
  end

  test do
    assert_path_exists prefix/"Flatroom.app/Contents/MacOS/Flatroom"
    system "codesign", "--verify", prefix/"Flatroom.app"
  end
end
