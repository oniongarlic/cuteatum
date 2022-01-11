import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2

Page {
    id: mainPage
    objectName: "main"

    property alias ftb: btnFTB.checked
    property int program;
    property int preview;

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

    InputButtonGroup {
        id: programGroup
        activeInput: meCon.program;
        onClicked: {
            root.setProgram(button.inputID)
        }
    }

    InputButtonGroup {
        id: previewGroup
        activeInput: meCon.preview;
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
            ColumnLayout {
                spacing: 2
                InputButton {
                    text: "Black"
                    inputID: 0
                    compact: true
                    ButtonGroup.group: programGroup
                }
                InputButton {
                    text: "Bars"
                    inputID: 1000
                    compact: true
                    ButtonGroup.group: programGroup
                }
            }
            ColumnLayout {
                spacing: 2
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
            ColumnLayout {
                spacing: 2
                InputButton {
                    text: "Black"
                    inputID: 0
                    isPreview: true
                    compact: true
                    ButtonGroup.group: previewGroup
                }
                InputButton {
                    text: "Bars"
                    inputID: 1000
                    isPreview: true
                    compact: true
                    ButtonGroup.group: previewGroup
                }
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

        InputButtonGroup {
            id: upstreamKeyFillSourceGroup
            // activeInput: meCon.preview;
            onClicked: {
                var me=atem.mixEffect(0);
                me.setUpstreamKeyFillSource(0, button.inputID)
            }
        }

        InputButtonGroup {
            id: upstreamKeySourceGroup
            // activeInput: meCon.preview;
            onClicked: {
                var me=atem.mixEffect(0);
                me.setUpstreamKeyKeySource(0, button.inputID)
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
                ButtonGroup.group: upstreamKeyFillSourceGroup
            }
            InputButton {
                text: "C2"
                inputID: 2
                isPreview: true
                ButtonGroup.group: upstreamKeyFillSourceGroup
            }
            InputButton {
                text: "C3"
                inputID: 3
                isPreview: true
                ButtonGroup.group: upstreamKeyFillSourceGroup
            }
            InputButton {
                text: "C4"
                inputID: 4
                isPreview: true
                ButtonGroup.group: upstreamKeyFillSourceGroup
            }
            InputButton {
                text: "Still"
                inputID: 3010
                isPreview: true
                ButtonGroup.group: upstreamKeyFillSourceGroup
            }
        }

        RowLayout {
            Layout.fillWidth: true

            ComboBox {
                // 0 = luma, 1 = chroma, 2 = pattern, 3 = DVE
                textRole: "text"
                valueRole: "keyType"
                model: ListModel {
                    ListElement { keyType: 0; text: "Luma" }
                    ListElement { keyType: 1; text: "Chroma" }
                    ListElement { keyType: 2; text: "Pattern" }
                    ListElement { keyType: 3; text: "DVE" }
                }
                onActivated: {
                    var me=atem.mixEffect(0);
                    me.setUpstreamKeyType(0, currentValue)
                }
            }


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
            CheckBox {
                text: "DVEKey"
                onClicked: {
                    var me=atem.mixEffect(0);
                    me.setDVEKeyEnabled(checked)
                }
            }

            ColumnLayout {

                RowLayout {
                    SpinBox {
                        id: dveXPos
                        editable: true
                        from: -125
                        to: 125
                        onValueModified: {
                            var me=atem.mixEffect(0);
                            me.setUpstreamKeyDVEPosition(0, value/10.0, me.upstreamKeyDVEYPosition(0))
                        }
                    }

                    SpinBox {
                        id: dveYPos
                        editable: true
                        from: -70
                        to: 70
                        onValueModified: {
                            var me=atem.mixEffect(0);
                            me.setUpstreamKeyDVEPosition(0, me.upstreamKeyDVEXPosition(0), value/10.0)
                        }
                    }
                }

                CheckBox {
                    id: lockAspect
                    text: "Lock"
                    checked: true
                }

                RowLayout {

                    SpinBox {
                        id: dveXSize
                        editable: true
                        from: 0
                        to: 100
                        onValueModified: {
                            var me=atem.mixEffect(0);
                            var v=value/100.0;
                            me.setUpstreamKeyDVESize(0, v, lockAspect ? v : me.upstreamKeyDVEYSize(0))
                        }
                    }

                    SpinBox {
                        id: dveYSize
                        editable: true
                        from: 0
                        to: 100
                        onValueModified: {
                            var me=atem.mixEffect(0);
                            var v=value/100.0;
                            me.setUpstreamKeyDVESize(0, lockAspect ? v : me.upstreamKeyDVEXSize(0), v)
                        }
                    }

                }

            }

            BlinkButton {
                id: btnFTB
                text: !meCon.ftb_fading ? "FTB" : meCon.ftb_frame
                display: AbstractButton.TextUnderIcon
                onClicked: {
                    var me=atem.mixEffect(0);
                    me.toggleFadeToBlack();
                }
                tristate: meCon.ftb_fading
                checked: meCon.ftb
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
            Button {
                id: btnEasing
                text: "Easing"
                enabled: !easingTransition.running
                onClicked: {
                    easingTransition.start()
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
        
        PropertyAnimation {
            id: easingTransition
            duration: 5000
            easing.type: Easing.InOutBounce
            target: sliderTbar
            property: "value"
            from: 0
            to: 10000
        }

        Slider {
            id: sliderTbar
            Layout.fillHeight: true
            orientation: Qt.Vertical
            to: 10000
            from: 0
            stepSize: 100
            enabled: !easingTransition.running
            onValueChanged: {
                if (easingTransition.running) {
                    var me=atem.mixEffect(0);
                    me.setTransitionPosition(value);
                }
            }

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
