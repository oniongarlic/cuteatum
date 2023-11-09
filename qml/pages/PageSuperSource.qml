import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Timeline
import Qt.labs.qmlmodels

import "../models"
import "../components"

import org.bm 1.0

Page {
    id: ssDrawer
    title: "SuperSource editor"
    // enabled: atem.connected

    property double ratio: 16/9
    property int boxDragMargin: 16

    property AtemSuperSource ss;

    property var boxes: [];
    property var proxies: [];

    property var savedPosition: [];

    onSavedPositionChanged: console.debug(savedPosition)

    StackView.onActivating: syncBoxStates();

    objectName: "supersource"

    Keys.onReleased: (event) => {
        if (event.key === Qt.Key_Escape) {
            event.accepted = true;
            rootStack.pop()
        }
    }

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
        function onSuperSourceChanged(boxid) {
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

    TimelineBoxProxy {
        id: sproxy1
        box: 0
    }

    TimelineBoxProxy {
        id: sproxy2
        box: 1
    }

    TimelineBoxProxy {
        id: sproxy3
        box: 2
    }

    TimelineBoxProxy {
        id: sproxy4
        box: 3
    }

    TableModel {
        id: timelineModel
        TableModelColumn { display: "f" }
        TableModelColumn { display: "x" }
        TableModelColumn { display: "y" }
        TableModelColumn { display: "s" }

        function syncFromProxy(p) {
            timelineModel.clear()
            console.debug(p)
            for (let i=0;i<p.keyFrames.length;i++) {
                appendRow(p.keyFrames[i])
            }
        }
    }

    Component {
        id: kf
        Keyframe {}
    }

    Component {
        id: kfg
        KeyframeGroup {
            keyframes: []
        }
    }

    Timeline {
        id: ssTimeLine
        startFrame: 0
        endFrame: 60
        enabled: tlEnabled.checked || ssAnimation.running

        property var boxes: [];

        onCurrentFrameChanged: {
            if (!tlEnabled.checked) {
                proxies[selectedBox.boxId-1].append(currentFrame)
            }
        }

        Component.onCompleted: {
            initBoxes();
        }

        function initBoxes() {
            proxies=[]
            proxies[0]=sproxy1;
            proxies[1]=sproxy2;
            proxies[2]=sproxy3;
            proxies[3]=sproxy4;
            boxes=[]
            for (let i=0;i<4;i++) {
                let k=initBox(proxies[i]);
                boxes.push(k)
            }
        }

        function initBox(proxy) {
            return addBoxGroup(createBoxGroup(proxy))
        }

        function addBoxKeyframe(ki,f,x,y,s) {
            let k=boxes[ki]
            addKeyframeToGroup(k[0], f, x)
            addKeyframeToGroup(k[1], f, y)
            addKeyframeToGroup(k[2], f, s)

            dumpKeyframes(k[2]);
        }

        function dumpKeyframes(k) {
            for (let i=0;i<k.keyframes.length;i++) {
                console.debug("***KEYFRAME: "+k.keyframes[i].frame+" : "+k.keyframes[i].value)
            }
        }

        function addKeyframeToGroup(kg, f, v) {
            console.debug("Frame: "+f+" == "+v)
            kg.keyframes.push(kf.createObject(ssTimeLine, { frame: f, value: v }))
        }

        /* Per SuperSource box keyframe group */
        function createBoxGroup(proxy) {
            let tx=kfg.createObject(ssTimeLine, { target: proxy, property: "x" });
            let ty=kfg.createObject(ssTimeLine, { target: proxy, property: "y" });
            let ts=kfg.createObject(ssTimeLine, { target: proxy, property: "s" });
            return [tx, ty, ts];
        }

        function addBoxGroup(kg) {
            keyframeGroups.push(kg[0])
            keyframeGroups.push(kg[1])
            keyframeGroups.push(kg[2])

            return kg;
        }

        function clearKeyframes() {
            sproxy1.clear()
            sproxy2.clear()
            sproxy3.clear()
            sproxy4.clear()
            timelineModel.clear()
        }

        function addKeyframe(frame) {
            addBoxKeyframe(ssBoxParent.currentIndex, frame, selectedBox.setX, selectedBox.setY, selectedBox.boxSize)
        }

        animations: [
            TimelineAnimation {
                id: ssAnimation
                duration: 2000
                easing.type: Easing.InOutExpo
                from: ssTimeLine.startFrame
                to: ssTimeLine.endFrame
                onFinished: {
                    console.debug("Animated!")
                    timelineModel.syncFromProxy(proxies[selectedBox.boxId-1])
                }
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

        timelineModel.syncFromProxy(proxies[selectedBox.boxId-1])
    }

    ColumnLayout {
        id: c
        anchors.fill: parent
        anchors.margins: 4

        focus: true
        Keys.enabled: true
        Keys.onPressed: (event) => {
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

                                case Qt.Key_F5:
                                event.accepted=true;
                                break;
                                case Qt.Key_F6:
                                event.accepted=true;
                                break;
                                case Qt.Key_F7:
                                event.accepted=true;
                                break;
                                case Qt.Key_F8:
                                event.accepted=true;
                                break;

                                case Qt.Key_F9:
                                animateSuperSource(0)
                                event.accepted=true;
                                break;
                                case Qt.Key_F10:
                                animateSuperSource(1)
                                event.accepted=true;
                                break;
                                case Qt.Key_F11:
                                event.accepted=true;
                                break;
                                case Qt.Key_F12:
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
                //Layout.maximumWidth: 340
                Layout.minimumWidth: 120
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                enabled: selectedBox!=null

                RowLayout {

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

                }

                ComboBox {
                    id: inputSourceCombo
                    Layout.fillWidth: true
                    model: atem.camInputs
                    onActivated: {
                        selectedBox.inputSource=currentValue;
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
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
                }
                RowLayout {
                    Layout.fillWidth: true
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
                RowLayout {
                    Layout.fillWidth: true
                    Button {
                        text: "Add KF"
                        onClicked: {
                            ssTimeLine.addKeyframe(ssFrame.value)
                        }
                    }
                    Button {
                        text: "Clear"
                        onClicked: ssTimeLine.clearKeyframes()
                    }
                    Button {
                        text: "Play"
                        enabled: !ssAnimation.running
                        onClicked: ssAnimation.start()
                    }
                    SpinBox {
                        id: ssFrame
                        Layout.fillWidth: true
                        from: 0
                        to: 120
                        wheelEnabled: true
                        stepSize: 1
                    }
                }

                ListView {
                    id: tlKeyframes
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    delegate: ItemDelegate {
                        text: modelData
                    }

                    onCountChanged: console.debug("ListView keyframes: "+count)
                }

                ColumnLayout {
                    id: tlc
                    Layout.fillWidth: true
                    RowLayout {
                        CheckBox {
                            id: tlEnabled
                        }
                        Slider {
                            id: tlFrame
                            Layout.fillWidth: true
                            from: 0
                            to: timelineList.rows
                            enabled: !tlEnabled.checked && timelineList.rows>0
                            visible: !tlEnabled.checked
                            wheelEnabled: true
                            stepSize: 1
                            onMoved: tlc.setFromRow(value)
                        }
                        Slider {
                            id: tlKeyFrame
                            Layout.fillWidth: true
                            from: 0
                            to: ssTimeLine.endFrame
                            enabled: tlEnabled.checked
                            visible: tlEnabled.checked
                            wheelEnabled: true
                            stepSize: 1
                            onMoved: ssTimeLine.currentFrame=value
                        }
                        Label {
                            text: tlEnabled.checked ? tlKeyFrame.value : tlFrame.value
                        }
                    }

                    HorizontalHeaderView {
                        id: horizontalHeader
                        Layout.fillWidth: true
                        syncView: timelineList
                        clip: true
                        model: [ "Frame", "X", "Y", "Size" ]
                    }

                    function setFromRow(r) {
                        let v=timelineList.model.getRow(r)
                        selectedBox.setSize(v.s)
                        selectedBox.setCenter(v.x, v.y)
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
                            tlc.setFromRow(currentRow)
                            tlFrame.value=currentRow
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
            rows: 2
            columns: 2
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
    }
}
