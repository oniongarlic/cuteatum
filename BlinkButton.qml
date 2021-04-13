import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

Button {
    id: btn
    checkable: true

    property color checkedColor: "red"
    property color notCheckedColor: "green"
    property color blinkColor: "white"

    background: Rectangle {
        id: btnBg
        implicitHeight: 50
        implicitWidth: 60

        ColorAnimation on color {
            running: btn.state=='on'
            from: "green"
            to: "red"
            duration: 600
            loops: Animation.Infinite
            onRunningChanged: console.debug(running)
        }
    }

    onStateChanged: console.debug(state)

    states: [
        State {
            name: "off"
            when: !btn.checked
            PropertyChanges {
                target: btnBg
                color: btn.notCheckedColor
            }
        },        
        State {
            name: "on"
            when: btn.checked
        }
    ]

}
