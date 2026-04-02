# SSH Key Setup Strategy

## Authentication Method Decision
- **Use SSH keys instead of HTTPS PATs**
  - PATs expire and require renewal
  - SSH keys don't expire, less maintenance
  - More secure long-term approach

## Key Strategy  
- **Focus on default SSH key** (`~/.ssh/id_ed25519`)
  - No SSH config needed for GitHub
  - Single identity across services
  - Works out-of-the-box for `git@github.com:` URLs

## Security & Storage
- **Generate key with strong passphrase** (encrypted private key)
- **Store encrypted private key** safely in iCloud Drive
- **Store public key** alongside for verification
- **Upload public key to GitHub** (one-time manual step)

## Automation Strategy
- **Idempotent verification**: Compare current vs expected public key
- **Skip restore** if correct key already installed
- **Only prompt for passphrase** when restoration needed
- **Derive public from private** to verify key pair integrity

## .env Configuration Integration
- **Centralized secrets**: Store SSH passphrase in `.env` file alongside other personal settings
- **Unattended automation**: Enables script to run independently (e.g., nightly cron jobs)
- **Decoupled key management**: Separates user's personal key/passphrase management from script execution
- **Single input source**: All personal configurations in one place (Git settings, SSH passphrase, paths, etc.)
- **Security**: Process-scoped variables that don't leak to system environment

```bash
# Example .env additions:
SSH_PASSPHRASE="your-ssh-key-passphrase"
ICLOUD_BACKUP_PATH="$HOME/Library/Mobile Documents/com~apple~CloudDocs/backup"
```

## Implementation Flow
1. Check if `~/.ssh/id_ed25519` exists and matches expected public key
2. If match: skip restoration (no passphrase prompt)  
3. If no match: restore from iCloud backup + verify + add to ssh-agent using `$SSH_PASSPHRASE`
4. Script can run fully unattended with all inputs from `.env`

## Files Involved
- Backup: `~/iCloud/backup/ssh/id_ed25519` (encrypted private)
- Backup: `~/iCloud/backup/ssh/id_ed25519.pub` (public for verification)
- Target: `~/.ssh/id_ed25519` (restored private key)

## Alternative: Progressive Detection Approach

**Philosophy**: Detect, inform, exit gracefully. Simpler than full automation.

### Script Behavior

1. **Key exists** (`~/.ssh/id_ed25519`):
   - ✅ Add to SSH agent (prompts for passphrase if not in Keychain)
   - ✅ Continue with automation

2. **Key missing**:
   - ⚠️ Display helpful message with options
   - 🛑 Exit gracefully
   - ✅ User restores key manually and re-runs script

### Example Script Logic

```bash
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "⚠️  No SSH key found at ~/.ssh/id_ed25519"
    echo ""
    echo "Options:"
    echo "  1. Restore from your backup (iCloud, password manager, etc.)"
    echo "  2. Generate new: ssh-keygen -t ed25519 -C 'your_email@example.com'"
    echo "  3. Then add public key to GitHub and run this script again"
    echo ""
    echo "Skipping Git SSH setup for now."
    exit 0
fi

# Key exists, add to agent if not already there
ssh-add -l | grep -q "id_ed25519" || ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

### Trade-offs vs Full Automation

**Pros:**
- Simpler code (no backup/restore logic)
- No assumptions about backup location
- User controls restoration method
- No state to manage
- **Fully automated after initial setup** (once key exists and passphrase is in Keychain)

**Cons:**
- Requires one-time manual setup on new machines (restore key before first run)
- **Not a real con for general-purpose tools**: Users have different backup strategies, so not hardcoding a specific backup location is actually the right design

## Files We DON'T Need to Touch

### `.git-credentials`
- **HTTPS-only**: Only used for PAT authentication
- **Irrelevant for SSH**: SSH bypasses credential helpers entirely
- **Keep existing**: Work PATs remain untouched

### `~/.ssh/config` 
- **Safe Automation**: Use `Include` directive to inject settings without overwriting user's existing config.
- **Strategy**:
  1. **Append** `Include ~/.ssh/config.d/*` to the **bottom** of `~/.ssh/config` (if not present).
  2. Write managed settings to `~/.ssh/config.d/macstack`.
  
  *Example `~/.ssh/config.d/macstack`:*
  ```ssh
  Host github.com
    User git
  
  Host *
    UseKeychain yes
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_ed25519
  ```

### `~/.ssh/known_hosts`
- **Auto-populated**: First connection to GitHub prompts user once
- **Self-maintaining**: SSH handles this automatically
- **No automation needed**

### `~/.gitconfig`
- **Already handled**: Mac-stack automation sets user identity & preferences
- **No SSH-specific config**: Git works with SSH out-of-the-box
- **Credential helper ignored**: `osxkeychain` not used with SSH URLs

### `~/.gitignore_global`
- **Already handled**: Mac-stack creates/copies this file
- **Independent of auth method**: Same for SSH or HTTPS

### Additional Key Pairs
- **Not needed**: One key (default key) can serve many services (GitHub, GitLab, servers, etc.)
- **Leave work keys untouched**: Existing work keys remain for organizational requirements
- **Separate concerns**: Default key for personal services, work keys for work
- **No conflicts**: SSH config handles key selection per host when needed

## Other Notes

As setup script might want to:
```bash
# Auto-add GitHub to known_hosts so scripts don't ask for confirmation
# The '||' ensures we don't duplicate if it's already there
ssh-keygen -F github.com || ssh-keyscan github.com >> ~/.ssh/known_hosts
```

## Benefits
- ✅ Simple: No external tools required
- ✅ Secure: Encrypted keys safe in cloud storage  
- ✅ Fully automated: Unattended execution with .env configuration
- ✅ Centralized: All personal settings in single .env file
- ✅ Flexible: User controls passphrase management (keychain, password manager, or .env)
- ✅ Idempotent: Safe to run multiple times
- ✅ Non-destructive: Doesn't interfere with existing work setups
- ✅ Schedulable: Can run as cron job or nightly automation