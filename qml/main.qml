import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

import "drawers"

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

    property date atemTime;
    property string sTime;

    Shortcut {
        sequence: StandardKey.FullScreen
        onActivated: {
            visibility=Window.FullScreen
        }
    }

    Shortcut {
        sequence: StandardKey.Cancel
        enabled: root.visibility==Window.FullScreen
        onActivated: {
            visibility=Window.Windowed
        }
    }

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

    ListModel {
        id: atemSources
    }

    Dialog {
        id: nyaDialog
        standardButtons: Dialog.Ok | Dialog.Cancel
        width: parent.width/2
        title: "Connect to switcher"

        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)

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
        enabled: rootStack.depth<2
        Menu {
            title: "&File"

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
                text: "Save settings"
                enabled: atem.connected
                onClicked: atem.saveSettings();
            }

            MenuItem {
                text: "Clear settings"
                enabled: atem.connected
                onClicked: atem.clearSettings();
            }

            MenuSeparator {

            }

            MenuItem {
                text: "Settings..."
                onClicked: {
                    return rootStack.push(settingsView)
                }
            }

            MenuItem {
                text: "&Quit"
                onClicked: {
                    if (atem.connected)
                        atem.disconnectFromSwitcher();
                    Qt.quit();
                }
            }
        }
        Menu {
            title: "&Audio"
            enabled: atem.connected
            MenuItem {
                id: audioLevelsMenu
                checkable: true
                text: "Levels"
                onCheckedChanged: {
                    //atem.setAudioLevelsEnabled(checked)
                    fairlight.setAudioLevelsEnabled(checked)
                }
            }
            MenuItem {
                text: "Reset source peaks"
                onClicked: {
                    fairlight.resetPeakLevels(true, false)
                }
            }
            MenuItem {
                text: "Reset master peak"
                onClicked: {
                    fairlight.resetPeakLevels(false, true)
                }
            }
            MenuItem {
                text: "Reset all peak"
                onClicked: {
                    fairlight.resetPeakLevels(true, true)
                }
            }
            MenuItem {
                id: audioMonitorMenu
                checkable: true
                text: "Monitor"
                onCheckedChanged: {
                    atem.setAudioMonitorEnabled(checked)
                }
            }
        }
        Menu {
            title: "&Output"
            enabled: atem.connected
            InputMenuItem {                
                text: "Multiview"
                inputID: 9001
                ButtonGroup.group: outputGroup
            }
            InputMenuItem {                
                text: "Program"
                inputID: 10010
                ButtonGroup.group: outputGroup
            }
            InputMenuItem {                
                text: "Preview"
                inputID: 10011
                ButtonGroup.group: outputGroup
            }
            InputMenuItem {                
                text: "Input 1"
                inputID: 1
                ButtonGroup.group: outputGroup
            }
            InputMenuItem {                
                text: "Input 2"
                inputID: 2
                ButtonGroup.group: outputGroup
            }
            InputMenuItem {                
                text: "Input 3"
                inputID: 3
                ButtonGroup.group: outputGroup
            }
            InputMenuItem {                
                text: "Input 4"
                inputID: 4
                ButtonGroup.group: outputGroup
            }
            InputMenuItem {                
                text: "Direct input 1"
                inputID: 11001
                ButtonGroup.group: outputGroup
            }
        }
        Menu {
            title: "&Macros"
            MenuItem {
                text: "Show interface"
                action: actionMacros
            }
        }        
    }

    Action {
        id: actionMacros
        shortcut: "Ctrl+M"
        onTriggered: macroDrawer.open();
    }

    MacroDrawer {
        id: macroDrawer
        enabled: atem.connected        
    }

    InputButtonGroup {
        id: outputGroup
        activeInput: 0
        onClicked: {
            atem.setAuxSource(0, button.inputID);
        }
    }

    footer: ToolBar {
        RowLayout {
            anchors.fill: parent
            anchors.margins: 2
            spacing: 2
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
                id: timeMsg
                text: sTime
                Layout.fillWidth: true
            }
            Label {
                Layout.fillWidth: false
                visible: atem.streamingDatarate>0 && atem.connected
                text: atem.streamingTime
                Layout.alignment: Qt.AlignRight
            }
            Label {
                Layout.fillWidth: false
                visible: atem.streamingDatarate>0 && atem.connected
                text: atem.streamingDatarate/1000/1000 + " Mbps"
                Layout.alignment: Qt.AlignRight
            }
            Label {
                Layout.fillWidth: false
                visible: atem.streamingDatarate>0 && atem.connected
                text: atem.streamingCache
                Layout.alignment: Qt.AlignRight
            }
            ColumnLayout {
                Layout.preferredWidth: 100
                Layout.minimumWidth: 60
                Layout.maximumWidth: 200
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                ProgressBar {
                    id: audioLevelMainLeft
                    from: 0
                    to: 100
                }
                ProgressBar {
                    id: audioLevelMainRight
                    from: 0
                    to: 100
                }
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
            me: !atem.connected ? null : atem.mixEffect(0)
            fl: !atem.connected ? null : fairlight
            dsk: !atem.connected ? null : atem.downstreamKey(0)
            ss: !atem.connected ? null : superSource
        }
    }

    Component {
        id: settingsView
        PageSettings {

        }
    }

    function loadSettings() {
        mqttEnabled=settings.getSettingsBool("mqttEnabled", true)
        mqttHostname=settings.getSettingsStr("mqttHostname", "localhost");
        mqttPort=settings.getSettingsInt("mqttPort", 1883);
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

        property int camInputs: 0
        property int supersources: 0

        onConnected: {
            console.debug("Connected!")
            console.debug(productInformation())

            console.debug(colorGeneratorColor(0))
            console.debug(colorGeneratorColor(1))

            console.debug(tallyIndexCount())
            camInputs=tallyIndexCount()

            console.debug(mediaPlayerType(0))

            console.debug(audioChannelCount())

            var topo=topology();
            console.debug("ME:"+topo.MEs)
            console.debug("SR:"+topo.sources)
            console.debug("CG:"+topo.colorGenerators)
            console.debug("AU:"+topo.auxBusses)
            console.debug("DO:"+topo.downstreamKeyers)
            console.debug("UP:"+topo.upstreamKeyers)
            console.debug("ST:"+topo.stingers)
            console.debug("DVE:"+topo.DVEs)
            console.debug("SS:"+topo.supersources)

            supersources=topo.supersources

            requestRecordingStatus();
            requestStreamingStatus();

            var me=atem.mixEffect(0);

            if (me) {
                console.debug("Keys: "+me.upstreamKeyCount())

                meCon.target=me;
                meCon.program=me.programInput();
                meCon.preview=me.previewInput();                

                dumpMixerState()

                //mainView.ftb=me.fadeToBlackEnabled();
            } else {
                console.debug("No Mixer!")
            }
            deviceID=hostname();
            conMsg.text=productInformation()+" ("+hostname()+")";
            mqttClient.publishActive(1)

            var inputs=inputInfoCount();
            console.debug("INPUTS: "+inputs)
            for (var i=0; i<inputs; i++) {
                var input=inputInfo(i);
                console.debug("INPUT: "+i)
                console.debug(" IDX:"+input.index)
                console.debug(" TAL:"+input.tally)
                console.debug(" EXT:"+input.externalType)
                console.debug(" INT:"+input.internalType)
                console.debug(" LTX:"+input.longText)
                console.debug(" STX:"+input.shortText)
            }
        }

        function dumpMixerState() {
            var me=atem.mixEffect(0);

            console.debug("upstreamKeyOnAir: "+ me.upstreamKeyOnAir(0))
            console.debug("upstreamKeyType: "+ me.upstreamKeyType(0))
            console.debug("upstreamKeyFillSource: "+ me.upstreamKeyFillSource(0))
            console.debug("upstreamKeyKeySource: "+ me.upstreamKeyKeySource(0))
            console.debug("Program is: "+me.programInput())
            console.debug("Preview is: "+me.previewInput())
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
            atemTime=tc;
            sTime=atemTime.toTimeString();
            mqttClient.publishTimeCode(tc)            
        }

        onAudioLevelsChanged: {
            console.debug("AudioLevel")
        }

        onSwitcherWarning: {
            console.debug(warningString)
            infoMsg.text=warningString;
        }

        onInputInfoChanged: console.debug(info)

        onMediaInfoChanged: console.debug(info)

        onStreamingDatarateChanged: {
            if (atem.streamingDatarate>0)
                mqttClient.publishOnAir(atem.streamingDatarate);
            else
                mqttClient.publishOnAir(0);
        }
        onStreamingCacheChanged: {
            console.debug("Cache status: "+cache)
        }

        onRecordingTimeChanged: {
            console.debug("Recording: "+time)
        }

        onStreamingTimeChanged: {
            console.debug("Streaming: "+time)
        }

        onTimecodeLockedChanged: {
            console.debug("TimecodeLock"+locked)
        }

        onAuxSourceChanged: {
            console.debug("AUX:"+aux+" = "+source)
            outputGroup.activeInput=source
            mqttClient.publishOutput(source)
        }

        onAudioMasterLevelsChanged: {
            console.debug(left)
            console.debug(right)
            audioLevelMainLeft.value=left/65535
            audioLevelMainRight.value=right/65535
        }
    }

    AtemFairlight {
        id: fairlight
        atemConnection: atem

        onAudioLevelChanged: {
            console.debug(audioSource+':= '+ levelLeft +':'+levelRight)
        }

        onTallyChanged: {
            console.debug('audioTally: '+audioSource)
        }
    }

    AtemSuperSource {
        id: superSource
        atemConnection: atem
        // superSourceID: 0
        onSuperSourceChanged: {
            console.debug("SuperSource updated for box: "+boxid)
        }
    }

    Timer {
        id: statusPoller
        interval: 1000
        repeat: true
        running: atem.connected && atem.timecodeLocked
        onTriggered: {
            atem.requestRecordingStatus();
            atem.requestStreamingStatus();
        }
    }

    Connections {
        id: meCon
        target: null

        property int program;
        property int preview;
        property bool ftb;
        property bool ftb_fading: false;
        property int ftb_frame;

        function onProgramInputChanged(newIndex) {
            console.debug("onProgramInputChanged:" +newIndex)
            program=newIndex;
            mqttClient.publishProgram(newIndex)
        }
        function onPreviewInputChanged(newIndex) {
            console.debug("onPreviewInputChanged:" +newIndex)
            preview=newIndex;
            mqttClient.publishPreview(newIndex)
        }
        function onFadeToBlackChanged(fading) {
            var me=atem.mixEffect(0);
            ftb_fading=fading
            ftb_frame=me.fadeToBlackFrameCount();
            ftb=me.fadeToBlackEnabled();
            mqttClient.publishFTB(me.fadeToBlackEnabled() ? 1 : 0)
        }

        function onFadeToBlackStatusChanged(status) {
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

        //onPingResponseReceived: console.debug("MQTT: Ping")

        //onMessageSent: console.debug("MQTT: Sent "+id)

        function publishActive(i) {
            publish(topicBase+"active", i, 1, true)
        }
        function publishProgram(i) {
            publish(topicBase+"program", i)
        }
        function publishPreview(i) {
            publish(topicBase+"preview", i)
        }
        function publishOutput(i) {
            publish(topicBase+"output", i)
        }
        function publishFTB(i) {
            publish(topicBase+"ftb", i)
        }
        function publishTimeCode(i) {
            publish(topicBase+"time", i)
        }
        function publishOnAir(i) {
            publish(topicBase+"onair", i)
        }
    }
}
