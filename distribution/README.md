## How to release

1. Bump the version in `homebrew-macstack/Formula/macstack.rb` — update the `url` and `version` fields to the new version number (e.g. `v0.2.0`).

2. Tag the release in the MacStack repo and push:
   ```bash
   git tag v0.2.0
   git push origin v0.2.0
   ```

3. Compute the sha256 of the release tarball GitHub just created:
   ```bash
   curl -sL https://github.com/nohype-ai/MacStack/archive/refs/tags/v0.2.0.tar.gz | shasum -a 256
   ```

4. Paste the hash into `macstack.rb` as the `sha256` value.

5. Commit and push the updated formula to the `homebrew-macstack` repo.

Users who already have the tap will get the update on their next `brew upgrade`.
