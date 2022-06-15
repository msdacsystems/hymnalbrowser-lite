# Hymnal Browser Lite Changelog

For developer-related changes, view the changes [here](https://github.com/msdacsystems/hymnalbrowser-lite/commits/main).

*This only logs significant changes in the application. Hotfixes are not included.

### Latest

*Changes for* patch **v0.2.3** (2022-06-15)
- New icon
- Initialization code is restructured
- Code refactors for interface (removed Setup method)
- Better error handling (missing binary and presentation failure)
- Lower package size (.sda package is now using better compression; from 98 MB down to 28 MB)
- Added query count and launch count for hymns. (Statistics are to be followed)
- Fixed a bug where the application behaves abnormally when the same window name 'Hymnal Browser Lite' is present in processes.
- The window's position will now dump at the end of the session compared to occasionally
- The temp folder will now be retained at the end of the session.

---

*Changes for* patch **v0.2.2** (2022-06-10)
- Log files will now be retained, allowing a maximum of 1000 lines before the oldest line is removed.
- Fixed temp folder for presentations not deleting after application exit.

---

*Changes for* patch **v0.2.1** (2022-06-08)
- Added about option in context menu
- Added tray icon
- Rebranded application icon

---

*Changes for* update **v0.2.0** (2022-06-08)
- Added Hymnal package verifier. Hymnal will now be scanned in several directories: (1) Same folder as app, (2) in Documents, and (3) ProgramData
- Added configuration settings such as focus back on Hymnal Browser after launching, auto-slideshow, and always on top.
- Added minimize option in right-click context menu
- Launch count will now be recorded for every session
- Improved search reliability
- Fixed a bug where the suggestion box will not close when dragging the application
- Fixed a bug where scrolling through suggestion box will not behave accordingly
- Last window position will now be remembered, including the monitor; Near-edge positions will reset the window's location to the center of primary monitor's screen on next launch.

---

*Changes for* patch **v0.1.1** (2022-06-07)
- Improvements when searching
- The "Launch" button will now dynamically change the text according to the status. (e.g: Not Available, Insert Hymn, Launching and Launched)
- The suggestions was rebranded to "matches" and will now show up in Launch button's text for a second.
- Critical errors will now show a message box instead of the default runtime error.
- Fixed a bug where clicking back on the app will clear the typed text in search bar.

---

*Changes for* build **v0.1.0** (2022-06-06)
- Initial test build