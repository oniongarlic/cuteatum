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

    ListModel {
        id: ssModel
        ListElement { box: 1; dx: 0; dy: 0; w: 0.5; h: 0.5; ena: true; }
        ListElement { box: 2; dx: 0.5; dy: 0; w: 0.5; h: 0.5; ena: true; }
        ListElement { box: 3; dx: 0; dy: 0.5; w: 0.5; h: 0.5; ena: true; }
        ListElement { box: 4; dx: 0.5; dy: 0.5; w: 0.5; h: 0.5; ena: true; }
    }

    Keys.onDigit1Pressed: selectBox(0)
    Keys.onDigit2Pressed: selectBox(1)
    Keys.onDigit3Pressed: selectBox(2)
    Keys.onDigit4Pressed: selectBox(3)

    function selectBox(i) {
        ssBoxParent.currentIndex=i;
        var item=itemAt(i)
        item.focus=true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: 2
            color: "green"
            Rectangle {
                id: superSourceContainer
                width: parent.width
                height: width/ratio
                color: "grey"

                Repeater {
                    id: ssBoxParent
                    property int currentIndex: -1
                    onCurrentIndexChanged: {
                        console.debug(currentIndex)
                        for (var i=0;i<count;i++) {
                            var item=itemAt(i)
                            if (i==currentIndex) {
                                item.z=1
                                ssCheck.ssbox=item;
                            } else {
                                item.z=0;
                            }
                        }

                    }
                    model: ssModel
                    delegate: SuperSourceBox {
                        boxId: box
                        defaultX: dx
                        defaultY: dy
                        visible: ena
                        onClicked: {
                            ssBoxParent.currentIndex=index
                        }
                    }
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
                id: ssCheck
                property SuperSourceBox ssbox;
                enabled: ssbox!=null
                text: "Visible"
                checked: ssbox.enabled
                onCheckedChanged: ssbox.enabled=checked
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
