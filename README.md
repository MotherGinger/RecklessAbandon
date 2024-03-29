# Reckless Abandon

A WoW addon that lets you quickly (and _recklessly_) abandon quests.

# Current Features

- Abandon individual quests with a single click
- Abandon all zone quests with a single click (prompts for confirmation by default)
- Abandon all campaign quests with a single click (prompts for confirmation by default)
- Command line option to abandon your entire quest log (disabled by default)
- Command line option to abandon groups of quests based on qualifiers (disabled by default)
  - Available Qualifiers: `gray`, `green`, `yellow`, `orange`, `red`, `daily`, `weekly`
- Exclude individual quests from group abandons
- Automation options to abandon quests automatically
- Configuration panel to toggle confirmations, hide/show abandon buttons, and setup keybindings
- Super tiny, less than 1MB of memory

# Upcoming features

Take a look at our [issue board](https://github.com/MotherGinger/RecklessAbandon/labels/enhancement) for scheduled enhancements and feature requests, or [submit your own](https://github.com/MotherGinger/RecklessAbandon/issues/new?assignees=&labels=enhancement&template=feature_request.md&title=%5BFeature+Request%5D) if you have an idea.

---

# Screenshots

## Quest Log Abandon Buttons

![WoWScrnShot_011621_135806](https://user-images.githubusercontent.com/29235654/104820560-8be32f00-5803-11eb-95da-5c6f0daa0855.jpg)

## Configuration Panel - General Options

![image](https://github.com/MotherGinger/RecklessAbandon/assets/29235654/efc35b15-0dbd-4b25-84b9-6067f1f55e06)

## Configuration Panel - Automation Options

![image2](https://user-images.githubusercontent.com/29235654/185288903-c1567d80-d930-4900-baec-0e54d5ed7688.png)

## Configuration Panel - Exclusions

![image3](https://user-images.githubusercontent.com/29235654/185288977-35e65f00-99fd-4395-9a45-afb3210d164c.png)

## Configuration Panel - Commands

![image4](https://user-images.githubusercontent.com/29235654/185289043-560f106a-c837-49f0-9389-d4431bf18f01.png)

## Configuration Panel - Profiles

![WoWScrnShot_011621_135752](https://user-images.githubusercontent.com/29235654/104820561-8be32f00-5803-11eb-8526-14e58d8d7e87.jpg)

---

# Usage

The following outlines how to use Reckless Abandon

## Quest Log

All quest log abandon buttons are shown by default with the exclusion of covenant callings

### Abandoning a Quest

Left click the abandon button next to a quest

### Abandoning All Quests in a Zone or Campaign

Left click the abandon button next to a zone or campaign header

### Excluding a Quest From Group Abandons

Right click the abandon button for an individual quest
Right click the abandon button again to include it

## Opening the Configuration Panel

To open the configuration panel run `/reckless config`

## Command Line Usage

All commands are disabled by default. You can enable them in the configuration panel.

### List all quests in a table

`/reckless list all`

### Abandon all quests

`/reckless abandon all`

### Abandon a quest by quest ID

`/reckless abandon <questId>`

### Abandon all quests that match a qualifier

`/reckless abandon <qualifier>`

### Exclude a quest from group abandons by questID

`/reckless exclude <questID>`

### Include a quest in group abandons by questID

`/reckless include <questID>`

### Toggle debugging

`/reckless debug`

---

# Contributing

Take a look at our [contribution guidelines](https://github.com/MotherGinger/RecklessAbandon/blob/main/CONTRIBUTING.md).

# Reporting an Issue

To report an issue please fill out a [bug report](https://github.com/MotherGinger/RecklessAbandon/issues/new?assignees=MotherGinger&labels=&template=bug_report.md&title=%5BBug+Report%5D). Reports should typically be reviewed within 24 hours.

# Frequently Asked Questions

- **Why can't I abandon covenant callings?**
  - _Blizzard currently [does not allow covenant callings to be abandoned](https://www.wowhead.com/guides/covenant-callings-shadowlands#:~:text=Like%20World%20Quests%2C%20Covenant%20Callings,Calling%20or%20let%20it%20expire.). You must let them expire._
- **Does Reckless Abandon only work with ElvUI?**
  - _No, I just happen to use ElvUI so the screenshots are skinned. Reckless Abandon works with or without ElvUI._
- **Does Reckless Abandon work in classic?**
  - _Yes! Check it out [here](https://github.com/MotherGinger/RecklessAbandon-Classic) and on CurseForge._
