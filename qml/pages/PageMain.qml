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
        id: me0
        target: me

        onUpstreamKeyDVEXPositionChanged: {
            console.debug("X:"+xPosition)
            dveXPos.enabled=false
            dveXPos.value=Math.floor(xPosition*100)
            dveXPos.enabled=true
        }

        onUpstreamKeyDVEYPositionChanged: {
            console.debug("Y:"+yPosition)
            dveYPos.enabled=false
            dveYPos.value=Math.ceil(yPosition*100)
            dveYPos.enabled=true
        }

        onUpstreamKeyDVEXSizeChanged: {
            console.debug("XS:"+xSize)
        }

        onUpstreamKeyDVEYSizeChanged: {
            console.debug("YS:"+ySize)
        }
    }

    Connections {
        id: dsk
    }

    Connections {
        target: atem
        function onConnectedChanged() {
            console.debug("ATEM Main Page: Connected")
            progColor1.color=""+atem.colorGeneratorColor(0)
            progColor2.color=""+atem.colorGeneratorColor(1)
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
        //enabled: atem.connected || root.debugEnabled
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
            InputButton {
                text: "SS1"
                inputID: AtemMixEffect.SuperSource1
                visible: atem.supersources>0
                ButtonGroup.group: programGroup
            }
            InputButton {
                text: "SS2"
                inputID: AtemMixEffect.SuperSource2
                visible: atem.supersources>1
                ButtonGroup.group: programGroup
            }
            InputButtonRepeater {
                model: mediaPlayersModel
                bg: programGroup
            }
            ColumnLayout {
                spacing: 0
                Layout.margins: 0
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
                spacing: 0
                Layout.margins: 0
                InputButton {
                    text: "Color 1"
                    inputID: AtemMixEffect.ColorGenerator1
                    compact: true
                    ButtonGroup.group: programGroup
                    Rectangle {
                        id: progColor1
                        width: 8
                        height: 8
                        x: 2
                        y: 2
                        visible: atem.connected
                    }
                }
                InputButton {
                    text: "Color 2"
                    inputID: AtemMixEffect.ColorGenerator2
                    compact: true
                    ButtonGroup.group: programGroup
                    Rectangle {
                        id: progColor2
                        width: 8
                        height: 8
                        x: 2
                        y: 2
                        visible: atem.connected
                    }
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
            InputButton {
                text: "SS1"
                inputID: AtemMixEffect.SuperSource1
                visible: atem.supersources>0
                isPreview: true
                ButtonGroup.group: previewGroup
            }
            InputButton {
                text: "SS2"
                inputID: AtemMixEffect.SuperSource2
                visible: atem.supersources>1
                isPreview: true
                ButtonGroup.group: previewGroup
            }
            InputButtonRepeater {
                model: mediaPlayersModel
                isPreview: true
                bg: previewGroup
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
            Layout.column: 0
            Layout.row: 3
            Layout.margins: 4

            Repeater {
                model: atem.connected ? me.upstreamKeyCount() : 0
                UpstreamKeyBaseControls {
                    required property int index;
                    usk: index
                    me: mainPage.me
                    Button {
                        text: "Properties"
                        onClicked: uskDrawer.open()
                    }
                }
            }            

            ColumnLayout {
                Label {
                    text: "DSK 1"
                }
                DownstreamKeyBaseControls {
                    me: mainPage.me
                    dsk: mainPage.dsk
                    model: keyAndMasksModel
                }
                Button {
                    text: "Properties"
                    onClicked: dskDrawer.open()
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

        ParallelAnimation {
            id: dveAnimation

            property real xPosStart: 0
            property real xPosEnd: 0

            property real yPosStart: 0
            property real yPosEnd: 0

            property real sizeStart: 0
            property real sizeEnd: 0

            property int duration: 1000

            NumberAnimation { from: dveAnimation.xPosStart; to: dveAnimation.xPosEnd; duration: dveAnimation.duration; properties: "value"; target: dveXPos }
            NumberAnimation { from: dveAnimation.yPosStart; to: dveAnimation.yPosEnd; duration: dveAnimation.duration; properties: "value"; target: dveYPos }
            NumberAnimation { from: dveAnimation.sizeStart; to: dveAnimation.sizeEnd; duration: dveAnimation.duration; properties: "value"; targets: [ dveXSize, dveYSize ]}
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: false
            Layout.margins: 4
            Layout.column: 1
            Layout.row: 0
            Layout.rowSpan: 4

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
                    enabled: !sliderTbar.running
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
