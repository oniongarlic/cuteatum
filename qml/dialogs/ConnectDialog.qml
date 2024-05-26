import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: nyaDialog
    standardButtons: Dialog.Ok | Dialog.Cancel
    width: Math.min(parent.width/2, 600)
    height: Math.min(parent.height/1.5, 400)
    title: "Connect to switcher"
    modal: true

    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)

    property alias model: deviceListView.model
    property alias ip: ipText.text

    signal refresh();

    ColumnLayout {
        anchors.fill: parent
        TextField {
            id: ipText
            Layout.fillWidth: true
            inputMethodHints: Qt.ImhPreferNumbers | Qt.ImhNoPredictiveText
            placeholderText: "Switcher IP"
        }
        Frame {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: ipText.height*4
            Layout.maximumHeight: ipText.height*5
            ColumnLayout {
                anchors.fill: parent
                ListView {
                    id: deviceListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    delegate: Component {
                        Label {
                            text: name+"("+deviceIP+")"
                            MouseArea {
                                anchors.fill: parent
                                onDoubleClicked: {
                                    var dev=deviceListView.model.get(index)
                                    ipText.text=dev.deviceIP
                                    nyaDialog.accept()
                                }
                                onClicked: {
                                    var dev=deviceListView.model.get(index)
                                    ipText.text=dev.deviceIP
                                }
                            }
                        }
                    }
                }

            }
        }
        Button {
            text: "Refresh"
            onClicked: {
                refresh();
            }
        }
    }

    onAccepted: {
        console.debug(result)
        atem.connectToSwitcher(ipText.text, 2000)
    }
}
