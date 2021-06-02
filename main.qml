import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2

import org.bm 1.0
import org.tal.servicediscovery 1.0

ApplicationWindow {
    width: 800
    height: 480
    visible: true
    title: qsTr("CuteAtum")

    background: Rectangle {
        gradient: Gradient {
            GradientStop { position: 0; color: "#bfa0a0" }
            GradientStop { position: 1; color: "#605050" }
        }
    }

    ServiceDiscovery {
        id: sd
        Component.onCompleted: {
            sd.startDiscovery();
        }
    }

    Dialog {
        id: nyaDialog
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        title: "Connect to switcher"
        TextField {
            id: ip
            inputMethodHints: Qt.ImhPreferNumbers | Qt.ImhNoPredictiveText
            placeholderText: "Switcher IP"
        }

        onAccepted: {
            nyaDialog.close();
            atem.connectToSwitcher(ip.text, 2000)
        }
    }

    menuBar: MenuBar {
        Menu {
            title: "File"

            MenuItem {
                text: "Connect..."
                onClicked: {
                    nyaDialog.open();
                }
            }

            MenuItem {
                text: "Default"
                //enabled: atem.connected()
                onClicked: atem.connectToSwitcher("192.168.0.48", 2000)
            }

            MenuItem {
                text: "Emulator"
                onClicked: atem.connectToSwitcher("192.168.1.89", 2000)
            }

            MenuItem {
                text: "Disconnect"
                //enabled: atem.connected()
                onClicked: atem.disconnectFromSwitcher();
            }

            MenuItem {
                text: "Quit"
                onClicked: Qt.quit();
            }
        }
        Menu {
            title: "Audio"
            MenuItem {
                checkable: true
                text: "Monitor"
                onCheckedChanged: {
                    atem.setAudioLevelsEnabled(checked)
                }
            }
        }
    }

    footer: ToolBar {
        RowLayout {
            anchors.fill: parent
            Label {
                id: conMsg
                text: ""
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
            }
            Label {
                id: infoMsg
                text: ""
                Layout.fillWidth: true
            }
            Label {
                Layout.fillWidth: false
                visible: atem.streamingDatarate>0
                text: atem.streamingDatarate/1000/1000 + " Mbps"
                Layout.alignment: Qt.AlignRight
            }
        }
    }

    ButtonGroup {
        id: programGroup
        property int activeInput;
        onClicked: {
            var me=atem.mixEffect(0);
            me.changeProgramInput(button.inputID)
        }
    }

    ButtonGroup {
        id: previewGroup
        property int activeInput;
        onClicked: {
            var me=atem.mixEffect(0);
            me.changePreviewInput(button.inputID)
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

    Component.onCompleted: {
        atem.setDebugEnabled(true);
    }

    AtemConnection {
        id: atem

        onConnected: {
            console.debug("Connected!")
            console.debug(productInformation())

            var me=atem.mixEffect(0);

            if (me) {
                meCon.target=me
                console.debug("Program is"+me.programInput())
                console.debug("Preview is"+me.previewInput())
                console.debug("Keys: "+me.upstreamKeyCount())
                btnFTB.checked=me.fadeToBlackEnabled();
            } else {
                console.debug("No Mixer!")
            }
            conMsg.text=productInformation();
        }

        onDisconnected: {
            console.debug("Disconnected")
            conMsg.text='';
        }

        onTimeChanged: console.debug("Time: "+ getTime())

        onAudioLevelsChanged: {
            console.debug("AudioLevel")
        }

    }

    Connections {
        id: meCon

        onProgramInputChanged: console.debug("Program:" +newIndex)
        onPreviewInputChanged: console.debug("Preview:" +newIndex)
        onFadeToBlackChanged: {
            var me=atem.mixEffect(0);

            console.debug("FTB"+fading+enabled+me.fadeToBlackFrameCount())

            if (fading) {
                btnFTB.text=me.fadeToBlackFrameCount();
            } else {
                btnFTB.text="FTB"
            }
            btnFTB.tristate=fading
            btnFTB.checked=me.fadeToBlackEnabled();
        }
    }
}
