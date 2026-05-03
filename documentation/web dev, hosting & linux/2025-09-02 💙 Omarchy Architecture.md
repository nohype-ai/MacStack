# 💙 Omarchy Architecture

**Date:** 2025-09-02 10:28:56
**ID:** c3f4544c-16cb-4788-8d6d-619feb563904

---

### User

So hyprland the linux window manager is built upon Wayland?

---

### Grok (grok-3)

Yes, Hyprland is a dynamic tiling window manager built on Wayland. It uses the wlroots library, a modular Wayland compositor framework, to provide a lightweight and highly customizable window management experience.

---

### User

Does this have implications on which apps can be installed on hyprland?

---

### Grok (grok-3)

Yes, Hyprland being a Wayland-based window manager has implications for app compatibility:

- **Wayland-native apps**: Apps designed for Wayland (e.g., modern GTK or Qt apps) work seamlessly, offering better performance, smoother scaling, and native features like fractional scaling.
- **X11 apps via XWayland**: Hyprland uses XWayland to support X11 apps, so most traditional X11-based apps (e.g., older Linux software) should work, but they may have issues like blurry scaling, input lag, or lack of Wayland-specific features.
- **Incompatibilities**: Some X11 apps with heavy reliance on X-specific features (e.g., certain screen recorders, global hotkey tools, or older games) may not function perfectly or require workarounds.
- **Electron apps**: Many Electron-based apps (e.g., VS Code, Discord) work fine via XWayland, but Wayland-native support depends on the app's version and configuration.
- **GPU drivers**: Wayland requires good GPU driver support (e.g., Mesa for Intel/AMD, NVIDIA 495+ drivers). Incompatible or outdated drivers can limit app functionality or performance.

You can install most Linux apps, but for optimal experience, prioritize Wayland-native apps or ensure XWayland compatibility. Check app documentation or Hyprland’s wiki for specific tweaks if issues arise.

---

### User

Are there still alternatives to wayland?

---

### Grok (grok-3)

Yes, there are alternatives to Wayland for window management on Linux:

- **X11 (X.Org)**: The traditional display server protocol, still widely used. Many window managers (e.g., i3, Openbox, Awesome) run on X11. It’s mature but lacks modern features like Wayland’s security model or smooth scaling.
- **Mir**: A display server developed by Canonical, used in some Ubuntu-based environments. It’s less common but supports Wayland clients and has niche use cases.
- **Direct Rendering (DRM/KMS)**: Some experimental or minimal setups bypass a full display server, using DRM/KMS directly (e.g., Sway’s backend or niche compositors). This is rare and app support is limited.

X11 remains the primary alternative, but it’s gradually being phased out in favor of Wayland by many distros (e.g., Fedora, Ubuntu) due to Wayland’s modern architecture. App compatibility with X11 is broader for legacy software, but Wayland is catching up. Choose based on your app needs and hardware support.

---

### User

So hyprland is gpu accelerated?

---

### Grok (grok-3)

Yes, Hyprland is GPU-accelerated. As a Wayland compositor built on wlroots, it leverages GPU hardware for rendering, animations, and effects, ensuring smooth performance and visually appealing transitions. This requires compatible GPU drivers (e.g., Mesa for Intel/AMD, NVIDIA 495+).

---

### User

Omarchy is basically arch linux plus hyprland. That means the layers are: linux kernel, arch distro, wayland, hyprland. Is that roughly correct?

---

### Grok (grok-3)

Yes, your understanding is roughly correct, but let’s clarify the stack for Omarchy (a preconfigured Arch Linux-based distribution with Hyprland):

1. **Linux Kernel**: The foundation, handling hardware interaction and core system functions.
2. **Arch Linux**: The base distribution, providing a minimal, rolling-release system with pacman for package management.
3. **Wayland**: The display server protocol, replacing X11, managing how windows are displayed and interacted with.
4. **Hyprland**: A Wayland compositor (built on wlroots), acting as the window manager, handling tiling, animations, and desktop interactions.

So, the layers are accurate: Linux kernel → Arch Linux → Wayland → Hyprland. Note that Wayland isn’t a standalone layer like a distro; it’s a protocol implemented by Hyprland via wlroots, but your stack representation is conceptually sound.

---

### User

What are other noteworthy layers or components in this stack?

---

### Grok (grok-4)

Yes, several noteworthy layers and components extend or support the core stack (Linux kernel → Arch Linux → Wayland → Hyprland). Here's a breakdown, focusing on key additions for a functional desktop setup:

### Lower-Level Foundations
- **Bootloader (e.g., GRUB or systemd-boot)**: Handles booting into the kernel; Arch typically uses GRUB for BIOS or systemd-boot for UEFI.
- **Init System (systemd)**: Manages services, daemons, and boot processes post-kernel; essential for starting Hyprland sessions.<grok:render card_id="4efa62" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">16</argument>
</grok:render>
- **Base Libraries (e.g., glibc)**: Core C library for system calls and runtime; part of Arch's base packages.

### Graphics and Rendering
- **GPU Drivers (e.g., Mesa for AMD/Intel, NVIDIA proprietary)**: Enable GPU acceleration; required for Hyprland's smooth animations and effects. NVIDIA needs special config to avoid issues.<grok:render card_id="4dd9e3" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">16</argument>
</grok:render><grok:render card_id="2b458f" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">0</argument>
</grok:render>
- **Aquamarine**: Hyprland's rendering backend library, replacing wlroots for compositing and display handling.<grok:render card_id="92ce17" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">16</argument>
</grok:render>
- **wlroots (historical/optional)**: Modular Wayland compositor library; Hyprland was built on it but now uses Aquamarine.

### Input and Hardware Interaction
- **libinput**: Handles input devices like keyboards, mice, and touchpads; supports gestures and layouts configurable in Hyprland.<grok:render card_id="50016f" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">16</argument>
</grok:render>
- **seatd or Polkit**: Manages user sessions and permissions; required to start Hyprland without failures.<grok:render card_id="fe1401" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">16</argument>
</grok:render>
- **brightnessctl**: Controls screen and keyboard backlight.

### Audio and Multimedia
- **PipeWire (or PulseAudio)**: Modern audio server; preferred for low-latency audio, video, and screen sharing in Wayland setups.<grok:render card_id="aa2e06" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">10</argument>
</grok:render>
- **pavucontrol or pamixer**: For volume control via media keys.
- **playerctl**: Manages media playback controls.

### Desktop Utilities and Ecosystem
- **XDG Desktop Portals (e.g., xdg-desktop-portal-hyprland)**: Enables screen sharing, file pickers, and global shortcuts; often paired with xdg-desktop-portal-gtk.<grok:render card_id="deb1cc" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">16</argument>
</grok:render>
- **Hypr-Ecosystem Tools**: Includes hyprpaper (wallpapers), hyprpicker (color picker), hypridle (idle daemon), hyprlock (screen locker), hyprcursor (cursors), and others for enhanced functionality.<grok:render card_id="d52df2" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">16</argument>
</grok:render>
- **Common Add-ons**: Waybar (status bar), Wofi (app launcher), Swaync or Mako (notifications), Kitty (terminal), grim/slurp (screenshots), cliphist (clipboard manager).<grok:render card_id="d88e5c" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">14</argument>
</grok:render><grok:render card_id="436e0d" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">11</argument>
</grok:render><grok:render card_id="366407" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">16</argument>
</grok:render>

These components integrate to provide a complete, customizable environment. For Omarchy specifically, it preconfigures many of these (e.g., Waybar, Wofi) via scripts.<grok:render card_id="7c0c33" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">8</argument>
</grok:render> Prioritize Wayland-native apps for best compatibility.<grok:render card_id="718762" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">15</argument>
</grok:render>

---

### User

So hyprland doesn't use much if wayland anymore? Since it used wlroots but has shifted to Aquamarine?

---

### Grok (grok-4)

No, Hyprland is still a full Wayland compositor and implements the Wayland protocol independently.<grok:render card_id="b1b901" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">3</argument>
</grok:render><grok:render card_id="6ef991" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">5</argument>
</grok:render> It dropped wlroots in mid-2024 (around version 0.41.0) to become fully independent, shifting to its own Aquamarine backend for rendering and display handling.<grok:render card_id="fbefff" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">6</argument>
</grok:render><grok:render card_id="a03285" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">9</argument>
</grok:render> Aquamarine is a lightweight, API-agnostic library focused on rendering abstractions for Wayland (or DRM) sessions—not a wlroots competitor or replacement for the protocol itself.<grok:render card_id="0fd8f8" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">7</argument>
</grok:render> This change improves performance and autonomy but keeps Hyprland firmly on Wayland.<grok:render card_id="e0b023" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">3</argument>
</grok:render>

---

### User

So but it uses Wayland mainly in the sense of a protocol or interface contract? Not so much in the sense of calling Wayland functionality?

---

### Grok (grok-4)

Yes, exactly. Hyprland implements the Wayland protocol as a specification or contract for communication between the compositor and client apps (e.g., defining how windows are managed, inputs handled, and surfaces rendered).<grok:render card_id="cbdd47" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">1</argument>
</grok:render><grok:render card_id="3a0f22" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">7</argument>
</grok:render> It doesn't "call Wayland functionality" like a library dependency; instead, it has its own in-house C++ implementation of the protocol (generated via tools like hyprwayland-scanner).<grok:render card_id="a1220b" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">8</argument>
</grok:render> Aquamarine provides the rendering abstractions for Wayland sessions (or DRM), keeping Hyprland lightweight and independent while adhering to the protocol.<grok:render card_id="dd1b88" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">10</argument>
</grok:render>

---

### User

So Hyprland could theoretically also create a version that works with X11?

---

### Grok (grok-4)

Yes, theoretically, Hyprland could be adapted for X11, but it would require a major rewrite: shifting from implementing the Wayland protocol to X11 APIs (e.g., via XCB), restructuring rendering and input handling, and losing Wayland-specific features like its security model.<grok:render card_id="7a5cd9" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">2</argument>
</grok:render><grok:render card_id="f5dda4" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">11</argument>
</grok:render> In practice, the project is Wayland-only, evolved from an abandoned X11 predecessor called Hypr, and has no plans for X11 support.<grok:render card_id="3c2f49" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">0</argument>
</grok:render><grok:render card_id="681844" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">5</argument>
</grok:render><grok:render card_id="eba2d5" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">10</argument>
</grok:render> A community fork of the old Hypr exists for Xorg users.<grok:render card_id="024a1a" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">5</argument>
</grok:render>

---

### User

There is a new attempt to keep X11 available, in the form of XLibre. What is the technical argument for X11 apart from legacy compatibility?

---

### Grok (grok-4)

XLibre is a June 2025 fork of the X.org X11 server by developer Enrico Weigelt, aimed at modernizing X11 with code cleanups, security enhancements, and performance improvements after his ban from freedesktop.org amid alleged corporate (Red Hat) influence.<grok:render card_id="08236b" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">0</argument>
</grok:render><grok:render card_id="faf59a" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">2</argument>
</grok:render><grok:render card_id="5991b5" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">4</argument>
</grok:render>

Technical arguments for X11 over Wayland, beyond legacy compatibility, include:

- **Native network transparency**: X11 allows seamless remote display of applications over networks without additional tools, unlike Wayland which omits this for security and requires extensions or portals.<grok:render card_id="0ab57f" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">25</argument>
</grok:render><grok:render card_id="80bb69" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">35</argument>
</grok:render><grok:render card_id="847c67" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">36</argument>
</grok:render>
- **Flexible input handling**: Supports global input interception, routing beyond the focused window, injection for automation, and key grabs/hotkeys natively, while Wayland restricts these to focused windows or optional portals.<grok:render card_id="1a9a88" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">36</argument>
</grok:render>
- **Client-side window control**: Clients can directly position, resize, and stack windows, offering more extensibility than Wayland's compositor-only model.<grok:render card_id="45c890" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">36</argument>
</grok:render>
- **Atoms and inter-client communication**: Enables storing arbitrary data on windows for features like global menus or hints, which Wayland limits for security.<grok:render card_id="fa43d6" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">36</argument>
</grok:render>
- **Resource efficiency in benchmarks**: Lower RAM usage (e.g., ~150 MB less) and potentially better performance in some setups, especially with proprietary Nvidia drivers on varied hardware.<grok:render card_id="7d8774" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">36</argument>
</grok:render>
- **Direct hardware configuration**: Full access to screen settings via XRandR and clipboard without portals, simplifying certain tasks.<grok:render card_id="8b975e" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">36</argument>
</grok:render>

These advantages stem from X11's design flexibility, though Wayland prioritizes security and modernity, leading to trade-offs.

---

### User

So Wayland is less efficient and flexible but more secure.

---

### Grok (grok-4)

Not entirely accurate—it's nuanced:

- **Efficiency**: Wayland is often *more* efficient than X11 on modern hardware, with reduced latency, no screen tearing, and benchmarks showing performance gains (e.g., +20% FPS in games like Cyberpunk 2077).<grok:render card_id="3be967" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">11</argument>
</grok:render><grok:render card_id="3340c3" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">7</argument>
</grok:render> However, X11 can edge out in specific scenarios, like lower CPU usage with compositing disabled or on certain Nvidia setups.<grok:render card_id="6f4824" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">3</argument>
</grok:render><grok:render card_id="adaa06" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">12</argument>
</grok:render> Overall, Wayland prioritizes smoother, hardware-accelerated rendering.

- **Flexibility**: Yes, Wayland is less flexible by design—e.g., no native network transparency, restricted client-side window control, and limited global input grabs—to enforce better isolation.<grok:render card_id="a57081" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">8</argument>
</grok:render><grok:render card_id="4df5dd" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">4</argument>
</grok:render> X11's permissive model allows more extensibility and tooling, though this contributes to its security issues.

- **Security**: Wayland is indeed more secure, with a compartmentalized architecture that prevents apps from spying on each other or grabbing inputs globally, unlike X11's outdated, vulnerability-prone design.<grok:render card_id="700271" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">0</argument>
</grok:render><grok:render card_id="94fa00" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">7</argument>
</grok:render><grok:render card_id="5c3f5c" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">8</argument>
</grok:render>

In 2025, Wayland is mature for most users, especially with multi-monitor or HDR needs, but X11 persists for legacy or niche flexibility.<grok:render card_id="797fdd" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">5</argument>
</grok:render><grok:render card_id="6d6a7e" card_type="citation_card" type="render_inline_citation">
<argument name="citation_id">13</argument>
</grok:render>

---

