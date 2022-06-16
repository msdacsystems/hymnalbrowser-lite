# Hymnal Browser Lite Documentation

## Table of Contents
- [Hymnal Browser Lite Documentation](#hymnal-browser-lite-documentation)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [AutoHotkey](#autohotkey)
  - [Code Dependencies](#code-dependencies)
  - [Prerequisites](#prerequisites)
  - [Known Limitations](#known-limitations)
  - [Localization](#localization)
  - [Code Architecture](#code-architecture)
      - [Syntax and Terminology](#syntax-and-terminology)
      - [List of Classes](#list-of-classes)
        - [Core Classes](#core-classes)
        - [Interface Classes](#interface-classes)
      - [Initialization Flow](#initialization-flow)
        - [1. System Execution](#1-system-execution)
        - [2. Developer Mode](#2-developer-mode)
        - [3. Configuration and Logger](#3-configuration-and-logger)
        - [4. Tray Menu](#4-tray-menu)
        - [5. Directory Verification](#5-directory-verification)
        - [6. Requisites Verification (Presentation)](#6-requisites-verification-presentation)
        - [7. Environments](#7-environments)
        - [8. Hymnal](#8-hymnal)
        - [9. Session](#9-session)
        - [10. User Interface](#10-user-interface)
        - [11. Background Thread](#11-background-thread)
        - [12. Initialization Complete](#12-initialization-complete)
    - [User Interface](#user-interface)
      - [Main Window Elements](#main-window-elements)
      - [Settings Window Elements](#settings-window-elements)
    - [Program Flow](#program-flow)
    - [Error Handling](#error-handling)
      - [List of Exit Codes](#list-of-exit-codes)
      - [List of Error Names](#list-of-error-names)
    - [Events](#events)
      - [System](#system)
        - [Exit](#exit)
        - [Reload](#reload)
      - [Launch](#launch)
        - [Click](#click)
      - [Settings](#settings)
        - [Click](#click-1)
      - [Search](#search)
        - [TextChanged](#textchanged)
        - [Clear](#clear)
    - [Relation of Config and Software](#relation-of-config-and-software)
  - [Acknowledgements](#acknowledgements)

## Introduction

This file contains both developer and user documentation for the application.
This documentation is last updated on **June 16, 2022**.

> Changes may or may not be made without prior notice.


## AutoHotkey

Autohotkey may not be the best language to develop this app, but this is just an experimental project to temporarily fix the slow runtime issue in the Python-based Hymnal Browser.

It is programmed in C++ and its source code is open source. Though it's made for task automation which doesn't fit much in our application, the speed it offers makes it easier to run faster which is why we decided to create an application using this language.


## Code Dependencies

1. [AHK2ExtLib](https://github.com/verdaderoken/AHK2ExtLib) - a personalized extended library for AutoHotkey v2
2. KConfig - customized configuration serializer/deserializer 
3. SevenZip - AHK wrapper for 7zip


## Prerequisites

- Hymnal Database (.sda) file
- Microsoft Office PowerPoint or any .pptx-compatible software.


## Known Limitations

- Since this application is written in AHKv2, interface design is limited to what's available resources.
- Although efforts have been made to maximize user interface, the primary goal is focused on better functionality and reliability.


## Localization

Unfortunately, Hymnal Browser Lite only offers English and Tagalog presentations. We currently don't have plans for other languages as it will need to recreate the hymn files.

  
## Code Architecture

Classes are broken down into different files to keep the code organized and maintainable. The code structure relies on object-oriented programming.

The program consists of several classes in which every class has a different purpose. (See the list of classes below)

Since an [external library](#code-dependencies) is needed to make the program run properly, most of the functions are custom and may not be explained very well. Many custom codes are implemented and inspired by Python's syntax and terminology like the use of leading underscores ( _ ) to indicate a method that should only be used internally.

#### Syntax and Terminology

(No content yet.)

#### List of Classes

##### Core Classes
1. [System](src/system/system.ah2) - This handles system-related info of the application such as checking if the required folders are present, executing the main program, and getting the monitor number where the application is visible.
2. [UI](src/ui.ah2) - Handles user-interface behavior, threads, and connections between every control (or widgets) such as Search bar, Launch button, Suggestion box, and Hymn detail text. It also handles every control.
3. [Config](src/config.ah2) - Handles and processes the user-specified configuration. This also covers application-related configurations like `TME_QUERY` (Time before the search considers the count).
4. [Hymnal](src/hymnal.ah2) - Works with the hymnal package's content such as parsing and generating a map of the parsed data.
5. [Session](src/session.ah2) - Works similarly to the Config class but this handles only the data in the current session.
6. [Background](src/system/background.ah2) - Acts like the background thread/listener for the application. It covers events like detecting if the app is currently active or the window is moved. 
7. [Events](src/system/events.ah2) - Handle events forwarded by signals from controls or the system. This contains methods like `Events.System.Exit()` where the system will request a proper close event for the application.
8. [Errors](src/system/errors.ah2) - Handle errors properly for the system.
9. [Launcher](src/launcher.ah2) - Handles extraction and presentation launch for the application.
10. [File Management](src/system/fileManagement.ah2) - Manages the external files that are within the scope of the program such as removing temp files.
11. [SW/Software](src/software.ah2) - Contains metadata about the software such as `SW.TITLE` to retrieve the title of the application.

##### Interface Classes
12. [Buttons](src/interface/buttons.ah2) - Interface for buttons like **Clear** and **Launch** button.
13. [Search Bar](src/interface/searchbar.ah2) - The LineEdit/TextEdit where the user inputs the hymn.
14. [Completer](src/interface/completer.ah2) - A customized completer/suggestion box for the search bar.
15. [Context Menu](src/interface/contextMenu.ah2) - Handles context menu items and their behaviors.
16. [Main Menu](src/interface/mainmenu.ah2) - Interface for texts like the **Hymnal Browser Lite** title, the app version, and the hymn details.
17. [Settings](src/interface/settings.ah2) - **[Not implemented yet]** a GUI version of configuration where user can change settings via this window.

> Several classes are not implemented as a file in the program. For example, the `_LOG` object from `KLogger` class handles the logging for the app. This helps the developer to identify bugs easily. This also acts as a replacement for the default exception message box from AHK

#### Initialization Flow

##### 1. System Execution
The main program will start with the **Hymnal Browser Lite.ah2** file where AHK settings will be set and `System.Exec()` is called.

Inside `System.Exec()`, there are several instructions on setting up the interface, handlers, and threads.

The following statements are under the `System.Exec()` method.

`_STARTUP` - This variable starts the startup counter to measure how long the initialization will take time.

##### 2. Developer Mode
`System.CheckDevMode()` will check if the application is being run in script mode or the compiled mode. The differences are minimal but noticeable. These include (1) additional menu items in the context menu as well as (2) the indicator beside the version text. But more importantly, the `FileInstall` command will be only executed if the system detects a compiled mode.

##### 3. Configuration and Logger
Global variables like `_LOG` (KLogger) and `CF` (Config) are also initiated at this point. These are now the instance of their class, where `_LOG` handles logging and `CF` handles the configuration data of the application.

The system will now set the settings for `_LOG` object:
1. Verbose logging will be set according to `CF.MAIN.VERBOSE_LOG`.
    > In script mode, the verbose log will be always set to 1 (Enabled)
2. Max lines will be set according to `SW.LOG_MAX_LINES`.
    > Default value is set to 1,000 lines before the log is truncated

Since the KLogger is instantiated, several logs will be dumped:
- Application start message
- System information report
- Dev mode notice (Only shows in compiled mode)
- Process ID report
- Verbose logging status
- Core initialization message
  
> Config is always placed ahead of Logger to load the `CF.MAIN.VERBOSE_LOG` before instantiating the logger. Both instances are global.

##### 4. Tray Menu
Menu tray items are deleted and replaced with an **Exit** item. You can see this item by right-clicking the tray icon of Hymnal Browser Lite.

`Error.Setup()` will rebind the error messages to `Error.BaseError()` method if the `SW.ERROR_HANDLING` is set to True

##### 5. Directory Verification
The system will now verify each required directory. Directories are retrieved from `SW.DIRS`. Every absent directory will be created. After this, the system logs the report, including `MISSING` and `RESOLVED` directories if available.

##### 6. Requisites Verification (Presentation)
After directory verification, the system will now verify the presentation software that will be used later for launching.

There are two (2) situations that the program may encounter:
1. If the computer does not have an Office PowerPoint installed, the file will be executed by `Run()` command, in which in some cases, Windows will ask the user for the presentation software the '.pptx' file should be opened with. 
2. If **Microsoft Office PowerPoint** is detected (via registry path search), the retrieved value will be stored in `SW.FILE_POWERPOINT`

##### 7. Environments
System environments are loaded and stored in an `ENV` object. This contains the sensitive keys for the program.

##### 8. Hymnal
This part will now scan the hymnal package and retrieves its parsed content. The hymn package is specified in `CF.__FILE_HYMNALDB`. If the user changes the `[HYMNAL] PACKAGE = <name>` in settings.cfg (`SW.FILE_CONFIG`), the specified package will be used.

**HymnalDB._VerifyDatabase()** 

There are several directories for the package search. This includes:
1. `A_ScriptDir` or the directory where the .exe is located.
2. `SW.DIR_PROGRAM` or the program's directory in `A_CommonAppdata` (ProgramData)
3. `SW.DIR_DOCS_PROGRAM` or the program's directory in `Documents\MSDAC Systems`

Failure to find the package in these directories will result in `AbsentPackage` error in `Errors.HymnsDB`.

The package path is stored in `CF.__FILE_HYMNALDB` which will be used
later in Launcher class.

**HymnalDB.ScanHymnal()**

The method will return a map of all hymnal data such as the number of hymns in English, Tagalog, User, or both, the hymn titles, and hymn numbers.

The method uses `SevenZip` to read the contents inside the package.

The map object is stored in `HYMNAL` as a global variable.

##### 9. Session
The Session data will start. The object is stored in global `SES` and all properties in session data will be referenced as `SES.PROPERTY_NAME`.

##### 10. User Interface
The user interface or [UI](src/ui.ah2) will execute several instructions for its `UI.Setup()` method, in which the individual controls are initialized.

It calls every UI element specified in `UI.UIs` array and holds its object to bind all objects together in a UI's property.

> Class names are different from provided class names in static variable `_NAME`. (e.g: ContextMenu class is referenced as UI.RCTX, not UI.ContextMenu)

For example, the `UI.CPLTR` is referencing the Completer object that is instantiated in the setup method.

**UI.ConnectEvents()**

After instantiating all UI elements, their events will now connect to `Events` class where Events will handle their function

**UI.StartThreads()**

The setup will now invoke the `UI.StartThreads()` to start the background listeners of some UI elements like the search bar.

**UI.Keybinds**

The UI will now bind certain keys to its function. One of examples is the <kbd>Ctrl</kbd> + <kbd>Backspace</kbd> which is connected to `UI.SEARCH.Keypress` to emulate a regular key combination in search bar (because it's apparently not working in AHK).

##### 11. Background Thread
After setting up the UI, the `BackgroundThread` class will now be initialized. This class contains methods that are in a [timer](https://lexikos.github.io/v2/docs/commands/SetTimer.htm) with a specific period defined by `SW.BG_REF_RATE`

One of the methods it contains is the `BackgroundThread.WindowListener()` that detects and listens to the activity of the main window if it's active or not, or whether the main window was moved.

The hymn stats can be also found here which listens at different periods (custom listener) and logs a query and launch for a particular hymn.

##### 12. Initialization Complete
Before the initialization is complete, the `_LOG` will dump all postponed logs to the log file.

After that, the main window will now show the saved coordinates (if available) provided by `CF.WINDOW.XPOS` and `CF.WINDOW.YPOS`

A completion log will be sent to the logger along with the startup time that was declared [here](#1-system-execution).

`_RUNTIME` will now start to mark the runtime of the program.

At this point, the program is now ready for usage, assuming that there was no error encountered by the system as discussed in [Error handling](#error-handling).

### User Interface

This section contains all the details about the controls of the UI.

The application utilizes 3 GUI interfaces:
1. Main Window
2. Completer Window
3. Settings Window

Two context menus are found in the main window and the tray menu icon.

There are seven (7) elements that can be found in the main window (from left to right, top to bottom):
1. Title Text (Hymnal Browser Lite)
2. Version Text
3. Detail Text
4. Last launched **[Not implemented yet]**
5. Search Bar
6. Clear Button
7. Launch Button

In the completer window or the suggestion box, the only element is the **ListBox** where the hymns are shown. The secondary window is transparent.


#### Main Window Elements
|     Name      | Control Type | Description                                                                      |
| :-----------: | :----------: | -------------------------------------------------------------------------------- |
|  Title Text   |     Text     | Displays "Hymnal Browser Lite" with a primary color                              |
| Version Text  |     Text     | Displays the current version of the running app                                  |
|  Detail Text  |     Text     | Displays the details of the hymn: Base hymn and Equivalent hymn                  |
| Last Launched |     Text     | Dynamic text that displays the last launched time of the current hymn relatively |
|  Search Bar   |     Edit     | A single-line edit that acts as an input for search query                        |
| Clear Button  |    Button    | Clears the current search text                                                   |
| Launch Button |    Button    | Launches the hymn. Also displays how many hymns are matching during the search   |

#### Settings Window Elements
> Not implemented yet.

|      Name      | Control Type | Description |
| :------------: | :----------: | ----------- |
| Confirm Button |    Button    |             |


### Program Flow

### Error Handling

#### List of Exit Codes
These are the known exit codes covered by the program.
| Code  |      Name       |  Scope   | Description                       |
| :---: | :-------------: | :------: | --------------------------------- |
|   0   |    `ExitApp`    |  System  | Normal application exit           |
|   1   | `AbsentPackage` | HymnalDB | Hymnal package cannot be found    |
|   2   |    `ExitApp`    |  System  | Normal application exit           |
|  10   |   `ReloadApp`   |  System  | System reload request             |
|  13   |   `BaseError`   |   Base   | A standard error if not specified |

#### List of Error Names
- `AbsentPackage` - Hymnal package cannot be found
- `AbsentBinary`  - Binary 7z.exe cannot be found in `A_Temp`


### Events
This event class consists of nested classes.
#### System
##### Exit
This event handles the proper exit of the application. Critical errors are also forwarded to this method to safely terminate the program.

The exit code defines the severity of the application exit. (See [list of exit codes](#list-of-exit-codes)) An exit code of 0 or 2 is normal.
##### Reload
Reloads the program. Also invokes `Events.System.Exit()` with an error code of `10` which requests for a program restart. This doesn't save the session data and does not take parameters to execute in the next launch.

#### Launch
##### Click
#### Settings
##### Click
#### Search
##### TextChanged
##### Clear


### Relation of Config and Software

The configuration and software share a similar purpose like storing a variable's value. However, there is a difference that makes these two comparable.

In the Config class, variables can be modified by the user once specified a custom value. On the other hand, the Software class variables are fixed and cannot be changed by the user.



## Acknowledgements
Special thanks to the AutoHotkey team and Lexikos for making this possible with AHK. 

Copyright © 2022 MSDAC Systems