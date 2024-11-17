import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../models"

import org.bm 1.0

Drawer {
    id: dskDrawer
    interactive: visible
    width: parent.width/2
    height: root.height

    required property AtemMixEffect me;
    required property AtemDownstreamKey dsk;

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        Label {
            text: "Downstream key properties"
        }
        CheckBox {
            text: "Invert key"
            checked: dsk.invertKey
            onCheckedChanged: {
                dsk.setInvertKey(checked)
            }
        }
        CheckBox {
            text: "Pre multiplied"
            checked: dsk.preMultiplied
            onCheckedChanged: {
                dsk.setPreMultiplied(checked)
            }
        }
        CheckBox {
            text: "Enable mask"
            checked: dsk.enableMask
            onCheckedChanged: {
                dsk.setEnableMask(checked)
            }
        }
        Slider {
            from: 0
            to: 100
            stepSize: 1
            onValueChanged: {
                dsk.setClip(value/100)
            }
        }
        Slider {
            from: 0
            to: 100
            stepSize: 1
            onValueChanged: {
                dsk.setGain(value/100)
            }
        }
    }
}
