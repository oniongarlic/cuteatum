import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.bm 1.0

import "../models"

ColumnLayout {
    Layout.fillWidth: false
    property int mp: 0

    ComboBox {
        Layout.fillWidth: true
        id: mediaPlayerMedia1
        textRole: "name"
        valueRole: "index"
        model: mediaModel
        onActivated: {
            atem.setMediaPlayerSource(mp, false, index)
        }
    }

    RowLayout {
        Button {
            text: "Play"
            icon.name: "media-playback-start"
            onClicked: atem.setMediaPlayerPlay(mp, true);
        }
        Button {
            text: "Beg"
            onClicked: atem.mediaPlayerGoToBeginning(mp)
        }
        Button {
            text: "Prev"
            onClicked: atem.mediaPlayerGoFrameBackward(mp)
        }
        Button {
            text: "Next"
            icon.name: "media-playback-forward"
            onClicked: atem.mediaPlayerGoFrameForward(mp)
        }
    }
}
