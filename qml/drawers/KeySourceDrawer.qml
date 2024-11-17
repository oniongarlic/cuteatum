import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../models"

import org.bm 1.0

Drawer {
    id: keySourceDrawer
    interactive: visible
    width: parent.width/1.5

    property int key: 0
    property AtemMixEffect me;

    InputButtonGroup {
        id: upstreamKeyFillSourceGroup
        onClicked: {
            me.setUpstreamKeyFillSource(key, button.inputID)
        }
    }

    InputButtonGroup {
        id: upstreamKeySourceGroup
        onClicked: {
            me.setUpstreamKeyKeySource(key, button.inputID)
        }
    }

    RowLayout {
        anchors.fill: parent
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: atem.camInputs<10 ? 8 : 10
            columnSpacing: 2
            rowSpacing: 2
            Repeater {
                model: atem.camInputs
                delegate: upstreamKeyFillButtonComponent
            }
            Component {
                id: upstreamKeyFillButtonComponent
                InputButton {
                    required property int index;
                    text: "C"+(index+1)
                    inputID: index+1
                    isPreview: true
                    compact: true
                    ButtonGroup.group: upstreamKeyFillSourceGroup
                }
            }
        }
        InputButton {
            text: "Still"
            inputID: AtemMixEffect.MediaPlayer1
            isPreview: true
            compact: true
            ButtonGroup.group: upstreamKeyFillSourceGroup
        }
        InputButton {
            text: "Color 1"
            inputID: AtemMixEffect.ColorGenerator1
            isPreview: true
            compact: true
            ButtonGroup.group: upstreamKeyFillSourceGroup
        }
        InputButton {
            text: "Color 2"
            inputID: AtemMixEffect.ColorGenerator2
            isPreview: true
            compact: true
            ButtonGroup.group: upstreamKeyFillSourceGroup
        }
        InputButton {
            text: "Black"
            inputID: AtemMixEffect.BlackInput
            isPreview: true
            compact: true
            ButtonGroup.group: upstreamKeyFillSourceGroup
        }
        InputButton {
            text: "Bars"
            inputID: AtemMixEffect.ColorBarsInput
            isPreview: true
            compact: true
            ButtonGroup.group: upstreamKeyFillSourceGroup
        }
    }
}
