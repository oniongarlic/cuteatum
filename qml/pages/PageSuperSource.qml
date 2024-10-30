import QtCore
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

    readonly property double ratio: 16/9
    property int boxDragMargin: 16

    property AtemSuperSource ss;

    property var boxes: [];
    property var proxies: [];

    property var savedPosition: [];
    property var savedCrop: [];

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

    Settings {
        id: ssSettings
        category: "SuperSource"
    }

    header: ToolBar {
        RowLayout {
            ToolButton {
                text: "Close"
                onClicked: rootStack.pop();
            }
            ToolSeparator {}
            ToolButton {
                text: "Save"
                enabled: false
            }
            ToolButton {
                text: "Load";
                enabled: false
            }
            ToolSeparator {}
            ToolButton {
                id: snapToGridTool
                text: "Snap"
                checkable: true
                checked: false
            }
        }
    }

    function dumpBoxState(b) {
        console.debug(b.enabled)
        console.debug(b.source)
        console.debug(b.position)
        console.debug(b.size)
        console.debug(b.cropEnabled)
        console.debug(b.crop)
        console.debug(b.borderEnabled)
        console.debug(b.borderColor)
    }

    property bool animating: false

    function syncBoxStates() {
        if (!atem.connected)
            return;
        console.debug("Syncing all boxes")
        for (var i=0;i<4;i++) {
            boxes[i]=ss.getSuperSourceBox(i);
            dumpBoxState(boxes[i])
            var sb=ssBoxParent.itemAt(i);
            syncBoxState(boxes[i], i, sb)
        }
    }

    function syncBoxState(b, i, sb) {
        console.debug("Syncing box", i, b)
        ssModel.setProperty(i, "ena", b.enabled)
        ssModel.setProperty(i, "src", b.source)
        ssModel.setProperty(i, "c", b.cropEnabled)

        ssModel.setProperty(i, "ds", b.size/1000);

        ssModel.setProperty(i, "borderEnabled", b.borderEnabled)
        ssModel.setProperty(i, "borderColor", ""+b.borderColor)

        sb.setAtemPosition(b.position)
        sb.setSize(b.size/1000)
        sb.setAtemCrop(b.crop)
    }

    Connections {
        target: ss
        function onSuperSourceChanged(boxid) {
            console.debug('SSChanged: '+boxid)
            var b=ss.getSuperSourceBox(boxid);
            var sb=ssBoxParent.itemAt(boxid);
            syncBoxState(b, boxid, sb)
        }
        function onSuperSourceBorderPropertiesChanged(boxid) {
            var b=ss.getSuperSourceBox(boxid);
            console.debug('SSBorder: ', boxid)
            console.debug(b, b.borderEnabled, b.borderColor)
            ssModel.setProperty(boxid, "borderEnabled", b.borderEnabled)
            ssModel.setProperty(boxid, "borderColor", ""+b.borderColor)
        }
    }

    Connections {
        target: atem
        onConnected: {
            console.debug("SuperSource got connected", supersources)
            syncBoxStates();
        }
    }

    function savePositions(bid) {
        savedPosition[bid]=[];
        savedCrop[bid]=[];
        for (var i=0;i<4;i++) {
            let item=ssBoxParent.itemAt(i)
            savedPosition[bid][i]=item.getPositionVector3d();
            savedCrop[bid][i]=item.getCropVector4d()
        }
        let s=JSON.stringify(savedPosition);
        let c=JSON.stringify(savedCrop);

        ssSettings.setValue("ss_pos_"+bid, s)
        ssSettings.setValue("ss_crop_"+bid, c)
    }

    function preparePositions(bid) {
        for (var i=0;i<4;i++) {
            let item=ssBoxParent.itemAt(i)

            let v=savedPosition[bid][i];
            let c=savedCrop[bid][i];

            item.animateFrom=item.getPositionVector3d();
            item.animateTo=v;

            item.animateCropFrom=item.getCropVector4d();
            item.animateCropTo=c;
        }
    }

    function loadPositions(bid) {
        let s=ssSettings.value("ss_"+bid, false)
        for (var i=0;i<4;i++) {
            let item=ssBoxParent.itemAt(i)

            let v=savedPosition[bid][i];
            let c=savedCrop[bid][i];

            item.setPositionVector3d(v);
            item.setCropVector4d(c);
        }
    }

    function animateSuperSource(bid) {
        preparePositions(bid)
        for (var i=0;i<4;i++) {
            let item=ssBoxParent.itemAt(i)
            item.animate();
        }
    }

    function syncBoxFromProxy(boxid, proxy) {
        var sb=ssBoxParent.itemAt(boxid);
        sb.setCenter(proxy.x, proxy.y)
        sb.setSize(proxy.s)
    }

    ListModelSuperSourceBoxes {
        id: ssModel
    }

    TimelineBoxProxy {
        id: sproxy1
        box: 0
        onUpdated: syncBoxFromProxy(box, sproxy1)
    }

    TimelineBoxProxy {
        id: sproxy2
        box: 1
        onUpdated: syncBoxFromProxy(box, sproxy2)
    }

    TimelineBoxProxy {
        id: sproxy3
        box: 2
        onUpdated: syncBoxFromProxy(box, sproxy3)
    }

    TimelineBoxProxy {
        id: sproxy4
        box: 3
        onUpdated: syncBoxFromProxy(box, sproxy4)
    }

    TableModel {
        id: timelineModel
        TableModelColumn { display: "f" } // Frame
        TableModelColumn { display: "x" } // XPos
        TableModelColumn { display: "y" } // YPos
        TableModelColumn { display: "s" } // Size 0-1
        TableModelColumn { display: "src" } // Source
        TableModelColumn { display: "c" } // Crop
        TableModelColumn { display: "cl" }
        TableModelColumn { display: "cr" }
        TableModelColumn { display: "ct" }
        TableModelColumn { display: "cb" }

        function syncFromProxy(p) {
            timelineModel.clear()
            for (let i=0;i<p.keyFrames.length;i++) {
                console.debug(p.keyFrames[i])
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
        endFrame: 0
        enabled: tlEnabled.checked || ssAnimation.running

        property var boxes: [];

        onCurrentFrameChanged: {
            if (!tlEnabled.checked) {
                console.debug("CF-animate: "+currentFrame)
                proxies[0].append(currentFrame)
                proxies[1].append(currentFrame)
                proxies[2].append(currentFrame)
                proxies[3].append(currentFrame)
            } else {
                console.debug("CF-interactive: "+currentFrame)
                proxies[0].setFrame(currentFrame)
                proxies[1].setFrame(currentFrame)
                proxies[2].setFrame(currentFrame)
                proxies[3].setFrame(currentFrame)
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
            let e=easingType.currentValue
            kg.keyframes.push(kf.createObject(ssTimeLine, { frame: f, value: v, easing: e }))
        }

        function clearKeyframeGroupsForBox(ki) {
            let k=boxes[ki];
            for (let i=0;i<3;i++) {
                console.debug(i,k[i])
                clearKeyframesInGroup(k[i]);
            }
        }

        function clearKeyframesInGroup(kg) {
            kg.keyframes=[]
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

            clearKeyframeGroupsForBox(0)
            clearKeyframeGroupsForBox(1)
            clearKeyframeGroupsForBox(2)
            clearKeyframeGroupsForBox(3)
        }

        function addKeyframe(box, frame) {
            let b=ssBoxParent.itemAt(box)
            ssTimeLine.endFrame=Math.max(frame, ssTimeLine.endFrame)
            addBoxKeyframe(box, frame, b.setX, b.setY, b.boxSize, b.crop, b.cropLeft, b.cropRight, b.cropTop, b.cropBottom)
        }

        animations: [
            TimelineAnimation {
                id: ssAnimation
                duration: 1000
                easing.type: Easing.InOutExpo
                from: ssTimeLine.startFrame
                to: ssTimeLine.endFrame
                onFinished: {
                    console.debug("Animation done")
                    timelineModel.syncFromProxy(proxies[selectedBox.boxId-1])
                }
                onStarted: {
                    console.debug("Animation starts...")
                    ssTimeLine.clearKeyframes();
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

    function updateAtemLiveBorder(box, force) {
        console.debug("updateLiveBorder", box.boxId)
        if (ssLiveCheck.checked || force) {
            ss.setBorder(box.boxId-1, box.borderEnabled)
            ss.setBorderColor(box.boxId-1, box.borderColor)
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
                color: "grey"
                border.color: "black"
                border.width: 1
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: c.width/1.5
                Layout.preferredHeight: Layout.preferredWidth/ssDrawer.ratio
                clip: true
                Rectangle {
                    id: superSourceContainer
                    width: parent.width-4
                    height: width/ratio
                    anchors.centerIn: parent
                    color: "grey"
                    border.color: ssLiveCheck.checked ? "red" : "green"
                    border.width: 4
                    clip: true

                    MouseArea {
                        anchors.fill: parent
                        onWheel: {
                            if (!selectedBox)
                                return;
                            selectedBox.externalWheelEventHandler(wheel)
                        }
                    }

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
                            required property int index;
                            required property int box;
                            required property int dx;
                            required property int dy;
                            required property int ds;
                            required property bool ena;
                            required property int src;
                            required property bool c;
                            required property int cLeft;
                            required property int cRight;
                            required property int cTop;
                            required property int cBottom;
                            //required property bool borderEnabled;
                            //required property color borderColor;
                            required property var model;

                            id: ssboxDelegate
                            boxId: box
                            defaultX: dx
                            defaultY: dy
                            defaultSize: ds
                            enabled: ena
                            inputSource: src

                            crop: c
                            cropLeft: cLeft
                            cropRight: cRight
                            cropTop: cTop
                            cropBottom: cBottom

                            borderEnabled: model.borderEnabled
                            borderColor: model.borderColor

                            visible: enabled || !ssHideDisabled.checked
                            selected: ssBoxParent.currentIndex==boxId-1
                            snapToGrid: snapToGridTool.checked

                            onClicked: {
                                ssBoxParent.currentIndex=index
                            }
                            onFocusChanged: {
                                if (focus)
                                    ssBoxParent.currentIndex=index
                            }
                            onBoxSizeChanged: {
                                model.cs=boxSize
                            }
                            onBoxCenterChanged: {
                                model.cx=boxCenter.x
                                model.cy=boxCenter.y
                            }
                            onAtemCropChanged: {
                                updateAtemLive(ssboxDelegate, true);
                            }
                            onAtemSizeChanged: {
                                updateAtemLive(ssboxDelegate, true);
                            }
                            onAtemPositionChanged: {
                                updateAtemLive(ssboxDelegate, true);
                            }
                            onCropChanged: {
                                updateAtemLive(ssboxDelegate, true);
                            }
                            onBorderColorChanged: {
                                console.debug("BorderColorChanged", borderColor)
                            }

                            onBorderEnabledChanged: {
                                console.debug("")
                                updateAtemLiveBorder(ssboxDelegate, true);
                            }
                            onEnabledChanged: {
                                updateAtemLive(ssboxDelegate, true);
                            }
                            onInputSourceChanged: {
                                updateAtemLive(ssboxDelegate, true);
                            }
                            onAnimationTick: {
                                console.debug("tick", boxId)
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
                //enabled: selectedBox!=null

                ButtonGroup {
                    id: boxGroup
                    property int activeBox: ssBoxParent.currentIndex
                    onActiveBoxChanged: {
                        for (var i = 0; i < buttons.length; ++i) {
                            if (buttons[i].boxIndex == activeBox)
                                buttons[i].checked=true;
                        }
                    }
                    onClicked: {
                        ssBoxParent.currentIndex=button.boxIndex
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Repeater {
                        model: ssModel
                        ColumnLayout {
                            required property int index;
                            required property bool ena;
                            required property bool c
                            required property bool borderEnabled
                            required property color borderColor
                            required property var model;
                            Layout.fillWidth: true
                            Button {
                                property int boxIndex: index
                                Layout.fillWidth: true
                                text: "Box "+(index+1)
                                checkable: true
                                ButtonGroup.group: boxGroup
                            }
                            CheckBox {
                                id: ssChecks
                                text: "Visible"
                                checked: ena
                                onCheckedChanged: ssModel.setProperty(index, "ena", checked)
                            }
                            CheckBox {
                                id: ssCrops
                                checked: c
                                text: "Crop"
                                onCheckedChanged: ssModel.setProperty(index, "c", checked)
                            }
                            RowLayout {
                                CheckBox {
                                    id: ssBorder
                                    checked: borderEnabled
                                    // visible: ss.bordersSupported
                                    text: "Border"
                                    onCheckedChanged: ssModel.setProperty(index, "border", checked)
                                }
                                Rectangle {
                                    width: 24
                                    height: 24
                                    color: borderColor
                                    border.width: 1
                                    border.color: "#101010"
                                }
                            }
                        }
                    }
                }

                ComboBox {
                    id: inputSourceCombo
                    Layout.fillWidth: true
                    model: atem.superSourceBoxInputModel
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
                        value: selectedBox ? selectedBox.boxCenterX*4800 : 0
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
                        value: selectedBox ? selectedBox.boxCenterY*4800 : 0
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

                RowLayout {
                    SpinBox {
                        id: boxSize
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        wheelEnabled: true
                        value: selectedBox ? selectedBox.boxSize*100 : 0
                        onValueModified: {
                            selectedBox.setSize(value/100)
                        }
                    }
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
                    Layout.fillWidth: true
                    enabled: selectedBox && selectedBox.crop
                    SpinBox {
                        from: 0
                        to: 1800
                        stepSize: 1
                        wheelEnabled: true
                        editable: true
                        inputMethodHints: Qt.ImhDigitsOnly
                        value: selectedBox ? selectedBox.cropTop : 0
                        onValueModified: selectedBox.cropTop=value
                    }
                    SpinBox {
                        from: 0
                        to: 1800
                        stepSize: 1
                        wheelEnabled: true
                        editable: true
                        inputMethodHints: Qt.ImhDigitsOnly
                        value: selectedBox ? selectedBox.cropBottom : 0
                        onValueModified: selectedBox.cropBottom=value
                    }
                    Button {
                        text: "25%"
                        onClicked: {
                            selectedBox.cropBottom=225
                            selectedBox.cropTop=225
                        }
                    }
                    Button {
                        text: "50%"
                        onClicked: {
                            selectedBox.cropBottom=450
                            selectedBox.cropTop=450
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    enabled: selectedBox && selectedBox.crop
                    SpinBox {
                        from: 0
                        to: 3200
                        stepSize: 1
                        wheelEnabled: true
                        editable: true
                        inputMethodHints: Qt.ImhDigitsOnly
                        value: selectedBox ? selectedBox.cropLeft : 0
                        onValueModified: selectedBox.cropLeft=value
                    }
                    SpinBox {
                        from: 0
                        to: 3200
                        stepSize: 1
                        wheelEnabled: true
                        editable: true
                        inputMethodHints: Qt.ImhDigitsOnly
                        value: selectedBox ? selectedBox.cropRight : 0
                        onValueModified: selectedBox.cropRight=value
                    }
                    Button {
                        text: "25%"
                        onClicked: {
                            selectedBox.cropLeft=400
                            selectedBox.cropRight=400
                        }
                    }
                    Button {
                        text: "50%"
                        onClicked: {
                            selectedBox.cropLeft=800
                            selectedBox.cropRight=800
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    ComboBox {
                        id: easingType
                        textRole: "text"
                        valueRole: "easingType"
                        enabled: selectedBox!=null
                        model: ListModelEasing {

                        }
                        onActivated: {
                            selectedBox.animateEasing=currentValue
                        }
                        Component.onCompleted: {
                            currentIndex=indexOfValue(Easing.InCubic)
                        }
                    }

                    SpinBox {
                        id: easingDuration
                        Layout.fillWidth: true
                        enabled: selectedBox!=null
                        editable: false
                        from: 1
                        to: 10
                        value: 1
                        wheelEnabled: true
                        onValueModified: {
                            selectedBox.animateDuration=value*1000;
                        }
                        //background.implicitWidth: 100
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Button {
                        text: "1 KF"
                        ToolTip.text: "Add keyframe for selected box"
                        ToolTip.visible: hovered
                        ToolTip.delay: 1000
                        onClicked: {
                            ssTimeLine.addKeyframe(ssBoxParent.currentIndex, ssFrame.value)
                        }
                    }
                    Button {
                        text: "A KF"
                        ToolTip.text: "Add keyframe for all boxes"
                        ToolTip.visible: hovered
                        ToolTip.delay: 1000
                        onClicked: {
                            ssTimeLine.addKeyframe(0, ssFrame.value)
                            ssTimeLine.addKeyframe(1, ssFrame.value)
                            ssTimeLine.addKeyframe(2, ssFrame.value)
                            ssTimeLine.addKeyframe(3, ssFrame.value)
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
                        Button {
                            text: "Play"
                            enabled: tlKeyFrame.enabled && ssTimeLine.endFrame>0 && !playbackTicker.running
                            visible: tlKeyFrame.enabled
                            icon.name: "media-playback-play"
                            onClicked: {
                                ssTimeLine.currentFrame=tlReverse.checked ? ssTimeLine.endFrame : 0
                                playbackTicker.start()
                            }
                            Timer {
                                id: playbackTicker
                                repeat: true
                                interval: 100
                                onTriggered: {
                                    console.debug("tick", ssTimeLine.currentFrame)

                                    if (!tlReverse.checked) {
                                        ssTimeLine.currentFrame++
                                        if (ssTimeLine.endFrame==ssTimeLine.currentFrame)
                                            stop();
                                    } else {
                                        ssTimeLine.currentFrame--
                                        if (ssTimeLine.currentFrame==0)
                                            stop();                                    }

                                    // Add 1 frame pause if macro recording is on
                                    if (atem.connected && atem.macroRecording) {
                                        console.debug("macroPause")
                                        atem.addMacroPause(1)
                                    }

                                }
                            }
                        }
                        Button {
                            text: "Stop"
                            visible: playbackTicker.running
                            onClicked: playbackTicker.stop()
                        }
                        CheckBox {
                            id: tlReverse
                            text: "Rev"
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
                            ToolTip {
                                parent: tlKeyFrame.handle
                                visible: tlKeyFrame.pressed
                                text: tlKeyFrame.value.toFixed(1)
                            }
                        }
                        Label {
                            text: tlEnabled.checked ? tlKeyFrame.value : tlFrame.value
                        }
                    }

                    function setFromRow(r) {
                        let v=timelineList.model.getRow(r)
                        selectedBox.setSize(v.s)
                        selectedBox.setCenter(v.x, v.y)
                    }

                    Rectangle {
                        color: "#e5f7c9"
                        border.width: 1
                        border.color: "black"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        HorizontalHeaderView {
                            id: horizontalHeader
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 1
                            syncView: timelineList
                            clip: true
                            resizableColumns: true
                            model: [ "Frame", "X", "Y", "Size", "Crop", "CL", "CR", "CT", "CB" ]
                        }

                        TableView {
                            id: timelineList
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: horizontalHeader.bottom
                            anchors.bottom: parent.bottom
                            anchors.margins: 1
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

            Button {
                text: "Debug"
                onClicked: {
                    console.debug(ssModel.toJSON());
                    if (selectedBox)
                        dumpBoxState(selectedBox);
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
        }
    }
}
