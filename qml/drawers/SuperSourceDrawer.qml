import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Timeline
import Qt.labs.qmlmodels

import ".."
import "../components"

import org.bm 1.0

Drawer {
    id: ssDrawer
    // enabled: atem.connected
    height: parent.height
    width: parent.width/1.2

    property double ratio: 16/9
    property int boxDragMargin: 16

    property AtemSuperSource ss;

    property var boxes: [];

    property var savedPosition: [];

    onSavedPositionChanged: console.debug(savedPosition)

    onAboutToShow: syncBoxStates();

    Component.onCompleted: {
        savePositions(0);
        savePositions(1);
    }

    function dumpBoxState(b) {
        console.debug(b.enabled)
        console.debug(b.source)
        console.debug(b.position)
        console.debug(b.size)
        console.debug(b.cropEnabled)
        console.debug(b.crop)
    }

    property bool animating: false

    function syncBoxStates() {
        if (!atem.connected)
            return;
        for (var i=0;i<4;i++) {
            boxes[i]=ss.getSuperSourceBox(i);
            dumpBoxState(boxes[i])
            var sb=ssBoxParent.itemAt(i);
            syncBoxState(boxes[i],sb)
        }
    }

    function syncBoxState(b, sb) {
        sb.enabled=b.enabled
        sb.inputSource=b.source
        sb.crop=b.cropEnabled
        sb.setAtemPosition(b.position)
        sb.setSize(b.size/1000)
    }

    Connections {
        target: ss
        onSuperSourceChanged: {
            console.debug('SSChanged: '+boxid)
            var b=ss.getSuperSourceBox(boxid);
            var sb=ssBoxParent.itemAt(boxid);
            syncBoxState(b, sb)
        }
    }

    function savePositions(bid) {
        savedPosition[bid]=[];
        for (var i=0;i<4;i++) {
            let item=ssBoxParent.itemAt(i)
            let v=item.getPositionVector3d();
            savedPosition[bid][i]=v;
        }
    }

    function preparePositions(bid) {
        for (var i=0;i<4;i++) {
            let v=savedPosition[bid][i];
            let item=ssBoxParent.itemAt(i)
            item.animateFrom=item.getPositionVector3d();
            item.animateTo=v;
        }
    }

    function loadPositions(bid) {
        for (var i=0;i<4;i++) {
            let v=savedPosition[bid][i];
            let item=ssBoxParent.itemAt(i)
            item.setPositionVector3d(v);
        }
    }

    function animateSuperSource(bid) {
        preparePositions(bid)
        for (var i=0;i<4;i++) {
            let item=ssBoxParent.itemAt(i)
            item.animate();
        }
    }

    ListModel {
        id: ssModel
        ListElement { box: 1; dx: -0.25; dy: -0.25; s: 0.5; ena: true; }
        ListElement { box: 2; dx: 0.25; dy: -0.25; s: 0.5; ena: true; }
        ListElement { box: 3; dx: -0.25; dy: 0.25; s: 0.5; ena: true; }
        ListElement { box: 4; dx: 0.25; dy: 0.25; s: 0.5; ena: true; }
    }

    QtObject {
        id: sproxy
        property double x;
        property double y;
        property double s;
        property int frame: 0;

        function append(f) {
            //let v={ "f": Math.round(f), "x": x.toFixed(2), "y": y.toFixed(2), "s": s.toFixed(2) }
            let v={ "f": frame++, "x": x.toFixed(3), "y": y.toFixed(3), "s": s.toFixed(3) }
            timelineModel.appendRow(v)
        }

        function clear() {
            timelineModel.clear()
            frame=0
        }
    }

    TableModel {
        id: timelineModel
        TableModelColumn { display: "f" }
        TableModelColumn { display: "x" }
        TableModelColumn { display: "y" }
        TableModelColumn { display: "s" }
    }

    Component {
        id: kfg
        KeyframeGroup {
            keyframes: [
                Keyframe { frame: 0; value: 0 },
                Keyframe { frame: 60; value: 0 }
            ]
            function setStartValue(v) {
                keyframes[0].value=v;
            }
            function setEndValue(v) {
                keyframes[1].value=v;
            }
            function setFromTo(f, t) {
                setStartValue(f)
                setEndValue(t)
            }
        }
    }

    Timeline {
        id: ssTimeLine
        startFrame: 0
        endFrame: 60
        enabled: true

        onCurrentFrameChanged: {
            sproxy.append(currentFrame)
        }

        Component.onCompleted: {
            let tx=kfg.createObject(ssTimeLine, { target: sproxy, property: "x" });
            let ty=kfg.createObject(ssTimeLine, { target: sproxy, property: "y" });
            let ts=kfg.createObject(ssTimeLine, { target: sproxy, property: "s" });

            tx.setFromTo(-0.5, 0.5)
            ty.setFromTo(-0.5, 0.5)
            ts.setFromTo(0.2, 1)

            keyframeGroups.push(tx)
            keyframeGroups.push(ty)
            keyframeGroups.push(ts)
        }

        animations: [
            TimelineAnimation {
                id: ssAnimation
                duration: 1000
                easing.type: Easing.InOutExpo
                from: ssTimeLine.startFrame
                to: ssTimeLine.endFrame
            }
        ]
    }

    function selectBox(i) {
        console.debug('KEYPRESS')
        ssBoxParent.currentIndex=i;
        var item=ssBoxParent.itemAt(i)
        item.focus=true
    }

    property SuperSourceBox selectedBox;

    function updateAtemLive(box, force) {
        if (ssLiveCheck.checked || force) {
            ss.setSuperSource(box.boxId-1,
                              box.enabled,
                              box.inputSource,
                              box.atemPosition,
                              box.atemSize,
                              box.crop,
                              box.atemCrop)
        }
    }

    onSelectedBoxChanged: {
        inputSourceCombo.currentIndex=inputSourceCombo.indexOfValue(selectedBox.inputSource)
        easingType.currentIndex=easingType.indexOfValue(selectedBox.animateEasing)
        easingDuration.value=selectedBox.animateDuration/1000;
    }

    ColumnLayout {
        id: c
        anchors.fill: parent
        anchors.margins: 8

        focus: true
        Keys.enabled: true
        Keys.onPressed: {
            switch (event.key) {
            case Qt.Key_F1:
                selectBox(0)
                event.accepted=true;
                break;
            case Qt.Key_F2:
                selectBox(1)
                event.accepted=true;
                break;
            case Qt.Key_F3:
                selectBox(2)
                event.accepted=true;
                break;
            case Qt.Key_F4:
                selectBox(3)
                event.accepted=true;
                break;
            }
        }

        RowLayout {
            id: ssc
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            Layout.minimumHeight: 1080/10
            Layout.margins: 2
            Rectangle {
                Layout.alignment: Qt.AlignTop
                color: "green"
                border.color: "red"
                border.width: 2
                Layout.preferredWidth: c.width/1.5
                Layout.preferredHeight: Layout.preferredWidth/ssDrawer.ratio
                clip: true
                Rectangle {
                    id: superSourceContainer
                    width: parent.width
                    height: width/ratio
                    color: "grey"
                    border.color: "red"
                    border.width: 2
                    clip: true

                    Rectangle {
                        color: "transparent"
                        border.color: "black"
                        border.width: 1
                        width: parent.width/2
                        height: parent.height/2
                        x: parent.width/4
                        y: parent.height/4
                        opacity: 0.4
                    }

                    Repeater {
                        id: ssBoxParent
                        property int currentIndex: -1
                        onCurrentIndexChanged: {
                            console.debug(currentIndex)
                            for (var i=0;i<count;i++) {
                                var item=itemAt(i)
                                if (i==currentIndex) {
                                    item.z=1
                                    selectedBox=item;
                                } else {
                                    item.z=0;
                                }
                            }
                        }
                        model: ssModel
                        delegate: SuperSourceBox {
                            id: ssboxDelegate
                            boxId: box
                            defaultX: dx
                            defaultY: dy
                            defaultSize: s
                            enabled: ena
                            visible: enabled || !ssHideDisabled.checked
                            selected: ssBoxParent.currentIndex==boxId-1
                            onClicked: {
                                ssBoxParent.currentIndex=index
                            }
                            onFocusChanged: {
                                if (focus)
                                    ssBoxParent.currentIndex=index
                            }
                            onAtemCropChanged: {
                                updateAtemLive(ssboxDelegate, true)
                            }
                            onAtemSizeChanged: {
                                updateAtemLive(ssboxDelegate, true)
                            }
                            onCropChanged: {
                                updateAtemLive(ssboxDelegate, true);
                            }
                            onEnabledChanged: {
                                updateAtemLive(ssboxDelegate, true);
                            }
                            onInputSourceChanged: {
                                updateAtemLive(ssboxDelegate, true);
                            }
                            onAtemPositionChanged: {
                                updateAtemLive(ssboxDelegate, true)
                            }
                        }
                    }
                }
            }
            ColumnLayout {
                Layout.maximumWidth: 340
                Layout.minimumWidth: 120
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                enabled: selectedBox!=null

                ComboBox {
                    id: boxId
                    Layout.fillWidth: true
                    model: ssModel
                    displayText: "Box: " + currentText
                    textRole: "box"
                    currentIndex: ssBoxParent.currentIndex
                    onCurrentIndexChanged: ssBoxParent.currentIndex=currentIndex
                }

                CheckBox {
                    id: ssCheck
                    property SuperSourceBox ssbox;
                    enabled: selectedBox!=null
                    text: "Visible"
                    checked: selectedBox && selectedBox.enabled
                    onCheckedChanged: selectedBox.enabled=checked
                }

                ComboBox {
                    id: inputSourceCombo
                    Layout.fillWidth: true
                    model: atem.camInputs
                    onActivated: {
                        selectedBox.inputSource=currentValue;
                    }
                }

                SpinBox {
                    id: boxX
                    Layout.fillWidth: true
                    from: -4800
                    to : 4800
                    stepSize: 10
                    wheelEnabled: true
                    editable: true
                    value: selectedBox.boxCenterX*4800
                    onValueModified: {
                        selectedBox.setCenterX(value/4800)
                    }
                }
                SpinBox {
                    id: boxY
                    Layout.fillWidth: true
                    from: -4800
                    to: 4800
                    stepSize: 10
                    wheelEnabled: true
                    editable: true
                    value: selectedBox.boxCenterY*4800
                    onValueModified: {
                        selectedBox.setCenterY(value/4800)
                    }
                }
                GridLayout {
                    rows: 3
                    columns: 3
                    Layout.fillWidth: true
                    Button {
                        text: "LU"
                        onClicked: selectedBox.setCenter(-0.25, -0.25)
                        Layout.fillWidth: true
                    }
                    Button {
                        text: "CU"
                        onClicked: selectedBox.setCenter(0, -0.25)
                        Layout.fillWidth: true
                    }
                    Button {
                        text: "RU"
                        onClicked: selectedBox.setCenter(0.25, -0.25)
                        Layout.fillWidth: true
                    }
                    Button {
                        text: "L"
                        onClicked: selectedBox.setCenterX(-0.25)
                        Layout.fillWidth: true
                    }
                    Button {
                        text: "C"
                        onClicked: selectedBox.setCenter(0,0)
                        Layout.fillWidth: true
                    }
                    Button {
                        text: "R"
                        onClicked: selectedBox.setCenterX(0.25)
                        Layout.fillWidth: true
                    }
                    Button {
                        text: "LD"
                        onClicked: selectedBox.setCenter(-0.25, 0.25)
                        Layout.fillWidth: true
                    }
                    Button {
                        text: "CD"
                        onClicked: selectedBox.setCenter(0, 0.25)
                        Layout.fillWidth: true
                    }
                    Button {
                        text: "RD"
                        onClicked: selectedBox.setCenter(0.25, 0.25)
                        Layout.fillWidth: true
                    }
                }
                RowLayout {
                    Button {
                        text: "F"
                        onClicked: {
                            selectedBox.setSize(1)
                            selectedBox.setCenterX(0)
                            selectedBox.setCenterY(0)
                        }
                    }
                    Button {
                        text: "I"
                        onClicked: selectedBox.snapInside()
                    }
                    Button {
                        text: "R"
                        onClicked: selectedBox.reset()
                    }
                    Button {
                        text: "TL"
                        onClicked: ssAnimation.start()
                    }
                }

                SpinBox {
                    id: boxSize
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    wheelEnabled: true
                    value: selectedBox.boxSize*100
                    onValueModified: {
                        selectedBox.setSize(value/100)
                    }
                }
                RowLayout {
                    Button {
                        text: "25%"
                        Layout.fillWidth: false
                        onClicked: selectedBox.boxSize=0.25
                    }
                    Button {
                        text: "50%"
                        Layout.fillWidth: false
                        onClicked: selectedBox.boxSize=0.50
                    }
                    Button {
                        text: "75%"
                        Layout.fillWidth: false
                        onClicked: selectedBox.boxSize=0.75
                    }
                    Button {
                        text: "100%"
                        Layout.fillWidth: false
                        onClicked: selectedBox.boxSize=1.00
                    }
                }
                RowLayout {
                    Button {
                        text: "Debug"
                        enabled: true
                        onClicked: dumpBoxState();
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    HorizontalHeaderView {
                        id: horizontalHeader
                        Layout.fillWidth: true
                        syncView: timelineList
                        clip: true
                        model: [ "Frame", "X", "Y", "Size" ]
                    }
                    TableView {
                        id: timelineList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        boundsBehavior: Flickable.StopAtBounds
                        boundsMovement: Flickable.StopAtBounds
                        clip: true
                        columnSpacing: 2
                        rowSpacing: 2
                        alternatingRows: true
                        model: timelineModel
                        animate: false
                        selectionModel: ItemSelectionModel { }
                        selectionBehavior: TableView.SelectRows
                        ScrollBar.vertical: ScrollBar { }
                        delegate: Rectangle {
                            id: cellDelegate
                            required property bool selected
                            required property bool current
                            implicitHeight: l.contentHeight
                            implicitWidth: Math.max(l.contentWidth, 56)
                            color: row === timelineList.currentRow
                                        ? palette.highlight
                                        : (timelineList.alternatingRows && row % 2 !== 0
                                        ? palette.alternateBase
                                        : palette.base)
                            Label {
                                id: l
                                anchors.fill: parent
                                anchors.leftMargin: 2
                                anchors.rightMargin: 2
                                horizontalAlignment: Text.AlignRight
                                leftInset: 2
                                rightInset: 2
                                text: model.display
                                font.bold: cellDelegate.current
                            }
                        }
                        onCurrentRowChanged: {
                            if (currentRow==-1)
                                return;
                            let v=model.getRow(currentRow)
                            selectedBox.setSize(v.s)
                            selectedBox.setCenter(v.x, v.y)
                        }
                    }
                }
            }

        }
        RowLayout {
            Layout.fillWidth: true
            CheckBox {
                id: ssLiveCheck
                text: "Live"
                checked: true
            }
            Button {
                text: "Commit"
                enabled: selectedBox && !ssLiveCheck.checked
                onClicked: {
                    ss.setSuperSource(selectedBox.boxId-1,
                                      selectedBox.enabled,
                                      selectedBox.inputSource,
                                      selectedBox.atemPosition,
                                      selectedBox.atemSize,
                                      selectedBox.crop,
                                      selectedBox.atemCrop)
                }
            }

            CheckBox {
                id: ssHideDisabled
                text: "Hide disabled"
            }
            CheckBox {
                id: ssCropCheck
                enabled: selectedBox!=null
                text: "Crop"
                checked: selectedBox && selectedBox.crop
                onCheckedChanged: selectedBox.crop=checked
            }
        }
        GridLayout {
            Layout.fillWidth: true
            enabled: selectedBox && selectedBox.crop
            rows: 1
            columns: 4
            SpinBox {
                from: 0
                to: 2048
                stepSize: 1
                wheelEnabled: true
                editable: true
                inputMethodHints: Qt.ImhDigitsOnly
                value: selectedBox.cropTop
                onValueChanged: selectedBox.cropTop=value
            }
            SpinBox {
                from: 0
                to: 2048
                stepSize: 1
                wheelEnabled: true
                editable: true
                inputMethodHints: Qt.ImhDigitsOnly
                value: selectedBox.cropBottom
                onValueChanged: selectedBox.cropBottom=value
            }
            SpinBox {
                from: 0
                to: 2048
                stepSize: 1
                wheelEnabled: true
                editable: true
                inputMethodHints: Qt.ImhDigitsOnly
                value: selectedBox.cropLeft
                onValueChanged: selectedBox.cropLeft=value
            }
            SpinBox {
                from: 0
                to: 2048
                stepSize: 1
                wheelEnabled: true
                editable: true
                inputMethodHints: Qt.ImhDigitsOnly
                value: selectedBox.cropRight
                onValueChanged: selectedBox.cropRight=value
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Button {
                text: "Set A"
                onClicked: {
                    savePositions(0);
                }
            }
            Button {
                text: "Get A"
                onClicked: {
                    loadPositions(0);
                }
            }
            Button {
                text: "Set B"
                onClicked: {
                    savePositions(1);
                }
            }
            Button {
                text: "Get B"
                onClicked: {
                    loadPositions(1);
                }
            }
            Button {
                text: "Run A"
                onClicked: {
                    animateSuperSource(0);
                }
            }
            Button {
                text: "Run B"
                onClicked: {
                    animateSuperSource(1);
                }
            }
            ComboBox {
                id: easingType
                textRole: "text"
                valueRole: "easingType"
                enabled: selectedBox
                model: ListModelEasing {

                }
                onActivated: {
                    selectedBox.animateEasing=currentValue
                }
                Component.onCompleted: {
                    currentIndex = indexOfValue(Easing.InCubic)
                }
            }

            SpinBox {
                id: easingDuration
                Layout.fillWidth: true
                enabled: selectedBox
                editable: false
                from: 1
                to: 10
                value: 1
                onValueModified: {
                    selectedBox.animateDuration=value*1000;
                }
                //background.implicitWidth: 100
            }
        }
    }
}
