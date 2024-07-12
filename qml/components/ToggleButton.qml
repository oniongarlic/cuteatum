import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
    id: toggleButton
    checkable: true
    Layout.fillWidth: true

    property color checkedColor: "yellow"
    property color notCheckedColor: "lightyellow"

    background: Rectangle {
        color: toggleButton.checked ? checkedColor : notCheckedColor
        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }
    }
}
