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
    width: root.width/1.3

    property double ratio: 16/9
    property int boxDragMargin: 16

    property SuperSourceBox currentBox: ssb1;

    ColumnLayout {
        anchors.fill: parent
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "green"
            Rectangle {
                id: superSourceContainer
                width: parent.width
                height: width/ratio
                color: "grey"

                SuperSourceBox {
                    id: ssb1
                    boxId: 1
                }
                SuperSourceBox {
                    id: ssb2
                    defaultX: 0.5
                    defaultY: 0
                    boxId: 2
                }
                SuperSourceBox {
                    id: ssb3
                    defaultX: 0
                    defaultY: 0.5
                    boxId: 3
                }
                SuperSourceBox {
                    id: ssb4
                    defaultX: 0.5
                    defaultY: 0.5
                    boxId: 4
                }
            }
        }

    }
}
