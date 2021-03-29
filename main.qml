import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2

import org.bm 1.0

ApplicationWindow {
    width: 800
    height: 480
    visible: true
    title: qsTr("CuteAtum")

    background: Rectangle {
       gradient: Gradient {
         GradientStop { position: 0; color: "#afafaf" }
         GradientStop { position: 1; color: "#505050" }
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
                text: "Disconnect"
                //enabled: atem.connected()
                onClicked: atem.disconnectFromSwitcher();
            }

            MenuItem {
                text: "Quit"
                onClicked: Qt.quit();
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
            }
        }
    }

    ButtonGroup {
        id: programGroup
        onClicked: {
            var me=atem.mixEffect(0);
            me.changeProgramInput(button.text)
        }
    }

    ButtonGroup {
        id: previewGroup
        onClicked: {
            var me=atem.mixEffect(0);
            me.changePreviewInput(button.text)
        }
    }

    ColumnLayout {
        id: container

        RowLayout {
            Label {
                text: "Program"
            }

            RadioButton {
                text: "1"                
                ButtonGroup.group: programGroup
            }
            RadioButton {
                text: "2"
                ButtonGroup.group: programGroup
            }
            RadioButton {
                text: "3"
                ButtonGroup.group: programGroup
            }
            RadioButton {
                text: "4"
                ButtonGroup.group: programGroup
            }
            RadioButton {
                text: "3010"
                ButtonGroup.group: programGroup
            }
        }

        RowLayout {
            Label {
                text: "Preview"
            }

            RadioButton {
                text: "1"
                ButtonGroup.group: previewGroup
            }
            RadioButton {
                text: "2"
                ButtonGroup.group: previewGroup
            }
            RadioButton {
                text: "3"
                ButtonGroup.group: previewGroup
            }
            RadioButton {
                text: "4"
                ButtonGroup.group: previewGroup
            }
            RadioButton {
                text: "3010"
                ButtonGroup.group: previewGroup
            }
        }

        RowLayout {
            CheckBox {
                text: "Key1"
                onClicked: {
                    var me=atem.mixEffect(0);
                    me.setUpstreamKeyOnAir(0, checked)
                }
            }
            CheckBox {
                text: "KeyOnChange"
                onClicked: {
                    var me=atem.mixEffect(0);
                    me.setUpstreamKeyOnNextTransition(0, true)
                }
            }

            CheckBox {
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
        }

        RowLayout {
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
        }

        Slider {
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
                console.debug(me.programInput())
                console.debug(me.previewInput())
                console.debug(me.upstreamKeyCount())
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

    }

    Connections {
        id: meCon

        onProgramInputChanged: console.debug("Program:" +newIndex)
        onPreviewInputChanged: console.debug("Preview:" +newIndex)
        onFadeToBlackChanged: {
            console.debug("FTB"+fading+enabled)
            var me=atem.mixEffect(0);
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
