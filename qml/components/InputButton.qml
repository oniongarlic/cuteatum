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
    property string textLong;
    property string textShort;

    text: (compact || width<60) && textShort!='' ? textShort : textLong

    ToolTip.visible: hovered
    ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
    ToolTip.timeout: 5000
    ToolTip.text: textLong +" - "+ textShort

    property Rectangle statusIndicator: inputStatus;

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

            Rectangle {
                id: inputStatus
                width: 12
                height: 12
                radius: width/2
                border.width: 1
                border.color: "darkgrey"
                visible: false
                x: 2
                y: 2
            }
        }
    }
}
