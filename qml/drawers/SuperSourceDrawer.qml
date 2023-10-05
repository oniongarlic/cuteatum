import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
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
                    visible: ss1Check.checked
                }
                SuperSourceBox {
                    id: ssb2
                    defaultX: 0.5
                    defaultY: 0
                    boxId: 2
                    visible: ss2Check.checked
                }
                SuperSourceBox {
                    id: ssb3
                    defaultX: 0
                    defaultY: 0.5
                    boxId: 3
                    visible: ss3Check.checked
                }
                SuperSourceBox {
                    id: ssb4
                    defaultX: 0.5
                    defaultY: 0.5
                    boxId: 4
                    visible: ss4Check.checked
                }
            }
        }
        RowLayout {
            CheckBox {
                id: ssLiveCheck
                text: "Live"
                checked: true
            }
            Button {
                text: "Commit"
                enabled: !ssLiveCheck.checked
            }
            CheckBox {
                id: ss1Check
                text: "1"
                checked: true
            }
            CheckBox {
                id: ss2Check
                text: "2"
                checked: true
            }
            CheckBox {
                id: ss3Check
                text: "3"
                checked: true
            }
            CheckBox {
                id: ss4Check
                text: "4"
                checked: true
            }
        }
        RowLayout {
            Button {
                text: "Set A"
            }
            Button {
                text: "Set B"
            }
        }
    }
}
