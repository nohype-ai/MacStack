# MacStack Homebrew Release

## Release via Script

```zsh
./release.sh <new version>
```

## Release Manually

1. Tag the release in the MacStack repo and push:
   ```bash
   git tag v0.1.1
   git push origin v0.1.1
   ```

2. Compute the sha256 of the release tarball GitHub just created:
   ```bash
   curl -sL https://github.com/nohype-ai/MacStack/archive/refs/tags/v0.1.1.tar.gz | shasum -a 256
   ```

3. Paste the hash into `homebrew-macstack/Formula/macstack.rb` as the `sha256` value.

4. Bump the version in `homebrew-macstack/Formula/macstack.rb`: Update the version wherever it's referenced (at least in the URL) to the new version number (e.g. `v0.1.1`).

5. Commit and push the updated formula to the `homebrew-macstack` repo. Users who already have the tap will get the update on their next `brew upgrade`.

6. Test MacStack Release
   ```zsh
   # Initial install
   brew tap nohype-ai/macstack
   brew install macstack
   
   # force tap update after new release
   cd $(brew --repository nohype-ai/macstack) && git pull
   
   # Upgrade
   brew upgrade macstack
   
   # Check version
   brew list --versions macstack
   ```
