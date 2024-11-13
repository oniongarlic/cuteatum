# CuteAtum - Linux ATEM Switcher

Blackmagic Design ATEM Mini Switcher applications for Linux (or anything where Qt 6.5 can be run).

* Built with C++, Qt 6.6 & QtQuick
* Uses the libqatemcontrol library
* Works great on a Raspberry Pi with touchscreen (See screenshot and video)

Currently experimental and not ready for any kind of production use.
Very much work in progress, there might be breaking changes from time to time.

## Requirements

* Qt 6.6 or later
* QtMQTT 6.6 or later
* [libqatemcontrol fork](https://github.com/oniongarlic/libqatemcontrol) fork, always to use latest version available

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
* SuperSource animation
* Can send switch status to MQTT broker
* Can be controlled trough MQTT messages

### SuperSource editor

A much more user friendly interface for editing SuperSource boxes than in the official software.
Quickly adjust position with mouse or keyboard. Possible to animate live between positions.

Todo:
* Support for recording animation macros is work in progress.
* Saving and loading pre made positions
* Animation timeline

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
