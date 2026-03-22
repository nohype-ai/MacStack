# Data Backup Strategy

A simple, local 3-tier hierarchy with selective mirroring of important data only. Starts with internal SSD + one external HDD; adds a fast external SSD later. Replaces paid cloud storage for bulk data (free 5 GB tier kept for settings + ultra-critical docs only).

## Tiers & Purposes
- **Tier 1: Internal SSD**  
  - For active editing, current small enough projects, operating system, stuff that must be on main drive.
  - Only as big as needed for convenience, since large internal storage can be expensive.

- **Tier 2: External Fast SSD** (added later)
  - For 1) Large active projects that don't fit internal drive, and 2) storing critical data redundantly (in addition to both other drives).
  - Portable option for trips.
  - Stays plugged in (which also helps longevity)
  - Syncs critical data with internal drive at least daily.

- **Tier 3: WD My Passport Ultra for Mac, 6 TB (mechanical HDD)**
  - https://www.galaxus.ch/en/s1/product/wd-my-passport-ultra-for-mac-6-tb-external-hard-drives-44726266
  - For long-term archive of ALL data. Stores basically everything.
  - Syncs with both other drives at most daily.
  - Stays plugged in at home but is used only up to a few minutes per day.
  - HDDs up to 6TB can be USB-powered (like this one).

## Redundancy Strategy
Only critical/finished data is mirrored. And mirroring is done without RAID.
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

## HDD vs SSD Trade-offs
**HDD (archive tier)**  
Pros: Excellent long-term data stability (even unpowered), best $/TB, proven for decades of occasional use.  
Cons: Slower, mechanical (some noise/vibration). But noise only occurs when using the disk — otherwise macOS spins it down anyway after a few minutes and then it's completely silent.

**SSD (active tiers)**  
Pros: Extremely fast, silent, perfect for editing and portability.  
Cons: Higher cost per TB, weaker unpowered retention (but irrelevant when always plugged in).

## Core Principle
Fast SSD layers for daily work + HDD for reliable long-term archival. Selective mirroring gives speed, capacity, and redundancy exactly where needed — without RAID complexity or recurring cloud costs.  

Both the SSD and HDD can and should be kept plugged in. This is convenient and actually improves longevity (especially for the SSD, but also for the HDD due to fewer full power cycles).