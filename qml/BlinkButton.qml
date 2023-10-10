import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Button {
    id: btn
    checkable: true

    property bool tristate: false
    property bool compact: false

    property bool blink: true

    property color checkedColor: "red"
    property color notCheckedColor: "green"

    implicitHeight: 25

    Layout.minimumHeight: 25
    Layout.minimumWidth: 40

    background: Rectangle {
        id: btnBg
        implicitWidth: btn.compact ? 50 : 60
        implicitHeight: btn.compact ? 25 : 60

        SequentialAnimation on color {
            running: btn.state=='on' && blink
            loops: Animation.Infinite
            ColorAnimation {
                from: "black"
                to: "red"
                duration: 600
                easing.type: Easing.InOutCubic
                onRunningChanged: console.debug(running)
            }
            ColorAnimation {
                from: "red"
                to: "black"
                duration: 600
                easing.type: Easing.InOutQuad
                onRunningChanged: console.debug(running)
            }
        }
        ColorAnimation {
            running: btn.state=='tristate'
            from: "#ff0000"
            to: "#af0000"
            duration: 600
            easing.type: Easing.InOutQuad
            onRunningChanged: console.debug(running)
        }
    }

    onStateChanged: console.debug("BlinkButtonState is: "+state)

    states: [
        State {
            name: "off"
            when: !btn.checked && !tristate
            PropertyChanges {
                target: btnBg
                color: btn.notCheckedColor
            }
        },        
        State {
            name: "tristate"
            when: tristate
        },
        State {
            name: "on"
            when: btn.checked && !tristate
        }
    ]

}
