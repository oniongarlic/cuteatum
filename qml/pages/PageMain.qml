import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import "../drawers"
import "../models"
import "../components"

import org.bm 1.0

Page {
    id: mainPage
    objectName: "main"

    property alias ftb: btnFTB.checked
    property int program;
    property int preview;

    property bool forcePreview: false

    property AtemMixEffect me;
    property AtemFairlight fl;
    property AtemDownstreamKey dsk;
    property AtemSuperSource ss;
    property AtemStreaming atemStream;
    property AtemRecording atemRecording;

    required property ListModel meSourcesModel;
    required property ListModel mediaPlayersModel;
    required property ListModel mediaModel;
    required property ListModel keySourceModel;
    //required property ListModel utputsModel;
    //required property ListModel outputSourcesModel;

    background: Rectangle {
        gradient: Gradient {
            GradientStop { position: 0; color: "#605050" }
            GradientStop { position: 1; color: "#af9090" }
        }
    }

    // XXX interferes with input widgets..
    Keys.onSpacePressed: root.cutTransition();
    Keys.onReturnPressed: {
        me.autoTransition();
    }

    // Black
    Keys.onDigit0Pressed: root.setProgram(0)

    // Inputs
    Keys.enabled: atem.connected
    Keys.onDigit1Pressed: root.setProgram(1)
    Keys.onDigit2Pressed: root.setProgram(2)
    Keys.onDigit3Pressed: root.setProgram(3)
    Keys.onDigit4Pressed: root.setProgram(4)

    Keys.onDigit5Pressed: root.setProgram(5)
    Keys.onDigit6Pressed: root.setProgram(6)
    Keys.onDigit7Pressed: root.setProgram(7)
    Keys.onDigit8Pressed: root.setProgram(8)

    Keys.onDigit9Pressed: root.setProgram(9)



    Connections {
        id: dsk
    }

    Connections {
        target: atem
        function onConnectedChanged() {
            console.debug("ATEM Main Page: Connected")
            progColor1.statusIndicator.color=""+atem.colorGeneratorColor(0)
            progColor2.statusIndicator.color=""+atem.colorGeneratorColor(1)
        }

        function onColorGeneratorColorChanged(generator, color) {
            console.debug("onColorGeneratorColorChanged", generator, color)
            switch (generator) {
            case 0:
                progColor1.statusIndicator.color=color
                break;
            case 1:
                progColor2.statusIndicator.color=color
                break;
            }


        }
    }

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

    KeySourceDrawer {
        id: keySourceDrawer
        me: mainPage.me
        key: 0
    }

    UpstreamKeyDrawer {
        id: uskDrawer
        edge: Qt.RightEdge
        me: mainPage.me
        key: 0

        function openUSK(i) {
            key=i;
            open();
        }
    }

    DownstreamKeyDrawer {
        id: dskDrawer
        edge: Qt.RightEdge
        dsk: mainPage.dsk
        me: mainPage.me
    }

    GridLayout {
        id: container
        rowSpacing: 1
        columnSpacing: 1
        columns: 2
        rows: 4
        anchors.fill: parent
        anchors.margins: 4
        enabled: atem.connected || root.debugEnabled
        visible: enabled

        RowLayout {
            id: inputProgramButtonRow
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            Layout.margins: 0
            Layout.column: 0
            Layout.row: 0
            spacing: 2
            visible: !forcePreview

            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: meSourcesModel.count<10 ? 8 : 10
                columnSpacing: 2
                rowSpacing: 2
                InputButtonRepeater {
                    model: meSourcesModel
                    bg: programGroup
                }
            }
            ColumnLayout {
                InputButton {
                    textLong: "Super Source 1"
                    textShort: "SS1"
                    inputID: AtemMixEffect.SuperSource1
                    visible: atem.supersources>0
                    ButtonGroup.group: programGroup
                }
                InputButton {
                    textLong: "Super Source 2"
                    textShort: "SS2"
                    inputID: AtemMixEffect.SuperSource2
                    visible: atem.supersources>1
                    ButtonGroup.group: programGroup
                }
            }
            ColumnLayout {
                InputButtonRepeater {
                    model: mediaPlayersModel
                    bg: programGroup
                }
            }
            ColumnLayout {
                InputButton {
                    text: "Black"
                    inputID: AtemMixEffect.BlackInput
                    compact: true
                    ButtonGroup.group: programGroup
                }
                InputButton {
                    text: "Bars"
                    inputID: AtemMixEffect.ColorBarsInput
                    compact: true
                    ButtonGroup.group: programGroup
                }
            }
            ColumnLayout {
                InputButton {
                    id: progColor1
                    text: "Color 1"
                    textShort: "COL1"
                    inputID: AtemMixEffect.ColorGenerator1
                    compact: true
                    statusIndicator.visible: true
                    ButtonGroup.group: programGroup
                }
                InputButton {
                    id: progColor2
                    text: "Color 2"
                    textShort: "COL2"
                    inputID: AtemMixEffect.ColorGenerator2
                    compact: true
                    statusIndicator.visible: true
                    ButtonGroup.group: programGroup
                }
            }
        }

        RowLayout {
            id: inputPreviewButtonRow
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            Layout.margins: 0
            Layout.column: 0
            Layout.row: 1
            spacing: 2
            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: atem.camInputs<10 ? 8 : 10
                columnSpacing: 2
                rowSpacing: 2
                InputButtonRepeater {
                    model: meSourcesModel
                    isPreview: true
                    bg: previewGroup
                }
            }
            ColumnLayout {
                InputButton {
                    textLong: "Super Source 1"
                    textShort: "SS1"
                    inputID: AtemMixEffect.SuperSource1
                    visible: atem.supersources>0
                    isPreview: true
                    ButtonGroup.group: previewGroup
                }
                InputButton {
                    textLong: "Super Source 2"
                    textShort: "SS2"
                    inputID: AtemMixEffect.SuperSource2
                    visible: atem.supersources>1
                    isPreview: true
                    ButtonGroup.group: previewGroup
                }
            }
            ColumnLayout {
                InputButtonRepeater {
                    model: mediaPlayersModel
                    isPreview: true
                    bg: previewGroup
                }
            }
            ColumnLayout {
                spacing: 0
                Layout.margins: 0
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
                spacing: 0
                Layout.margins: 0
                InputButton {
                    text: "Color 1"
                    textShort: "COL1"
                    inputID: 2001
                    isPreview: true
                    compact: true
                    statusIndicator.visible: true
                    statusIndicator.color: progColor1.statusIndicator.color
                    ButtonGroup.group: previewGroup
                }
                InputButton {
                    text: "Color 2"
                    textShort: "COL2"
                    inputID: 2002
                    isPreview: true
                    compact: true
                    statusIndicator.visible: true
                    statusIndicator.color: progColor2.statusIndicator.color
                    ButtonGroup.group: previewGroup
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.column: 0
            Layout.row: 3
            Layout.margins: 4

            Repeater {
                model: atem.connected ? me.upstreamKeyCount() : 0
                UpstreamKeyBaseControls {
                    id: uskbc
                    required property int index;
                    usk: index
                    me: mainPage.me
                    Button {
                        text: "Properties"
                        onClicked: uskDrawer.openUSK(index)
                    }
                }
            }

            Repeater {
                model: atem.downstreamKeyers

                ColumnLayout {
                    required property int index;
                    DownstreamKeyBaseControls {
                        me: mainPage.me
                        dsk: atem.connected ? atem.downstreamKey(index) : null
                        dskIndex: index+1
                        model: keyAndMasksModel
                    }
                    Button {
                        text: "Properties"
                        onClicked: dskDrawer.open()
                    }
                }
            }

            Repeater {
                model: mediaPlayersModel.count

                MediaPlayerBaseControls {
                    required property int index;
                    mp: index
                }
            }

            RowLayout {
                Layout.fillWidth: false
                Layout.column: 0
                Layout.row: 4
                Layout.margins: 4
                visible: atemStream.isSupported || atemRecording.isSupported

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Label {
                        text: "Streaming"
                    }
                    Button {
                        id: btnStreamStart
                        text: "Stream"
                        Layout.fillWidth: true
                        onClicked: {
                            atemStream.startStreaming();
                        }
                    }
                    Button {
                        id: btnStreamStop
                        text: "Stop"
                        Layout.fillWidth: true
                        onClicked: {
                            atemStream.stopStreaming();
                        }
                    }
                    Label {
                        text: "Recording"
                    }
                    Button {
                        id: btnRecStart
                        text: "Record"
                        Layout.fillWidth: true
                        onClicked: {
                            atem.startRecording();
                        }
                    }
                    Button {
                        id: btnRecStop
                        text: "Stop"
                        Layout.fillWidth: true
                        onClicked: {
                            atem.stopRecording();
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: false
            Layout.margins: 4
            Layout.column: 1
            Layout.row: 0
            Layout.rowSpan: 4
            Layout.alignment: Qt.AlignTop

            SliderTBar {
                id: sliderTbar
                me: mainPage.me
                Layout.fillHeight: true
                Layout.maximumHeight: parent.height/2
                Layout.alignment: Qt.AlignHCenter
            }

            Button {
                Layout.fillWidth: true
                Layout.minimumHeight: 40
                id: btnCut
                text: "Cut"
                onClicked: {
                    me.cut();
                }
            }
            Button {
                Layout.fillWidth: true
                Layout.minimumHeight: 40
                id: btnAuto
                text: "Auto"
                onClicked: {
                    me.autoTransition();
                }
            }
            ComboBox {
                textRole: "name"
                valueRole: "style"
                model: ListModelTransitions {}
                onActivated: {
                    me.setTransitionType(currentValue);
                }
            }

            ColumnLayout {
                Layout.fillWidth: true

                Button {
                    Layout.fillWidth: true
                    id: btnEasing
                    text: "Easing"
                    enabled: sliderTbar.enabled
                    onClicked: {
                        sliderTbar.start()
                    }
                }

                ComboBox {
                    id: easingType
                    textRole: "text"
                    valueRole: "easingType"
                    property int _tmp: 0
                    model: ListModelEasing {

                    }
                    onActivated: {
                        sliderTbar.easingType=currentValue
                    }
                    Component.onCompleted: {
                        currentIndex = indexOfValue(Easing.InCubic)
                    }
                }

                SpinBox {
                    Layout.fillWidth: true
                    id: easingDuration
                    editable: false
                    from: 0
                    to: 5000
                    value: 2000
                    stepSize: 100
                    wheelEnabled: true
                    onValueModified: {
                        sliderTbar.easingDuration=value;
                    }
                    background.implicitWidth: 100
                }
            }

            BlinkButton {
                Layout.fillWidth: true
                Layout.topMargin: 16
                id: btnFTB
                text: !meCon.ftb_fading ? "FTB" : meCon.ftb_frame
                display: AbstractButton.TextUnderIcon
                onClicked: {
                    me.toggleFadeToBlack();
                }
                tristate: meCon.ftb_fading
                checked: meCon.ftb
            }
        }
    }
}
