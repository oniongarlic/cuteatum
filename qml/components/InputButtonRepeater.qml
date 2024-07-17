import QtQuick
import QtQuick.Controls

Repeater {
    id: r
    property ButtonGroup bg;
    property bool isPreview: false
    delegate: inputButtonComponent
    Component {
        id: inputButtonComponent
        InputButton {
            id: ib
            required property int index
            required property string longText
            required property string shortText
            textLong: longText
            textShort: shortText
            inputID: index
            isPreview: r.isPreview
            ButtonGroup.group: bg
        }
    }
}
