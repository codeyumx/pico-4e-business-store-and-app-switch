# PICO 4 Enterprise: business apps → global consumer apps, without root

> [!CAUTION]
> **Use at your own risk.** Inspect every file carefully before you run it,
> run the scripts carefully, and have your AI agent read them too. What you run
> on your headset is your decision. I am not responsible if you break your
> headset, lose data or lose access to anything.

**Who should use this:** owners of a PICO 4 Enterprise running the business
software (such as the business Streaming Assistant) who want the PICO Store,
store apps such as Virtual Desktop, and the ability to install other APKs.

> [!WARNING]
> **Firmware.** These scripts only change apps. They never flash firmware.
> Never flash a firmware file meant for another model or edition, such as a
> consumer PICO 4 or PICO 4 Pro update, onto a PICO 4 Enterprise. Only use
> firmware confirmed for your exact model. Wrong firmware can brick the headset.

> [!NOTE]
> **Global editions only.** The consumer APKs in `Apks/` (PICO Store, User
> Center, PICO Home, PICO Connect) are the global (international) editions.
> These steps assume a global PICO account; China-region builds are not covered.

> [!IMPORTANT]
> **This does not make it a regular PICO 4.** The scripts give you the
> consumer PICO Store, but the headset is still registered as an enterprise
> device. Other users report that, because of this, many store apps show as
> outdated, will not update, or will not install at all. That is decided by
> PICO's servers, and nothing on the headset can change it. Virtual Desktop
> did install from the store in my testing, and PICO Connect works; I have
> not tested the rest of the library.
>
> Apps installed directly as APKs (over adb, or from the Files app) do run.
> So if the store will not install or update an app, you can install its APK
> instead.
>
> Getting the full store library would mean rooting the headset and changing
> its serial number so that it registers as a consumer PICO 4 or PICO 4 Pro.
> These scripts do not do that and I do not recommend it: it can brick the
> headset and void its warranty, and changing a serial number may break PICO's
> terms or local law.

## Contents

| Folder | What it holds |
| --- | --- |
| `Pico Scripts/` | The `.bat` scripts you run, plus shared helpers (`_adb.cmd`, `_pico.cmd`, `_enable.cmd`, `_copy_store.cmd`) |
| `Apks/` | The APKs the scripts install (global editions) |

## How this works

The headset stays a business-edition headset. Its edition is stored in
protected storage (`/mnt/vendor/persist`) that only root or factory tools can
change; these scripts do not touch it, and do not change the serial number.

Instead, everything happens at app level over adb (USB debugging):

- Some business apps are removed for the current user (`pm uninstall -k
  --user 0`); the originals stay in the system image, so this can be undone.
- The global consumer apps are installed and switched on.
- Business Settings is kept, so Customize Library stays available.
- The startup app `com.picovr.init.overlay` is switched off, so the consumer
  apps stay on after a reboot.

### Every app the scripts touch

| App | Package | Script | What happens |
| --- | --- | --- | --- |
| Business activation | `com.pvr.tobactivate` | 3 | Removed for user 0 |
| Business User Center | `com.picovr.tobvrusercenter` | 3 | Removed for user 0 |
| Business home | `com.pvr.tobhome` | 3 | Removed for user 0 |
| Business Store (older firmware) | `com.pvr.tobstore` | 3 | Removed for user 0 |
| Business Store (newer firmware, seen on 5.9.9) | `com.picoxr.tobstore` | 3 | Removed for user 0 |
| Enterprise assistant | `com.picovr.enterpriseassistant` | 3 | Removed for user 0 |
| Business Settings | `com.pvr.tobservice` | none | **Kept**; holds Customize Library |
| Business launcher, MDM, business user service | `com.picovrtob.vrlauncher`, `com.picoxr.tobmdm`, `com.bytedance.pico.tob.userservice` | none | Kept; effect of removing them is unknown |
| PICO Store (global) | `com.picovr.store` | 3, 4 | `store.apk` installed and switched on; also copied to the headset's Download folder |
| PICO User Center (global) | `com.picovr.vrusercenter` | 3 | `VRUserCenter2.apk` installed and switched on |
| PICO Home (global) | `com.pvr.home` | 3, 5 | `home.apk` installed and switched on by 3; switched off by 5 |
| PICO Connect (global; replaces Streaming Assistant) | `com.picovr.picostreamassistant` | 2 | `PICOConnect-*.apk` installed as an update over the business copy and switched on |
| Lightning Launcher | from `LightningLauncher.apk` | 3 | Installed; lists every installed app |
| QuickShortcutMaker | from `quickshortcut.apk` | 3 | Installed; opens hidden screens inside apps |
| Explore (activity center) | `com.picovr.activitycenter` | 5 | Switched off |
| User Guide | `com.picovr.guide` | 5 | Switched off |
| Startup app (PxrInitSceneOverlay) | `com.picovr.init.overlay` | 3, 6 | Switched off by 3, so the consumer apps are not switched off at boot; switched back on by 6 |

`Apks/nextapp.fx.apk` is in the folder but no script installs it: it is a
cracked FX File Explorer re-signed by a third party.

Sign in with a regular PICO account in the **PICO Store app**, not from the
taskbar. That sign-in is system-wide: other apps, such as PICO Connect, use
the same account, and apps check your purchases through it.

### Opening the store

The PICO Store may not appear in the app tray (app library), even when it is
installed and on. Open **Lightning Launcher**, find "Store" in its list and
launch it from there. The same goes for User Center.

If an app you installed does not show in the app tray, check Customize
Library: Settings > General > About, tap the software version until
"Developer" appears, then Developer > Business Settings > System Apps >
Customize Library, and make sure the app is listed and turned on there.

## What works afterwards

- Signing in with a regular PICO account in the PICO Store app
- Seeing and downloading apps you bought on that account
- PICO Connect: tested and works, signed in with the store account, over
  both Wi-Fi and USB
- Virtual Desktop: confirmed. After signing in through the store app, Virtual
  Desktop could be downloaded from the store.
- The consumer User Center app, opened from Lightning Launcher, shows your
  account
- Business Settings and its Customize Library stay available

## What does not work

- **The business account profile on the taskbar (menu bar) is inactive.**
  On a business-edition headset the taskbar only ever opens the *business*
  user center, which script 3 removes. It cannot be pointed at the consumer
  user center without changing the edition. Sign in through the store app,
  and open "User Center" from Lightning Launcher.
- **The store and User Center may be missing from the app tray.** Open them
  from Lightning Launcher (see [Opening the store](#opening-the-store)).
- **Removed business features:** Business Store, Business User Center,
  business home, business activation and the enterprise assistant (see the
  table above).

## After every reboot

At startup the business edition switches off a built-in list of consumer
apps (`/system/etc/pvrprovision/disablepackageslist_default.xml`, edition
`TOB`), including the store, User Center and PICO Home. The startup app that
does this, `com.picovr.init.overlay`, is switched off by script 3. In testing
(one reboot on firmware 5.9.9), the store and User Center then stayed on.

If they are switched off anyway, for example after a firmware update,
switch them back on:

- **From the PC, everything:** run `3. Business to Global.bat` again. It is
  safe to repeat.
- **From the PC, store only:** run `4. Store Enabler.bat`. It reinstalls
  `store.apk`, switches the store on, and makes sure the in-headset copy below
  is there. It does not touch any other app.
- **In the headset, no PC:** scripts 3 and 4 copy `store.apk` to the headset's
  Download folder (skipped if it is already there). Open Files, go to
  Download, tap `store.apk` and install it. Reinstalling the store this way
  switches it back on. Then open it from Lightning Launcher.

## Order

0. **In the headset, before any script:**
   Settings > General > About, tap the software version until "Developer"
   appears. Developer > Business Settings > System Apps > Customize Library:
   turn **off** Business Suite, Business User Center and Business Store,
   turn **on** Streaming Assistant.
1. `1. Check connection and device info.bat`: checks that Windows and adb
   see the headset, then shows model, firmware, OEM state, region and the
   business apps still installed. Read-only; run it any time.
2. `2. Install PICO Connect.bat`: installs the global PICO Connect APK
   (`Apks/PICOConnect-*.apk`) over Streaming Assistant and switches it on.
   This was done first, by hand, on the tested headset.
3. `3. Business to Global.bat`: removes business apps, installs and
   switches on the consumer apps, and switches off the startup app that
   turns them off at boot
4. `4. Store Enabler.bat`: not needed on the first run, because script 3
   already installs the store. Use it if the store is switched off again
   (see [After every reboot](#after-every-reboot)).
5. `5. Disable Home and User Guide.bat`: optional; switches off PICO Home,
   Explore and the User Guide
6. `6. Undo all changes.bat`: optional; reverses scripts 2 to 5 (see
   [Undo](#undo))

Every script asks which headset to use and shows its plan before changing
anything. With several headsets connected, check the serial number.

## Differences from owomushi's "Business to Global Apks"

These scripts started from owomushi's package, which has not been updated in a
while. Same basic method (remove business apps, restore and install consumer
apps over adb), with these changes:

| | owomushi | This repo |
| --- | --- | --- |
| adb | Bundled `ADB\adb.exe` | Uses an installed adb (see below) |
| Headset choice | First device whose `adb devices` line contains "PICO" | Menu of connected Picos by serial; every command uses `-s <serial>` |
| Confirmation | Runs immediately | Shows the plan, asks Y/N first |
| Business store package | `com.pvr.tobstore` only | Also `com.picoxr.tobstore` (newer firmware, seen on 5.9.9) |
| APKs installed | Every `.apk` in `Apks\` and `Apks\Pico\` | A fixed list; `nextapp.fx.apk` (a cracked FX File Explorer re-signed by a third party) is skipped |
| Re-enabling apps | Not handled | `_enable.cmd` turns the consumer apps back on, including system apps the headset switched off |
| USB drivers | Driver installer script (its driver folder was never shipped) | `1. Check connection and device info.bat` checks Windows and adb instead |
| PICO Connect | Not included | `2. Install PICO Connect.bat` installs the global build |
| Undo | Not shown | `6. Undo all changes.bat`, and the undo command printed at the end of script 3 |

## Undo

Run `6. Undo all changes.bat`. It checks what is on the headset and lists
only what it will change before asking Y/N:

- Brings back the business apps script 3 removed and switches them on
- Removes the installed updates of PICO Store, User Center, PICO Home and
  PICO Connect, which brings back the preinstalled versions. PICO Connect goes
  back to Streaming Assistant. Their data, including the store sign-in, is lost.
- Switches the consumer store, user center and PICO Home off
- Uninstalls Lightning Launcher and QuickShortcutMaker
- Switches Explore and the User Guide back on
- Deletes `store.apk` from the headset's Download folder

It does not touch apps you installed yourself, Customize Library or the
developer menu; change those back by hand. Reboot afterwards.

Other ways:

- One business app: `adb -s <serial> shell pm install-existing <package>`
- Everything, including your own apps and data: factory reset (Settings >
  General > Factory reset)

## Install adb first

These scripts need adb (Android Debug Bridge). It is not included.

1. Open Terminal or Command Prompt.
2. Run: `winget install Google.PlatformTools`
3. Close that window. The scripts find adb on their own.

To use adb by hand, open a **new** terminal after installing and type `adb`,
e.g. `adb devices -l`.

Without winget: download "SDK Platform-Tools for Windows" from
<https://developer.android.com/tools/releases/platform-tools>,
unzip it, and add the `platform-tools` folder to your `PATH`.
