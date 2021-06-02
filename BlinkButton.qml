import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

Button {
    id: btn
    checkable: true

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
                duration: 800
                easing.type: Easing.InOutCubic
                onRunningChanged: console.debug(running)
            }
            ColorAnimation {
                from: "red"
                to: "black"
                duration: 800
                easing.type: Easing.InOutQuad
                onRunningChanged: console.debug(running)
            }
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
