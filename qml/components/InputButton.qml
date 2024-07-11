import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
    id: btn
    autoExclusive: true
    checkable: true

    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.margins: 4

    Layout.minimumHeight: 25
    Layout.minimumWidth: 40

    required property int inputID;

    property bool compact: false
    property bool isPreview: false
    property string  textLong;
    property string  textShort;

    background: Item {
        implicitWidth: btn.compact ? 50 : 60
        implicitHeight: btn.compact ? 25 : 60
        Rectangle {
            id: btnbg
            anchors.fill: parent
            radius: 4
            color: btn.checked ? (isPreview ? "#20f520" : "#f53030") : (isPreview ? "#d0f5d0" : "#f5d0d0")
            border.width: btn.checked ? 2 : 1
            border.color: btn.checked ? "#90e520" : "#101010"
        }
    }
}
