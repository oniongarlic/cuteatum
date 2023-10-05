import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.12
import ".."
import "../components"

import org.bm 1.0

Drawer {
    id: ssDrawer
    // enabled: atem.connected
    height: root.height
    width: root.width/1.5

    property double ratio: 16/9

    property int boxDragMargin: 16

    Rectangle {
        anchors.fill: parent
        color: "red"
        Rectangle {
            id: pImage
            width: parent.width
            height: width/ratio
            color: "grey"

            SuperSourceBox {
                boxId: 1
            }
            SuperSourceBox {
                defaultX: 0.5
                defaultY: 0
                boxId: 2
            }
            SuperSourceBox {
                defaultX: 0
                defaultY: 0.5
                boxId: 3
            }
            SuperSourceBox {
                defaultX: 0.5
                defaultY: 0.5
                boxId: 4
            }

        }
    }


}
