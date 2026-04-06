class Macstack < Formula
  desc "Tech stack management based on a personal stack definition"
  homepage "https://github.com/nohype-ai/MacStack"
  url "https://github.com/nohype-ai/MacStack/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "REPLACE_WITH_SHA256_OF_RELEASE_TARBALL"
  license "MIT"
  version "1.0.0"

  depends_on "jq"
  depends_on "moreutils"
  depends_on "check-jsonschema"

  def install
    prefix.install "bin"
    prefix.install "scripts"
  end

  def caveats
    <<~EOS
      To set up your Mac, run:

        mack update

      This will prompt for your stack folder on first run, install your packages,
      and add MacStack's shell customizations to your ~/.zshrc automatically.
    EOS
  end

  test do
    assert_match "Valid calls are", shell_output("#{bin}/mack help")
  end
end
