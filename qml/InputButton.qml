import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12

Button {
    id: btn
    autoExclusive: true
    checkable: true
    anchors.margins: 8

    Layout.fillWidth: true

    property int inputID: 0
    property bool compact: false
    property bool isPreview: false

    onCheckedChanged: console.debug("ABC"+checked)

    background: Rectangle {
        implicitWidth: btn.compact ? 60 : 80
        implicitHeight: btn.compact ? 25 : 60
        color: isPreview ? "#20e520" : "#e52020"
        border.width: 2
        border.color: btn.checked ? "#90e520" : "#101010"
    }

}
