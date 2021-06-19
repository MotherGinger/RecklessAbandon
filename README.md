# Reckless Abandon

A WoW addon that lets you quickly (and _recklessly_) abandon quests.

# Current Features

- Abandon individual quests with a single click
- Abandon all zone quests with a single click (prompts for confirmation by default)
- Abandon all campaign quests with a single click (prompts for confirmation by default)
- Command line option to abandon your entire quest log (disabled by default)
- Exclude individual quests from group abandons
- Configuration panel to toggle confirmations and hide/show abandon buttons
- Super tiny, less than 1MB of memory

# Upcoming features

Take a look at our [issue board](https://github.com/MotherGinger/RecklessAbandon/labels/enhancement) for scheduled enhancements and feature requests, or [submit your own](https://github.com/MotherGinger/RecklessAbandon/issues/new?assignees=&labels=enhancement&template=feature_request.md&title=%5BFeature+Request%5D) if you have an idea.

---

# Screenshots

## Quest Log Abandon Buttons

![WoWScrnShot_011621_135806](https://user-images.githubusercontent.com/29235654/104820560-8be32f00-5803-11eb-95da-5c6f0daa0855.jpg)

## Configuration Panel - General Options

![WoWScrnShot_011621_135740](https://user-images.githubusercontent.com/29235654/104820564-8d145c00-5803-11eb-9da1-9980b7ca9fe2.jpg)

## Configuration Panel - Exclusions

![WoWScrnShot_011621_135744](https://user-images.githubusercontent.com/29235654/104820563-8c7bc580-5803-11eb-9a97-e7d0165964c8.jpg)

## Configuration Panel - Commands

![WoWScrnShot_061921_011625](https://user-images.githubusercontent.com/29235654/122631971-96993d00-d09d-11eb-8135-acc0eab74f08.jpg)

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

### Exclude a quest from group abandons by questID

`/reckless exclude <questID>`

### Include a quest in group abandons by questID

`/reckless include <questID>`

### Abandon all quests that match a qualifier

`/reckless abandon <qualifier>`

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
