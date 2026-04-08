## How to release

1. Tag the release in the MacStack repo and push:
   ```bash
   git tag v0.1.1
   git push origin v0.1.1
   ```

2. Compute the sha256 of the release tarball GitHub just created:
   ```bash
   curl -sL https://github.com/nohype-ai/MacStack/archive/refs/tags/v0.1.1.tar.gz | shasum -a 256
   ```

3. Paste the hash into `macstack.rb` as the `sha256` value.

4. Bump the version in `homebrew-macstack/Formula/macstack.rb` — update the `url` and `version` fields to the new version number (e.g. `v0.1.1`).

5. Commit and push the updated formula to the `homebrew-macstack` repo. Users who already have the tap will get the update on their next `brew upgrade`.

6. Test MacStack Release
   ```zsh
   # Initial install
   brew tap nohype-ai/macstack
   brew install macstack
   
   # Upgrade
   brew upgrade macstack
   
   # Check version
   brew list --versions macstack
   ```

   > `brew upgrade` skips taps that were recently cloned (cooldown). If `brew upgrade macstack` still shows the old version, force-pull the tap manually:
   > ```bash
   > cd $(brew --repository nohype-ai/macstack) && git pull
   > ```
