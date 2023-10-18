import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
    id: btn
    autoExclusive: true
    checkable: true
    anchors.margins: 0

    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.margins: 4

    Layout.minimumHeight: 25
    Layout.minimumWidth: 40

    property int inputID: 0
    property bool compact: false
    property bool isPreview: false

    onCheckedChanged: console.debug("ABC"+checked)

    background: Item {
        implicitWidth: btn.compact ? 50 : 60
        implicitHeight: btn.compact ? 25 : 60
        Rectangle {
            id: btnbg
            anchors.fill: parent
            color: isPreview ? "#20e520" : "#e52020"
            border.width: 1
            border.color: btn.checked ? "#90e520" : "#101010"
        }        
    }

}
