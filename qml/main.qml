import QtCore
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

import QtQml.Models

import "drawers"
import "dialogs"
import "pages"
import "components"

import org.bm 1.0
import org.tal.servicediscovery 1.0
import org.tal.mqtt 1.0

ApplicationWindow {
    id: root
    width: 800
    height: 480
    visible: true
    minimumWidth: 800
    minimumHeight: 480
    title: qsTr("CuteAtum")

    // MQTT
    property bool mqttEnabled: false
    property string mqttHostname: "localhost"
    property int mqttPort: 1883

    // Debug
    property bool debugEnabled: false

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

    Settings {
        id: deviceConfig
        category: "device"
        property string previousDevice;
    }

    Settings {
        id: config
        property alias x: root.x
        property alias y: root.y
        property alias width: root.width
        property alias height: root.height
        property alias visibility: root.visibility
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
            if (debugEnabled) {
                deviceModel.append({"name": "ATEM Mini Pro", "deviceIP": "192.168.1.99", "port": 9910})
                deviceModel.append({"name": "ATEM Mini Pro ISO", "deviceIP": "192.168.0.49", "port": 9910})
                deviceModel.append({"name": "Emulator", "deviceIP": "192.168.1.89", "port": 9910})
            }
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

    ListModel {
        id: macrosModel
    }

    ConnectDialog {
        id: nyaDialog
        model: deviceModel

        onAccepted: {
            console.debug(result)
            nyaDialog.close();
            atem.connectToSwitcher(ip, 2000)
        }

        onRefresh: {
            sd.startDiscovery();
        }
    }

    menuBar: MenuBar {
        enabled: rootStack.depth<2
        visible: rootStack.depth<2
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
                id: forcePreviewMenu
                text: "Force preview"
                checkable: true
            }

            MenuItem {
                text: "SuperSource..."
                onClicked: {
                    return rootStack.push(superSourceView)
                }
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
            id: outputsMenu
            title: "&Outputs"
            enabled: atem.connected
            Instantiator {
                model: atem.outputs
                active: outputGroups.active && outputGroups.count>0
                delegate: Menu {
                    id: om
                    title: "Output "+index;
                    required property int index;
                    OutputMenuItem {
                        text: "Multiview"
                        ButtonGroup.group: outputGroups.objectAt(om.index)
                        inputID: 9001
                    }
                    OutputMenuItem {
                        text: "Program"
                        inputID: 10010
                        ButtonGroup.group: outputGroups.objectAt(om.index)
                    }
                    OutputMenuItem {
                        text: "Preview"
                        inputID: 10011
                        ButtonGroup.group: outputGroups.objectAt(om.index)
                    }
                    Repeater {
                        model: 4
                        OutputMenuItem {
                            required property int index;
                            text: "Input "+index+1
                            inputID: index+1
                            ButtonGroup.group: outputGroups.objectAt(om.index)
                        }
                    }
                    Component.onCompleted: console.debug("OutputMenu created", index)
                }
                onObjectAdded: (index, object) => outputsMenu.insertMenu(index, object)
                onObjectRemoved: (index, object) => outputsMenu.removeMenu(object)
            }

            OutputMenuItem {
                text: "Multiview"
                inputID: 9001
                ButtonGroup.group: outputGroup
            }
            OutputMenuItem {
                text: "Program"
                inputID: 10010
                ButtonGroup.group: outputGroup
            }
            OutputMenuItem {
                text: "Preview"
                inputID: 10011
                ButtonGroup.group: outputGroup
            }
            OutputMenuItem {
                text: "Input 1"
                inputID: 1
                ButtonGroup.group: outputGroup
            }
            OutputMenuItem {
                text: "Input 2"
                inputID: 2
                ButtonGroup.group: outputGroup
            }
            OutputMenuItem {
                text: "Input 3"
                inputID: 3
                ButtonGroup.group: outputGroup
            }
            OutputMenuItem {
                text: "Input 4"
                inputID: 4
                ButtonGroup.group: outputGroup
            }
            OutputMenuItem {
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
    }

    Instantiator {
        id: outputGroups
        model: atem.outputs
        active: atem.connected && atem.outputs>0
        delegate: OutputButtonGroup {
            required property int index;
            // activeSource: atem.auxSource(index)
            outputIndex: index
            onClicked: {
                atem.setAuxSource(outputIndex, button.inputID);
            }
            Component.onCompleted: {
                activeSource=atem.auxSource(index)
                console.debug("OutputGroup created", index)
            }
        }
    }

    OutputButtonGroup {
        id: outputGroup
        activeSource: atem.connected ? atem.auxSource(0) : 0
        outputIndex: 0
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
                visible: streaming.streamingDatarate>0 && atem.connected
                text: streaming.streamingTime
                Layout.alignment: Qt.AlignRight
            }
            Label {
                Layout.fillWidth: false
                visible: streaming.streamingDatarate>0 && atem.connected
                text: streaming.streamingDatarate/1000/1000 + " Mbps"
                Layout.alignment: Qt.AlignRight
            }
            Label {
                Layout.fillWidth: false
                visible: streaming.streamingDatarate>0 && atem.connected
                text: streaming.streamingCache
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
            //ss: !atem.connected ? null : superSource
            ss: superSource
            atemStream: streaming
            forcePreview: forcePreviewMenu.checked
        }
    }

    Component {
        id: settingsView
        PageSettings {

        }
    }

    Action {
        id: actionSuperSource
        shortcut: "Ctrl+F"
        onTriggered: rootStack.push(superSourceView)
    }

    Component {
        id: superSourceView
        PageSuperSource {
            ss: superSource
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
        if (deviceConfig.previousDevice!='')
            atem.connectToSwitcher(deviceConfig.previousDevice, 2000)
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
        property int mixers: 0
        property int supersources: 0
        property int dves: 0
        property int sources: 0
        property int outputs: 0
        property int stingers: 0
        property int downstreamKeyers: 0
        property int upstreamKeyers: 0
        property int colorGenerators: 0

        onConnected: {
            console.debug("Connected!")

            deviceConfig.previousDevice=hostname()

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

            mixers=topo.MEs
            supersources=topo.supersources
            stingers=topo.stingers
            outputs=topo.auxBusses
            downstreamKeyers=topo.downstreamKeyers
            upstreamKeyers=topo.upstreamKeyers
            colorGenerators=topo.colorGenerators
            dves=topo.DVEs

            requestRecordingStatus();
            streaming.requestStreamingStatus();

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

            var inputSources=inputInfos();

            console.debug(inputSources)

            for (var i=0; i<inputs; i++) {
                var input=inputInfo(i);
                console.debug("INPUT: "+i)
                console.debug(input)
                console.debug(" IDX:"+input.index)
                console.debug(" TAL:"+input.tally)
                console.debug(" EXT:"+input.externalType)
                console.debug(" INT:"+input.internalType)
                console.debug(" LTX:"+input.longText)
                console.debug(" STX:"+input.shortText)

                atemSources.append(input)
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

        onMacroRecordingStateChanged: {
            console.debug("MacroRecording state is")
            console.debug(macroIndex)
            console.debug(recording)
        }

        onMacroRunningStateChanged: {
            console.debug("MacroRunning state is")
            console.debug(macroIndex)
            console.debug(running)
            console.debug(repeating)
        }

        onMacroRunningChanged: {
            console.debug("MacroRunning: "+macroRunning)
        }

        onMacroRecordingChanged: {
            console.debug("MacroRecording: "+macroRecording)
        }

        onMacroInfoChanged: {
            console.debug("MacroInfo: "+index)
            let m={ "macroIndex": index, "used": info.used, "name": info.name, "description": info.description }
            console.debug(info)
            if (macrosModel.count<index)
                macrosModel.insert(index, m)
            else
                macrosModel.set(index, m)
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

        onRecordingTimeChanged: {
            console.debug("Recording: "+time)
        }

        onTimecodeLockedChanged: {
            console.debug("TimecodeLock"+locked)
        }

        onAuxSourceChanged: {
            console.debug("AUX:"+aux+" = "+source)
            outputGroup.activeSource=source
            mqttClient.publishOutput(source)
            outputGroups.objectAt(aux).activeSource=source;
        }

        onAudioMasterLevelsChanged: {
            console.debug(left)
            console.debug(right)
            audioLevelMainLeft.value=-left/65535
            audioLevelMainRight.value=-right/65535
        }
    }

    AtemFairlight {
        id: fairlight
        atemConnection: atem

        onAudioLevelChanged: {
            //console.debug(audioSource+':= '+ levelLeft +':'+levelRight)
        }

        onMasterAudioLevelChanged: {
            audioLevelMainLeft.value=levelLeft/6553
            audioLevelMainRight.value=levelRight/6553
        }

        onTallyChanged: {
            console.debug('audioTally: '+audioSource)
        }
    }

    AtemStreaming {
        id: streaming
        atemConnection: atem

        onStreamingDatarateChanged: {
            if (atem.streamingDatarate>0)
                mqttClient.publishOnAir(atem.streamingDatarate);
            else
                mqttClient.publishOnAir(0);
        }
        onStreamingCacheChanged: {
            console.debug("Cache status: "+cache)
        }

        onStreamingTimeChanged: {
            console.debug("Streaming: "+time)
        }

        onStreamingServiceUpdated: {
            console.debug(name)
            console.debug(url)
            console.debug(key)
        }

        onStreamingAuthenticatonUpdated: {
            console.debug(username)
            console.debug(password)
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
            streaming.requestStreamingStatus();
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

