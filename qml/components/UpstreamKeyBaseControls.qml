import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.bm 1.0

import "../models"

ColumnLayout {
    Layout.fillWidth: false
    property int usk: 0
    required property AtemMixEffect me;
    Button {
        id: uskActive
        text: "Key "+(usk+1)
        checkable: true
        Layout.fillWidth: true
        onClicked: {
            me.setUpstreamKeyOnAir(usk, checked)
        }
    }
    ComboBox {
        id: uskFillSource
        textRole: "longText"
        valueRole: "index"
        model: keySourceModel
        Layout.fillWidth: true
        onActivated: {
            me.setUpstreamKeyFillSource(usk, currentValue)
        }
    }
    ComboBox {
        id: uskKeyMaskSource
        textRole: "longText"
        valueRole: "index"
        model: keySourceModel
        Layout.fillWidth: true
        visible: keyType.currentValue===0
        onActivated: {
            me.setUpstreamKeyKeySource(usk, currentValue)
        }
    }
    ComboBox {
        id: keyType
        textRole: "text"
        valueRole: "keyType"
        Layout.fillWidth: true
        model: ListModelKeyType {
        }
        onActivated: {
            me.setUpstreamKeyType(usk, currentValue)
            setDVEKey(usk, checkDVEKey.checked)
        }
    }
    Button {
        id: uskNextTransition
        text: "NT"
        checkable: true
        Layout.fillWidth: true
        onClicked: {
            me.setUpstreamKeyOnNextTransition(usk, checked)
        }
    }
}
