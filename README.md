# PICO 4 Enterprise: business apps → global consumer apps, without root

> [!WARNING]
> **Firmware.** These scripts only change apps. They never flash firmware.
> Never flash a firmware file meant for another model or edition, such as a
> consumer PICO 4 or PICO 4 Pro update, onto a PICO 4 Enterprise. Only use
> firmware confirmed for your exact model. Wrong firmware can brick the headset.

> [!NOTE]
> **Global editions only.** The consumer APKs in `Apks/` (PICO Store, User
> Center, PICO Home, PICO Connect) are the global (international) editions.
> These steps assume a global PICO account; China-region builds are not covered.

## Contents

| Folder | What it holds |
| --- | --- |
| `Pico Scripts/` | The `.bat` scripts you run, plus shared helpers (`_adb.cmd`, `_pico.cmd`, `_enable.cmd`) |
| `Apks/` | The APKs the scripts install (global editions) |

## How this works

The headset stays a business-edition headset. Its edition is stored in
protected storage (`/mnt/vendor/persist`) that only root or factory tools can
change; these scripts do not touch it, and do not change the serial number.

Instead, everything happens at app level over adb (USB debugging):

- Business apps are removed for the current user (`pm uninstall -k --user 0`);
  the originals stay in the system image, so this can be undone.
- The global consumer apps (store, user center, PICO Home) are installed and
  switched on.
- **PICO Connect**, the consumer build of Streaming Assistant (used for PC
  streaming), is installed as an update over the preinstalled business copy.
  Both use the package `com.picovr.picostreamassistant`.
- Helper apps are installed: **Lightning Launcher**, an app launcher that lists
  every installed app, and **QuickShortcutMaker**, which opens hidden screens
  inside apps.

You sign in with a regular PICO account through the consumer store. That
sign-in is system-wide: apps check your purchases through it.

## What works afterwards

- Signing in to the consumer PICO store with a regular account
- Seeing and downloading apps you bought on that account
- The consumer User Center app, opened from Lightning Launcher, shows your
  account, as long as it is switched on (see [After every reboot](#after-every-reboot))
- Virtual Desktop: confirmed. After signing in through the store app, Virtual
  Desktop could be downloaded from the store.

## What does not work

- **The profile button on the taskbar (menu bar) does nothing.**
  On a business-edition headset the taskbar only ever opens the *business*
  user center, and that has been removed. It cannot be pointed at the
  consumer user center without changing the edition. Open "User Center"
  from Lightning Launcher instead.
- **After every reboot** the system switches the consumer store, user center
  and PICO Home off again. The business edition has a built-in list of
  consumer apps to switch off at startup. See below.
- **Business features are gone:** Business Settings, Business Suite, Business
  Store, business activation. "Customize Library" lives in Business
  Settings, so do the developer-menu step *before* running script 3.

## After every reboot

Switch the consumer apps back on, either:

- **From the PC, everything:** run `3. Business to Global.bat` again. It is
  safe to repeat: it reinstalls the APKs and switches the consumer apps back on.
- **From the PC, store only:** run `4. Store Enabler.bat`. It reinstalls
  `store.apk` and switches the store on, and touches nothing else.
- **In the headset:** copy `store.apk` and `VRUserCenter2.apk` from the `Apks`
  folder to the headset's Download folder once, then after each reboot install
  them again from the Files app. Reinstalling the store this way switched
  it back on in testing; the user center should behave the same.

## Order

0. **In the headset, before any script:**
   Settings > General > About, tap the software version until "Developer"
   appears. Developer > Business Settings > System Apps > Customize Library:
   turn **off** Business Suite, Business User Center and Business Store,
   turn **on** Streaming Assistant.
1. `1. Check USB connection.bat`: checks that the PC sees the headset
2. `2. Install PICO Connect.bat`: installs the global PICO Connect APK
   (`Apks/PICOConnect-*.apk`) over Streaming Assistant and switches it on.
   This was done first, by hand, on the tested headset.
3. `3. Business to Global.bat`: removes business apps, installs and
   switches on the consumer apps
4. `4. Store Enabler.bat`: not needed on the first run, because script 3
   already installs the store. Use it after a reboot (see above).
5. `5. Device info.bat`: shows model, firmware and business apps
6. `6. Disable Explore and User Guide.bat`: optional; this also switches
   PICO Home off

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
| USB drivers | Driver installer script (its driver folder was never shipped) | `1. Check USB connection.bat` checks Windows and adb instead |
| PICO Connect | Not included | `2. Install PICO Connect.bat` installs the global build |
| Undo | Not shown | Undo command printed at the end |

## Undo

- One app: `adb -s <serial> shell pm install-existing <package>`
- Everything: factory reset (Settings > General > Factory reset)

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
