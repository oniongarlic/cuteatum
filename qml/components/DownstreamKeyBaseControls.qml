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

    required property int dskIndex;

    onDskChanged: {
        if (!dsk)
            return;

        checkDownstream.checked=dsk.onAir
        dskTie.checked=dsk.tie
    }

    ToggleButton {
        id: checkDownstream
        text: "DSK "+dskIndex
        checkable: true
        onCheckedChanged: {
            dsk.setOnAir(checked)
        }
    }
    ToggleButton {
        id: dskTie
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
