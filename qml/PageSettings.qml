import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

// import "../components"

Page {
    id: settingsPage
    title: qsTr("Settings")
    objectName: "settings"

    Keys.onReleased: {
        if (event.key === Qt.Key_Back) {
            console.log("*** Back button")
            event.accepted = true;
            rootStack.pop()
        }
    }

    Flickable {
        anchors.fill: parent
        anchors.margins: 16
        contentHeight: c.height
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: c
            width: parent.width
            spacing: 8

            GroupBox {
                title: qsTr("Generic settings")
                Layout.fillWidth: true
                ColumnLayout {
                    CheckBox {
                        id: checkXXX
                        text: qsTr("Do something cool")
                        checked: true
                        enabled: false
                    }
                }
            }

            GroupBox {
                title: qsTr("MQTT Settings")
                Layout.fillWidth: true
                ColumnLayout {
                    anchors.fill: parent
                    CheckBox {
                        id: checkMQTTEnabled
                        text: qsTr("Connect to MQTT broker")
                        checked: true
                    }
                    TextField {
                        id: textMQTTHost
                        Layout.fillWidth: true
                        inputMethodHints: Qt.ImhPreferNumbers | Qt.ImhNoPredictiveText
                        placeholderText: "MQTT Broker address"
                    }
                    TextField {
                        id: textMQTTPort
                        Layout.fillWidth: true
                        inputMethodHints: Qt.ImhDigitsOnly | Qt.ImhNoPredictiveText
                        placeholderText: "MQTT Port"
                    }
                    CheckBox {
                        id: checkMQTTRemote
                        text: qsTr("Subscribe to remote access")
                        checked: true
                        enabled: false
                    }
                }
            }

            GroupBox {
                title: "Debug settings"
                Layout.fillWidth: true
                ColumnLayout {
                    CheckBox {
                        id: checkDevelopment
                        text: qsTr("Debug mode")
                        checked: false
                    }
                }
            }

            Button {
                text: "OK"
                onClicked: rootStack.pop();
            }
        }

    }
}
