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

    property alias me0: me0.target

    // XXX interferes with input widgets..
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

    function setDVEKey(checked) {
        var me=atem.mixEffect(0);
        if (keyType.currentValue!==3)
            me.setUpstreamKeyFlyEnabled(0, checked)
        else
            me.setDVEKeyEnabled(checked)
    }

    Connections {
        id: me0
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
        onConnectedChanged: {
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

    GridLayout {
        id: container
        rowSpacing: 1
        columnSpacing: 1
        columns: 2
        rows: 4
        anchors.fill: parent
        anchors.margins: 4
        enabled: atem.connected

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            //Layout.alignment: Qt.AlignHCenter
            Layout.margins: 0
            Layout.column: 0
            Layout.row: 0
            spacing: 2
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
                spacing: 0
                Layout.margins: 0
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
                spacing: 0
                Layout.margins: 0
                InputButton {
                    text: "Color 1"
                    inputID: 2001
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
                    inputID: 2002
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
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: 0
            Layout.column: 0
            Layout.row: 1
            spacing: 2
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

        GridLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.column: 0
            Layout.row: 2
            columns: 5
            columnSpacing: 2
            rows: 2
            rowSpacing: 0
            InputButton {
                text: "C1"
                inputID: 1
                isPreview: true
                compact: true
                ButtonGroup.group: upstreamKeyFillSourceGroup
            }
            InputButton {
                text: "C2"
                inputID: 2
                isPreview: true
                compact: true
                ButtonGroup.group: upstreamKeyFillSourceGroup
            }
            InputButton {
                text: "C3"
                inputID: 3
                isPreview: true
                compact: true
                ButtonGroup.group: upstreamKeyFillSourceGroup
            }
            InputButton {
                text: "C4"
                inputID: 4
                isPreview: true
                compact: true
                ButtonGroup.group: upstreamKeyFillSourceGroup
            }
            InputButton {
                text: "Still"
                inputID: 3010
                isPreview: true
                compact: true
                ButtonGroup.group: upstreamKeyFillSourceGroup
            }

            InputButton {
                text: "Color 1"
                inputID: 2001
                isPreview: true
                compact: true
                ButtonGroup.group: upstreamKeyFillSourceGroup
            }
            InputButton {
                text: "Color 2"
                inputID: 2002
                isPreview: true
                compact: true
                ButtonGroup.group: upstreamKeyFillSourceGroup
            }

            InputButton {
                text: "Black"
                inputID: 0
                isPreview: true
                compact: true
                ButtonGroup.group: upstreamKeyFillSourceGroup
            }
            InputButton {
                text: "Bars"
                inputID: 1000
                isPreview: true
                compact: true
                ButtonGroup.group: upstreamKeyFillSourceGroup
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.column: 0
            Layout.row: 3
            Layout.margins: 4

            ColumnLayout {
                ComboBox {
                    id: keyType
                    textRole: "text"
                    valueRole: "keyType"
                    model: ListModelKeyType {
                    }
                    onActivated: {
                        var me=atem.mixEffect(0);
                        me.setUpstreamKeyType(0, currentValue)
                        setDVEKey(checkDVEKey.checked)
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
                    id: checkDVEKey
                    text: "DVEKey"
                    onClicked: {
                        setDVEKey(checked)
                    }
                }
                CheckBox {
                    id: checkDownstream
                    text: "DSK1"
                    onCheckedChanged: {
                        var dsk=atem.downstreamKey(0);
                        dsk.setOnAir(checked)
                    }
                }
                Button {
                    text: "Auto-DSK"
                    onClicked: {
                        var dsk=atem.downstreamKey(0);
                        dsk.doAuto();
                    }
                }
            }

            GridLayout {
                rows: 3
                columns: 2

                Button {
                    text: "FS"
                    Layout.fillWidth: true
                    onClicked: {
                        var me=atem.mixEffect(0);
                        me.runUpstreamKeyTo(0, 3, 0)
                    }
                }
                Button {
                    text: "INF"
                    Layout.fillWidth: true
                    onClicked: {
                        var me=atem.mixEffect(0);
                        me.runUpstreamKeyTo(0, 4, 0) // center
                    }
                }
                Button {
                    text: "A"
                    Layout.fillWidth: true
                    onClicked: {
                        var me=atem.mixEffect(0);
                        me.runUpstreamKeyTo(0, 1, 0)
                    }
                }
                Button {
                    text: "B"
                    Layout.fillWidth: true
                    onClicked: {
                        var me=atem.mixEffect(0);
                        me.runUpstreamKeyTo(0, 2, 0)
                    }
                }
                Button {
                    text: "Animate"
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                    onClicked: {
                        var me=atem.mixEffect(0);
                        me.setUpstreamKeyDVEKeyFrame(0, 2)
                    }
                }
                DelayButton {
                    text: "Set A"
                    Layout.fillWidth: true
                    onActivated: {
                        var me=atem.mixEffect(0);
                        me.setUpstreamKeyDVEKeyFrame(0, 1)
                    }
                }
                DelayButton {
                    text: "Set B"
                    Layout.fillWidth: true                    
                    onActivated: {
                        var me=atem.mixEffect(0);
                        me.setUpstreamKeyDVEKeyFrame(0, 2)
                    }
                }

            }

            ColumnLayout {

                RowLayout {
                    SpinBox {
                        id: dveXPos
                        editable: true
                        from: -2000
                        to: 2000
                        stepSize: 10
                        wheelEnabled: true
                        onValueModified: {
                            if (!enabled) return;
                            var me=atem.mixEffect(0);
                            me.setUpstreamKeyDVEPosition(0, value/100.0, me.upstreamKeyDVEYPosition(0))
                        }
                    }                    

                    SpinBox {
                        id: dveYPos
                        editable: true
                        from: -2000
                        to: 2000
                        stepSize: 10
                        wheelEnabled: true
                        onValueModified: {
                            if (!enabled) return;
                            var me=atem.mixEffect(0);
                            me.setUpstreamKeyDVEPosition(0, me.upstreamKeyDVEXPosition(0), value/100.0)
                        }
                    }
                }

                RowLayout {
                    SpinBox {
                        id: dveXSize
                        editable: true
                        from: 0
                        to: 100
                        wheelEnabled: true
                        onValueModified: {
                            var me=atem.mixEffect(0);
                            var v=value/100.0;
                            me.setUpstreamKeyDVESize(0, v, lockAspect ? v : me.upstreamKeyDVEYSize(0))
                        }
                    }

                    CheckBox {
                        id: lockAspect
                        // text: "Lock"
                        checked: true
                    }

                    SpinBox {
                        id: dveYSize
                        editable: true
                        //visible: !lockAspect.checked
                        from: 0
                        to: 100
                        wheelEnabled: true
                        onValueModified: {
                            var me=atem.mixEffect(0);
                            var v=value/100.0;
                            me.setUpstreamKeyDVESize(0, lockAspect ? v : me.upstreamKeyDVEXSize(0), v)
                        }
                    }

                }

            }

            RowLayout {
                Layout.fillWidth: false
                Layout.column: 0
                Layout.row: 4
                Layout.margins: 4

                ColumnLayout {
                    Layout.fillWidth: true

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

                ColumnLayout {
                    Layout.fillWidth: true

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
            }
        }
        
        PropertyAnimation {
            id: easingTransition
            duration: 2000
            easing.type: Easing.InCubic
            target: sliderTbar
            property: "value"
            from: 0
            to: 10000
        }

        ParallelAnimation {
            id: dveAnimation

            property real xPosStart: 0
            property real xPosEnd: 0

            property real yPosStart: 0
            property real yPosEnd: 0

            property real sizeStart: 0
            property real sizeEnd: 0

            NumberAnimation { from: dveAnimation.xPosStart; to: dveAnimation.xPosEnd; duration: 1000; properties: "value"; target: dveXPos }
            NumberAnimation { from: dveAnimation.yPosStart; to: dveAnimation.yPosEnd; duration: 1000; properties: "value"; target: dveYPos }
            NumberAnimation { from: dveAnimation.sizeStart; to: dveAnimation.sizeEnd; duration: 1000; properties: "value"; target: [ dveXSize, dveYSize]}
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: false
            Layout.margins: 4
            Layout.column: 1
            Layout.row: 0
            Layout.rowSpan: 4

            Slider {
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter
                id: sliderTbar
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


            Button {
                Layout.fillWidth: true
                id: btnCut
                text: "Cut"
                onClicked: {
                    var me=atem.mixEffect(0);
                    me.cut();
                }
            }
            Button {
                Layout.fillWidth: true
                id: btnAuto
                text: "Auto"
                onClicked: {
                    var me=atem.mixEffect(0);
                    me.autoTransition();
                }
            }

            ColumnLayout {

                ComboBox {
                    id: easingType
                    textRole: "text"
                    valueRole: "easingType"
                    model: ListModelEasing {

                    }
                    onActivated: {
                        easingTransition.easing=currentValue
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
                    to: 10
                    value: 2
                    onValueModified: {
                        easingTransition.duration=value*1000;
                    }
                    background.implicitWidth: 100
                }

                Button {
                    Layout.fillWidth: true
                    id: btnEasing
                    text: "Easing"
                    enabled: !easingTransition.running
                    onClicked: {
                        easingTransition.start()
                    }
                }
            }

            BlinkButton {
                Layout.fillWidth: true
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

        }

    }
}
