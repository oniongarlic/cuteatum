# CuteAtum - Linux ATEM Switcher

Blackmagic Design ATEM Mini Switcher applications for Linux (or anything where Qt 6.5 can be run).

* Built with C++, Qt 6.5 & QtQuick
* Uses the libqatemcontrol library
* Works great on a Raspberry Pi with touchscreen (See screenshot and video)

Currently experimental and not ready for any kind of production use. Very much work in progress.

## Requirements

* Qt 6.5 or later
* QtMQTT 6.5 or later
* [libqatemcontrol fork](https://github.com/oniongarlic/libqatemcontrol) fork

## Tested switchers:

* Constellation HD 2 M/E
* ATEM Mini Pro ISO
* ATEM Mini Pro

## Implemented features:

* Autodiscovery of devices (requires avahi to be installed)
* Source selection, program/preview
* Output/AUX selection
* Preview/Program toggle
* Cut/Fade
* Fade to black
* Streaming start/stop
* Recording start/stop
* Macro interface
* SuperSource editor
* Can send switch status to MQTT broker
* Can be controlled trough MQTT messages

### SuperSource editor

A much more user friendly interface for editing SuperSource boxes than in the official software.
Quickly adjust position with mouse or keyboard. Possible to animate live between positions.

Todo:
* Support for recording animation macros is work in progress.
* Saving positions

### Macro interface

Quick access to triggering and recording macros.

## Todo & various ideas

* SuperSource keyframed timeline
* DVE editor in same style as the SuperSource editor
* CAN bus support
* Integration with HyperDecks control
* Integration with network/BLE controllable cameras
* PTZ camera control (visca IP)
* Control from Stream Deck(s)
* Timer controlled auto switching
* Source audio level auto switching
* Any other ? Please add as issue!
