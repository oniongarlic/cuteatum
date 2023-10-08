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
    width: root.width/1.2

    property double ratio: 16/9
    property int boxDragMargin: 16

    ListModel {
        id: ssModel
        ListElement { box: 1; dx: 0; dy: 0; s: 0.5; ena: true; }
        ListElement { box: 2; dx: 0.5; dy: 0; s: 0.5; ena: true; }
        ListElement { box: 3; dx: 0; dy: 0.5; s: 0.5; ena: true; }
        ListElement { box: 4; dx: 0.5; dy: 0.5; s: 0.5; ena: true; }
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

    property SuperSourceBox selectedBox;

    ColumnLayout {
        id: c
        anchors.fill: parent
        anchors.margins: 8
        RowLayout {
            id: ssc
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            Layout.margins: 2
            Rectangle {
                Layout.alignment: Qt.AlignTop
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: "green"
                border.color: "red"
                border.width: 1
                Layout.minimumWidth: 1920/8
                Layout.minimumHeight: 1080/8
                Layout.maximumWidth: 1920/2
                Layout.maximumHeight: 1080/2
                Layout.preferredWidth: ssc.width/1.1
                clip: true
                Rectangle {
                    id: superSourceContainer
                    width: parent.width
                    height: width/ratio
                    color: "grey"
                    clip: true

                    Repeater {
                        id: ssBoxParent
                        property int currentIndex: -1
                        onCurrentIndexChanged: {
                            console.debug(currentIndex)
                            for (var i=0;i<count;i++) {
                                var item=itemAt(i)
                                if (i==currentIndex) {
                                    item.z=1
                                    selectedBox=item;
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
                            defaultSize: s
                            visible: ena
                            onClicked: {
                                ssBoxParent.currentIndex=index
                            }
                        }
                    }
                }
            }
            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: false
                Layout.alignment: Qt.AlignTop
                SpinBox {
                    id: boxSize
                    from: 0
                    to: 100
                    enabled: selectedBox!=null
                    wheelEnabled: true
                    value: selectedBox.boxSize*100
                    onValueModified: {
                        selectedBox.setSize(value/100)
                    }
                }
            }
        }
        RowLayout {
            Layout.fillWidth: true
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
                enabled: selectedBox!=null
                text: "Visible"
                checked: selectedBox && selectedBox.enabled
                onCheckedChanged: selectedBox.enabled=checked
            }
            CheckBox {
                id: ssCropCheck
                enabled: selectedBox!=null
                text: "Crop"
                checked: selectedBox && selectedBox.crop
                onCheckedChanged: selectedBox.crop=checked
            }
        }
        GridLayout {
            Layout.fillWidth: true
            enabled: selectedBox && selectedBox.crop
            rows: 1
            columns: 4
            SpinBox {
                from: 0
                to: 2048
                stepSize: 1
                wheelEnabled: true
                editable: true
                inputMethodHints: Qt.ImhDigitsOnly
                value: selectedBox.cropTop
                onValueChanged: selectedBox.cropTop=value
            }
            SpinBox {
                from: 0
                to: 2048
                stepSize: 1
                wheelEnabled: true
                editable: true
                inputMethodHints: Qt.ImhDigitsOnly
                value: selectedBox.cropBottom
                onValueChanged: selectedBox.cropBottom=value
            }
            SpinBox {
                from: 0
                to: 2048
                stepSize: 1
                wheelEnabled: true
                editable: true
                inputMethodHints: Qt.ImhDigitsOnly
                value: selectedBox.cropLeft
                onValueChanged: selectedBox.cropLeft=value
            }
            SpinBox {
                from: 0
                to: 2048
                stepSize: 1
                wheelEnabled: true
                editable: true
                inputMethodHints: Qt.ImhDigitsOnly
                value: selectedBox.cropRight
                onValueChanged: selectedBox.cropRight=value
            }

        }

        RowLayout {
            Layout.fillWidth: true
            Button {
                text: "Set A"
            }
            Button {
                text: "Set B"
            }
        }
    }
}
