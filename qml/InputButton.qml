import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12

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

    background: Item {
        implicitWidth: btn.compact ? 60 : 80
        implicitHeight: btn.compact ? 25 : 60
        Rectangle {
            id: btnbg
            anchors.fill: parent
            color: isPreview ? "#20e520" : "#e52020"
            border.width: 1
            border.color: btn.checked ? "#90e520" : "#101010"
        }
        Glow {
            anchors.fill: parent
            radius: btn.checked ? 8 : 0
            samples: 12
            color: isPreview ? "#20e520" : "#e52020"
            source: btnbg
        }
    }

}
