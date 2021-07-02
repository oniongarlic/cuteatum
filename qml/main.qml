import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12

import org.bm 1.0
import org.tal.servicediscovery 1.0
import org.tal.mqtt 1.0

ApplicationWindow {
    id: root
    width: 800
    height: 480
    visible: true
    title: qsTr("CuteAtum")

    // MQTT
    property bool mqttEnabled: false
    property string mqttHostname: "localhost"
    property int mqttPort: 1883

    ServiceDiscovery {
        id: sd

        onServicesFound: {
            var devs=getDevices();

            deviceModel.clear();

            for (var i=0; i<devs.length; i++) {
                console.log("Array item:", devs[i])
                deviceModel.append({"name": devs[i].name, "deviceIP": devs[i].ip, "port": devs[i].port})
            }

            // XXX: Static default test devices
            deviceModel.append({"name": "ATEM Mini Pro", "deviceIP": "192.168.1.99", "port": 9910})
            deviceModel.append({"name": "ATEM Mini Pro ISO", "deviceIP": "192.168.0.49", "port": 9910})
            deviceModel.append({"name": "Emulator", "deviceIP": "192.168.1.89", "port": 9910})
        }

        Component.onCompleted: {
            sd.startDiscovery();
        }
    }

    ListModel {
        id: deviceModel
    }

    Dialog {
        id: nyaDialog
        standardButtons: Dialog.Ok | Dialog.Cancel
        width: parent.width/3
        title: "Connect to switcher"
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
                        model: deviceModel
                        clip: true
                        delegate: Component {
                            Label {
                                text: name+"("+deviceIP+")"
                                MouseArea {
                                    anchors.fill: parent
                                    onDoubleClicked: {
                                        console.debug("DBCL")
                                        var dev=deviceModel.get(index)
                                        ipText.text=dev.deviceIP
                                        nyaDialog.close();
                                        atem.connectToSwitcher(dev.deviceIP, 2000)
                                    }
                                    onClicked: {
                                        console.debug("CL")
                                        var dev=deviceModel.get(index)
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
                    sd.startDiscovery();
                }
            }
        }

        onAccepted: {
            console.debug(result)
            nyaDialog.close();            
            atem.connectToSwitcher(ipText.text, 2000)
        }
    }

    menuBar: MenuBar {
        Menu {
            title: "File"

            MenuItem {
                text: "Connect..."
                enabled: !atem.connected
                onClicked: {
                    nyaDialog.open();
                }
            }

            MenuItem {
                text: "Disconnect"
                enabled: atem.connected
                onClicked: atem.disconnectFromSwitcher();
            }

            MenuItem {
                text: "Quit"
                onClicked: {
                    if (atem.connected)
                        atem.disconnectFromSwitcher();
                    Qt.quit();
                }
            }
        }
        Menu {
            title: "Audio"
            MenuItem {
                checkable: true
                text: "Levels"
                onCheckedChanged: {
                    atem.setAudioLevelsEnabled(checked)
                }
            }
            MenuItem {
                checkable: true
                text: "Monitor"
                onCheckedChanged: {
                    atem.setAudioMonitorEnabled(checked)
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
                visible: atem.streamingDatarate>0 && atem.connected
                text: atem.streamingDatarate/1000/1000 + " Mbps"
                Layout.alignment: Qt.AlignRight
            }
        }
    }

    StackView {
        id: rootStack
        anchors.fill: parent
        initialItem: mainView
        focus: true;
        onCurrentItemChanged: {
            console.debug("*** view is "+currentItem)
        }
    }

    Component {
        id: mainView
        PageMain {

        }
    }

    function loadSettings() {
        mqttEnabled=settings.getSettingsBool("mqttEnabled", true)
        mqttHostname=settings.getSettingsStr("mqttHostname", "localhost");
        mqttPort=settings.getSettingsStr("mqttPort", "localhost");
    }

    Component.onCompleted: {
        loadSettings();

        atem.setDebugEnabled(true);

        mqttClient.setHostname(mqttHostname)
        mqttClient.setPort(mqttPort)
        if (mqttEnabled) {
            mqttClient.connectToHost();
        }
    }

    function cutTransition() {
        var me=atem.mixEffect(0);
        me.cut();
    }

    function setProgram(i) {
        var me=atem.mixEffect(0);
        me.changeProgramInput(i)
    }

    function setPreview(i) {
        var me=atem.mixEffect(0);
        me.changePreviewInput(i)
    }

    AtemConnection {
        id: atem

        property string deviceID: ""

        onConnected: {
            console.debug("Connected!")
            console.debug(productInformation())

            var me=atem.mixEffect(0);

            if (me) {
                meCon.target=me
                console.debug("Program is: "+me.programInput())
                console.debug("Preview is: "+me.previewInput())
                console.debug("Keys: "+me.upstreamKeyCount())
                meCon.program=me.programInput();
                meCon.preview=me.previewInput();
                //mainView.ftb=me.fadeToBlackEnabled();
            } else {
                console.debug("No Mixer!")
            }
            deviceID=hostname();
            conMsg.text=productInformation()+" ("+hostname()+")";
            mqttClient.publishActive(1)
        }

        onAudioInputChanged: {
            console.debug("AudioInput changed "+index + " "+input)
        }

        onDisconnected: {
            console.debug("Disconnected")
            conMsg.text='';
            mqttClient.publishActive(0)
        }

        onTimeChanged: {
            var tc=getTime();
            console.debug("ATEM Time: "+ tc)
            mqttClient.publishTimeCode(tc)
        }

        onAudioLevelsChanged: {
            console.debug("AudioLevel")
        }        


    }

    Connections {
        id: meCon

        property int program;
        property int preview;
        property bool ftb;
        property bool ftb_fading: false;
        property int ftb_frame;

        onProgramInputChanged: {
            console.debug("Program:" +newIndex)
            program=newIndex;
            mqttClient.publishProgram(newIndex)
        }
        onPreviewInputChanged: {
            console.debug("Preview:" +newIndex)
            preview=newIndex;
            mqttClient.publishPreview(newIndex)
        }
        onFadeToBlackChanged: {
            var me=atem.mixEffect(0);
            ftb_fading=fading
            ftb_frame=me.fadeToBlackFrameCount();
            ftb=me.fadeToBlackEnabled();
            mqttClient.publishFTB(me.fadeToBlackEnabled() ? 1 : 0)
        }

        onFadeToBlackStatusChanged: {
            console.debug("FTB property status is "+status)
        }
    }

    MqttClient {
        id: mqttClient
        clientId: "cuteatum"
        hostname: mqttHostname
        // port: "1883"

        readonly property string topicBase: "cuteatum/"+atem.deviceID+"/"

        Component.onCompleted: {
            console.debug("MQTT")
        }

        onConnected: {
            console.debug("MQTT: Connected")
            publishActive(0)
            setWillTopic(topicBase+"active")
            setWillMessage(0)
        }

        onDisconnected: {
            console.debug("MQTT: Disconnected")
        }

        onErrorChanged: console.debug("MQTT: Error "+ error)

        onStateChanged: console.debug("MQTT: State "+state)

        onPingResponseReceived: console.debug("MQTT: Ping")

        onMessageSent: console.debug("MQTT: Sent "+id)

        function publishActive(i) {
            publish(topicBase+"active", i, 1, true)
        }
        function publishProgram(i) {
            publish(topicBase+"program", i)
        }
        function publishPreview(i) {
            publish(topicBase+"preview", i)
        }
        function publishFTB(i) {
            publish(topicBase+"ftb", i)
        }
        function publishTimeCode(i) {
            publish(topicBase+"time", i)
        }


    }

}
