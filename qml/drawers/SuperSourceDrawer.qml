import QtQuick
import QtQuick.Controls
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

    property AtemSuperSource ss;

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

    function updateAtemLive() {
        if (ssLiveCheck.checked) {
            ss.setSuperSource(selectedBox.boxId-1,
                              selectedBox.enabled,
                              selectedBox.inputSource,
                              selectedBox.atemPosition,
                              selectedBox.atemSize,
                              selectedBox.crop,
                              selectedBox.atemCrop)
        }
    }


    ColumnLayout {
        id: c
        anchors.fill: parent
        anchors.margins: 8
        RowLayout {
            id: ssc
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            Layout.minimumHeight: 1080/10
            Layout.margins: 2
            Rectangle {
                Layout.alignment: Qt.AlignTop
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: "green"
                border.color: "red"
                border.width: 1
                Layout.minimumWidth: 1920/6
                Layout.minimumHeight: 1080/6
                Layout.maximumWidth: 1920/1.6
                Layout.maximumHeight: 1080/1.6
                Layout.preferredWidth: ssc.width/1.1
                clip: true
                Rectangle {
                    id: superSourceContainer
                    width: parent.width
                    height: width/ratio
                    color: "grey"
                    clip: true

                    Rectangle {
                        color: "transparent"
                        border.color: "black"
                        border.width: 1
                        width: parent.width/2
                        height: parent.height/2
                        x: parent.width/4
                        y: parent.height/4
                        opacity: 0.4
                    }

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
                            enabled: ena
                            visible: enabled || !ssHideDisabled.checked
                            selected: ssBoxParent.currentIndex==boxId-1
                            onClicked: {
                                ssBoxParent.currentIndex=index
                            }
                            onFocusChanged: {
                                if (focus)
                                    ssBoxParent.currentIndex=index
                            }
                            onAtemCropChanged: {
                                updateAtemLive()
                            }
                            onAtemSizeChanged: {
                                updateAtemLive()
                            }
                            onAtemPositionChanged: {
                                updateAtemLive()
                            }
                        }
                    }
                }
            }
            ColumnLayout {
                Layout.maximumWidth: 240
                Layout.minimumWidth: 160
                Layout.fillHeight: true
                Layout.fillWidth: false
                Layout.alignment: Qt.AlignTop
                enabled: selectedBox!=null

                ComboBox {
                    id: boxId
                    model: ssModel
                    displayText: "Box: " + currentText
                    textRole: "box"
                    currentIndex: ssBoxParent.currentIndex
                    onCurrentIndexChanged: ssBoxParent.currentIndex=currentIndex
                }

                CheckBox {
                    id: ssCheck
                    property SuperSourceBox ssbox;
                    enabled: selectedBox!=null
                    text: "Visible"
                    checked: selectedBox && selectedBox.enabled
                    onCheckedChanged: selectedBox.enabled=checked
                }

                ComboBox {
                    id: inputSourceCombo
                    Layout.fillWidth: true
                    model: atem.camInputs
                    onActivated: {

                    }
                }

                SpinBox {
                    id: boxX
                    Layout.fillWidth: true
                    from: -4800
                    to : 4800
                    stepSize: 50
                    wheelEnabled: true
                    value: selectedBox.boxCenterX*4800
                    onValueModified: {
                        selectedBox.setCenterX(value/4800)
                    }
                }
                SpinBox {
                    id: boxY
                    Layout.fillWidth: true
                    from: -4800
                    to: 4800
                    stepSize: 50
                    wheelEnabled: true
                    value: selectedBox.boxCenterY*4800
                    onValueModified: {
                        selectedBox.setCenterY(value/4800)
                    }
                }
                RowLayout {
                    Button {
                        text: "Center"
                        onClicked: {
                            selectedBox.setCenterX(0)
                            selectedBox.setCenterY(0)
                        }
                    }
                    Button {
                        text: "Inside"
                        onClicked: selectedBox.snapInside()
                    }
                }

                SpinBox {
                    id: boxSize
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    wheelEnabled: true
                    value: selectedBox.boxSize*100
                    onValueModified: {
                        selectedBox.setSize(value/100)
                    }
                }
                RowLayout {
                    Button {
                        text: "20%"
                        Layout.fillWidth: false
                        onClicked: selectedBox.boxSize=0.25
                    }
                    Button {
                        text: "50%"
                        Layout.fillWidth: false
                        onClicked: selectedBox.boxSize=0.50
                    }
                    Button {
                        text: "100%"
                        Layout.fillWidth: false
                        onClicked: selectedBox.boxSize=1.00
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
                enabled: selectedBox && !ssLiveCheck.checked
                onClicked: {
                    ss.setSuperSource(selectedBox.boxId-1,
                                      selectedBox.enabled,
                                      selectedBox.inputSource,
                                      selectedBox.atemPosition,
                                      selectedBox.atemSize,
                                      selectedBox.crop,
                                      selectedBox.atemCrop)
                }
            }

            CheckBox {
                id: ssHideDisabled
                text: "Hide disabled"
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
