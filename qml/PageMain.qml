import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2

Page {
    id: mainPage
    objectName: "main"

    background: Rectangle {
        gradient: Gradient {
            GradientStop { position: 0; color: "#bfa0a0" }
            GradientStop { position: 1; color: "#605050" }
        }
    }

    Keys.onSpacePressed: root.cutTransition();

    Keys.onReturnPressed: {
        var me=atem.mixEffect(0);
        me.autoTransition();
    }

    // Black
    Keys.onDigit0Pressed: root.setProgram(0)

    // Inputs
    Keys.onDigit1Pressed: root.setProgram(1)
    Keys.onDigit2Pressed: root.setProgram(2)
    Keys.onDigit3Pressed: root.setProgram(3)
    Keys.onDigit4Pressed: root.setProgram(4)

    // Still
    Keys.onDigit9Pressed: root.setProgram(3010)

    ButtonGroup {
        id: programGroup
        property int activeInput;
        onClicked: {
            root.setProgram(button.inputID)
        }
    }

    ButtonGroup {
        id: previewGroup
        property int activeInput;
        onClicked: {
            root.setPreview(button.inputID)
        }
    }

    GridLayout {
        id: container
        rowSpacing: 2
        columnSpacing: 4
        columns: 1
        rows: 4
        anchors.fill: parent
        enabled: atem.connected

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: 4
            spacing: 4
            InputButton {
                text: "C1"
                inputID: 1
                ButtonGroup.group: programGroup
            }
            InputButton {
                text: "C2"
                inputID: 2
                ButtonGroup.group: programGroup
            }
            InputButton {
                text: "C3"
                inputID: 3
                ButtonGroup.group: programGroup
            }
            InputButton {
                text: "C4"
                inputID: 4
                ButtonGroup.group: programGroup
            }
            InputButton {
                text: "Still"
                inputID: 3010
                ButtonGroup.group: programGroup
            }
            InputButton {
                text: "Black"
                inputID: 0
                compact: true
                ButtonGroup.group: programGroup
            }
            ColumnLayout {
                InputButton {
                    text: "Color 1"
                    inputID: 2001
                    compact: true
                    ButtonGroup.group: programGroup
                }
                InputButton {
                    text: "Color 2"
                    inputID: 2002
                    compact: true
                    ButtonGroup.group: programGroup
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: 4
            spacing: 4
            InputButton {
                text: "C1"
                inputID: 1
                isPreview: true
                ButtonGroup.group: previewGroup
            }
            InputButton {
                text: "C2"
                inputID: 2
                isPreview: true
                ButtonGroup.group: previewGroup
            }
            InputButton {
                text: "C3"
                inputID: 3
                isPreview: true
                ButtonGroup.group: previewGroup
            }
            InputButton {
                text: "C4"
                inputID: 4
                isPreview: true
                ButtonGroup.group: previewGroup
            }
            InputButton {
                text: "Still"
                inputID: 3010
                isPreview: true
                ButtonGroup.group: previewGroup
            }
            InputButton {
                text: "Black"
                inputID: 0
                isPreview: true
                compact: true
                ButtonGroup.group: previewGroup
            }
            ColumnLayout {
                spacing: 2
                InputButton {
                    text: "Color 1"
                    inputID: 2001
                    isPreview: true
                    compact: true
                    ButtonGroup.group: previewGroup
                }
                InputButton {
                    text: "Color 2"
                    inputID: 2002
                    isPreview: true
                    compact: true
                    ButtonGroup.group: previewGroup
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            CheckBox {
                text: "Key"
                onClicked: {
                    var me=atem.mixEffect(0);
                    me.setUpstreamKeyOnAir(0, checked)
                }
            }
            CheckBox {
                text: "KeyOnChange"
                onClicked: {
                    var me=atem.mixEffect(0);
                    me.setUpstreamKeyOnNextTransition(0, checked)
                }
            }

            BlinkButton {
                id: btnFTB
                text: "FTB"
                display: AbstractButton.TextUnderIcon
                onClicked: {
                    var me=atem.mixEffect(0);
                    me.toggleFadeToBlack();
                }
            }
            Button {
                id: btnCut
                text: "Cut"
                onClicked: {
                    var me=atem.mixEffect(0);
                    me.cut();
                }
            }
            Button {
                id: btnAuto
                text: "Auto"
                onClicked: {
                    var me=atem.mixEffect(0);
                    me.autoTransition();
                }
            }
            CheckBox {
                text: "DVEKey"
                onClicked: {
                    var me=atem.mixEffect(0);
                    me.setDVEKeyEnabled(checked)
                }
            }
        }

        RowLayout {
            spacing: 4
            Button {
                id: btnStreamStart
                text: "Stream"
                onClicked: {
                    atem.startStreaming();
                }
            }
            Button {
                id: btnStreamStop
                text: "Stop"
                onClicked: {
                    atem.stopStreaming();
                }
            }

            Button {
                id: btnRecStart
                text: "Record"
                onClicked: {
                    atem.startRecording();
                }
            }
            Button {
                id: btnRecStop
                text: "Stop"
                onClicked: {
                    atem.stopRecording();
                }
            }
        }

        Slider {
            Layout.fillHeight: true
            orientation: Qt.Vertical
            to: 10000
            from: 0
            stepSize: 100
            onMoved: {
                var me=atem.mixEffect(0);
                me.setTransitionPosition(value);
            }
            onPressedChanged: {
                if (!pressed) {
                    value=0;
                    var me=atem.mixEffect(0);
                    me.setTransitionPosition(0);
                }
            }
        }

    }
}
