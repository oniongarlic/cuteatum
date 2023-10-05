import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.12
import ".."

import org.bm 1.0

Drawer {
    id: macroDrawer
    enabled: atem.connected
    height: root.height
    width: root.width/2
    Keys.enabled: atem.connected
    Keys.onDigit1Pressed: atem.runMacro(1)
    Keys.onDigit2Pressed: atem.runMacro(2)
    Keys.onDigit3Pressed: atem.runMacro(3)
    Keys.onDigit4Pressed: atem.runMacro(4)
    Keys.onDigit5Pressed: atem.runMacro(5)
    Keys.onDigit6Pressed: atem.runMacro(6)
    Keys.onDigit7Pressed: atem.runMacro(7)
    Keys.onDigit8Pressed: atem.runMacro(8)
    Keys.onDigit9Pressed: atem.runMacro(9)
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        CheckBox {
            text: "Repeat"
            onClicked: atem.setMacroRepeating(checked)
        }
        GridLayout {
            id: macroGrid
            Layout.fillHeight: true
            Layout.fillWidth: true
            columns: 4
            columnSpacing: 8
            rowSpacing: 8
            Repeater {
                model: 24
                delegate: Button {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: "M "+(index+1)
                    onClicked: atem.runMacro(index+1)
                }
            }
        }
    }
}