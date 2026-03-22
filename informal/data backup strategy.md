# Data Backup Strategy

A simple, local 3-tier hierarchy with selective mirroring of important data only. Starts with internal SSD + one external HDD; adds a fast external SSD later. Replaces paid cloud storage for bulk data (free 5 GB tier kept for settings + ultra-critical docs only).

## Storage Tiers

Tiers are numbered from 0 (highest tier) to 3 (lowest tier). Higher tiers are smaller and more expensive:

- **Tier 0: Cloud**
  - For critical docs and syncing small stuff across devices
  - kept small to avoid indefinite recurring cost

- **Tier 1: Internal SSD**  
  - For active editing, current small enough projects, operating system, stuff that must be on main drive.
  - Only as big as needed for convenience, since large internal storage can be expensive.
  - does not necessarily duplicate all data of Tier 0.

- **Tier 2: External Fast SSD**
  - For 1) Large active projects that don't fit internal drive, and 2) storing critical data redundantly (in addition to other tiers).
  - using this drive might be simplified by storing everything is on one of 3 folders:
    - "active work only": for actively worked on large non-critical stuff. content may be edited and deleted and gets backed up only on Tier 3.
    - "backup only": for small inactive critical stuff. content may neither be edited nor deleted and is a mirror of the backup on Tier 3. this stuff gets edited on Tier 1.
    - "active work and backup": for large critical stuff. content may be edited but NOT deleted and is also backed up (mirrored) on Tier 3.
  - Portable option for trips.
  - Stays plugged in (which also helps longevity)
  - Backs up critical data from Tier 0/1 at least once per day.
  - Large projects that don't fit the internal drive are stored only here and on Tier 3. If the external SSD (Tier 2) suddenly fails, recent work (a few days old at most) may be lost, since the only other copy lives on the HDD (Tier 3). This risk is acceptable and helps preserve the longevity of Tier 3.

- **Tier 3: WD My Passport Ultra for Mac, 6 TB (mechanical HDD)**
  - https://www.galaxus.ch/en/s1/product/wd-my-passport-ultra-for-mac-6-tb-external-hard-drives-44726266
  - For long-term archive of ALL data. Stores basically everything.
  - Syncs with other tiers at most once per day.
  - Stays plugged in at home but is used only up to a few minutes per day.
  - HDDs up to 6TB can be USB-powered (like this one).
 
### Summary: Where is what?

**Tier:**
- **Tier 0 (Cloud)**: Critical small data (documents) + device sync.
- **Tier 1 (Internal SSD)**: Small enough active projects.
- **Tier 2 (External SSD)**: Active projects that are too big for Tier 1, critical inactive projects.
- **Tier 3 (External HDD)**: All data.

**Backup vs Active Work:**
1. **Backup**: Critical data is backed up on Tier 0 (if it's small enough) and on Tiers 2+3. Non-critical data is backed up only on Tier 3.
2. **Active Work**: Editing happens on Tier 1 (if small enough) or Tier 2 (if larger). Once work is finished and backed up, data can be deleted from Tier 1 (and from Tier 2 if non-critical).

## Redundancy Strategy
Only critical data is redundantly backed up to 2 external drives. And mirroring is done without RAID.
 - Full flexibility to choose what gets duplicated -> significantly more usable space compared to the 50% RAID overhead
 - Allows managing data freely, with complete control and scripting, for example: detecting bit deviations, accessing the working version when one copy is corrupted
 - Avoids additional complexity and risks of RAID

## Backup Tools
- **Carbon Copy Cloner (CCC)**: Simple GUI for mirroring + verification.
- **rsync** (lightweight alternative):
  ```bash
  rsync -aAX --delete --checksum --info=progress2 "/Source/" "/Destination/"
  ```
  - `-a`: Archive mode (recursive copying that preserves permissions, timestamps, symlinks, and basic ownership).
  - `-A`: Preserve ACLs (Access Control Lists).
  - `-X`: Preserve extended attributes (important macOS file metadata).
  - `--delete`: Delete files in the destination that no longer exist in the source (creates a true mirror).
  - `--checksum`: Compare files by actual content checksum (detects silent bit deviations and corruption).
  - `--info=progress2`: Display a detailed progress bar during the operation.
- To simplify access to external drives, symlinks and aliases both can help.
  - Both can link to external drives and continue working after an external drive was temporarily unplugged.
  - Example of creating a symlink: `ln -s /Volumes/YourExternalDrive/path/to/target ~/Desktop/my-symlink`

## HDD vs SSD

Fast SSD layers for daily work + HDD for reliable long-term archival. Selective mirroring gives speed, capacity, and redundancy exactly where needed — without RAID complexity or recurring cloud costs.  

Both the SSD and HDD can and should be kept plugged in. This is convenient and actually improves longevity (especially for the SSD, but also for the HDD due to fewer full power cycles).

**HDD (archive tier)**  
Pros: Excellent long-term data stability (even unpowered), best $/TB, proven for decades of occasional use.  
Cons: Slower, mechanical (some noise/vibration). But noise only occurs when using the disk — otherwise macOS spins it down anyway after a few minutes and then it's completely silent.

**SSD (hybrid and active tiers)**
Pros: Extremely fast, silent, perfect for editing and portability.  
Cons: Higher cost per TB, weaker unpowered retention (but not critical when mostly plugged in).