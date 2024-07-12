import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.bm 1.0

ColumnLayout {
    id: dskControl
    Layout.fillWidth: false
    required property AtemMixEffect me;
    required property AtemDownstreamKey dsk;
    required property ListModel model;

    ToggleButton {
        id: checkDownstream
        text: "DSK1"
        checkable: true
        onCheckedChanged: {
            dsk.setOnAir(checked)
        }
    }
    ToggleButton {
        text: "Tie"
        onClicked: {
            dsk.setTie(checked);
        }
    }
    Button {
        text: "Auto"
        Layout.fillWidth: true
        onClicked: {
            dsk.doAuto();
        }
    }
    ComboBox {
        id: uskFillSource
        textRole: "longText"
        valueRole: "index"
        model: dskControl.model
        Layout.fillWidth: true
        onActivated: {
            dsk.setFillSource(currentValue)
        }
    }
    ComboBox {
        id: uskKeyMaskSource
        textRole: "longText"
        valueRole: "index"
        model: dskControl.model
        Layout.fillWidth: true
        onActivated: {
            dsk.setKeySource(currentValue)
        }
    }
}
