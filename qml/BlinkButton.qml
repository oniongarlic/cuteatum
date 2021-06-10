import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

Button {
    id: btn
    checkable: true

    property bool tristate: false

    property color checkedColor: "red"
    property color notCheckedColor: "green"    

    background: Rectangle {
        id: btnBg
        implicitHeight: 50
        implicitWidth: 60

        SequentialAnimation on color {
            running: btn.state=='on'
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
