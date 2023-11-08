import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

import org.bm 1.0

Drawer {
    id: macroDrawer
    height: root.height
    width: root.width/1.4
    Keys.onDigit1Pressed: runMacro(1)
    Keys.onDigit2Pressed: runMacro(2)
    Keys.onDigit3Pressed: runMacro(3)
    Keys.onDigit4Pressed: runMacro(4)
    Keys.onDigit5Pressed: runMacro(5)
    Keys.onDigit6Pressed: runMacro(6)
    Keys.onDigit7Pressed: runMacro(7)
    Keys.onDigit8Pressed: runMacro(8)
    Keys.onDigit9Pressed: runMacro(9)

    function runMacro(m) {
        if (atem.connected) {
            atem.runMacro(m)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        //enabled: atem.connected
        RowLayout {
            CheckBox {
                text: "Repeat"
                enabled: !atem.macroRunning
                onClicked: atem.setMacroRepeating(checked)
            }
            CheckBox {
                id: recordCheckbox
                enabled: !atem.macroRunning
                text: "Recording"
                icon.name: "media-record"
            }
            Button {
                text: "Stop"
                enabled: recordCheckbox.checked
                icon.name: "media-playback-stop"
                onClicked: atem.stopRecordingMacro();
            }
            Button {
                text: "Pause"
                enabled: atem.macroRecording
                onClicked: atem.addMacroPause(30)
            }
        }
        GridLayout {
            id: macroGrid
            Layout.fillHeight: true
            Layout.fillWidth: true
            columns: 5
            columnSpacing: 8
            rowSpacing: 8
            Repeater {
                model: macrosModel
                delegate: Button {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    // text: "M "+(index+1)
                    text: (index+1) +":" + name
                    icon.name: used ? "media-playback-start" : ""
                    highlighted: recordCheckbox.checked
                    enabled: !atem.macroRecording && !atem.macroRunning
                    onClicked: {
                        if (!recordCheckbox.checked)
                            atem.runMacro(index)
                        else
                            atem.startRecordingMacro(index, "Macro "+index+1, "");
                    }
                }
            }
        }
    }
}
