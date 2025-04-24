import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Timeline
import Qt.labs.qmlmodels

import "../models"
import "../components"

import org.bm 1.0
import org.tal.model 1.0

Page {
    id: ssDrawer
    title: "SuperSource editor"
    // enabled: atem.connected

    readonly property double ratio: 16/9
    property int boxDragMargin: 16

    required property AtemSuperSource ss;
    required property ListModel superSourceInputModel;

    property var proxies: [];

    property var savedPosition: [];
    property var savedCrop: [];

    onSavedPositionChanged: console.debug(savedPosition)

    objectName: "supersource"

    Keys.onReleased: (event) => {
                         if (event.key === Qt.Key_Escape) {
                             event.accepted = true;
                             rootStack.pop()
                         }
                     }

    property bool animating: false

    // Page global current box index
    property int currentBoxIndex: -1;

    readonly property bool isLive: ssLiveCheck.checked

    onCurrentBoxIndexChanged: {
        selectedBox=currentBoxIndex>-1 ? ssBoxParent.itemAt(currentBoxIndex) : null

        var o=ssModel.get(currentBoxIndex);
        inputSourceCombo.currentIndex=inputSourceCombo.indexOfValue(o.src)

        var d;
        d=syncProxyRepeater.itemAt(currentBoxIndex);
        easingType.currentIndex=easingType.indexOfValue(d.animateEasing)
        easingDuration.value=d.animateDuration/1000;

        timelineModel.syncFromProxy(proxies[currentBoxIndex])
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
                text: "Manage";
                onClicked: savedPositionsDrawer.open()
            }
            ToolButton {
                text: "Save"
                onClicked: savedPositionsModel.savePosition();
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

    SuperSourceBoxesModel {
        id: savedPositionsModel

        function savePosition() {
            var p=getPositions();
            var sb={ "name": "Saved testing", "boxes": p }
            appendFromMap(sb);
        }

        function loadPosition(idx) {
            let boxes=getItem(idx);
            let sboxes=[]
            for (let i=0;i<4;i++) {
                let sb=boxes.getBox(i)
                sboxes[i]=sb;
                console.debug(i, sb, sb.name, sb.source, sb.enabled, sb.position, sb.cropping)
            }
            return sboxes;
        }

        function loadPositionBox(idx, box) {
            var boxes=getItem(idx);
            return boxes.getBox(box)
        }
    }

    Drawer {
        id: savedPositionsDrawer
        interactive: visible
        width: parent.width/2
        height: parent.height

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8

            Label {
                text: savedPositionsModel.count
            }

            RowLayout {
                Layout.fillWidth: true
                Button {
                    text: "Export..."
                    onClicked: {
                        console.debug(savedPositionsModel.toJson());
                    }
                }
                Button {
                    text: "Import..."
                    onClicked: {
                        // xxx
                    }
                }
                Button {
                    text: "Clear"
                    onClicked: savedPositionsModel.clear();
                }
            }

            ListView {
                Layout.fillHeight: true
                Layout.fillWidth: true
                model: savedPositionsModel
                delegate: ItemDelegate {
                    id: idsbox
                    required property int index
                    required property string name
                    width: ListView.view.width
                    height: r.height+4
                    RowLayout {
                        id: r
                        width: parent.width
                        spacing: 4
                        Text {
                            text: idsbox.index+1
                        }
                        Text {
                            text: idsbox.name
                            Layout.fillWidth: true
                        }                        
                        Button {
                            text: "Load"
                            onClicked: {
                                savedPositionsModel.loadPosition(index)
                            }
                        }
                        Button {
                            text: "Set A"
                            onClicked: {

                            }
                        }
                        Button {
                            text: "Set B"
                            onClicked: {

                            }
                        }
                        Button {
                            text: "Export..."
                            onClicked: {

                            }
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: atem
        function onConnected() {
            console.debug("SuperSource got connected")
        }
    }

    function syncBoxStatesToDevice() {
        for (var i=0;i<4;i++) {
            var sb=syncProxyRepeater.itemAt(i);
            sb.syncToDevice();
        }
    }

    function getPositions() {
        var boxes=[];
        for (var i=0;i<4;i++) {
            let model=ssModel.get(i);
            let item=syncProxyRepeater.itemAt(i)
            boxes[i]={
                "name": "Dummy",
                "enabled": item.onair,
                "source": item.src,
                "position": item.getPositionVector3d(),
                "crop": item.c,
                "cropping": item.getCropVector4d()
            };
        }
        return boxes;
    }

    function savePositions(bid) {
        savedPosition[bid]=[];
        savedCrop[bid]=[];
        for (var i=0;i<4;i++) {
            let item=syncProxyRepeater.itemAt(i)
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
            let item=syncProxyRepeater.itemAt(i)

            let v=savedPosition[bid][i];
            let c=savedCrop[bid][i];

            item.animateFrom=item.getPositionVector3d();
            item.animateTo=v;

            item.animateCropFrom=item.getCropVector4d();
            item.animateCropTo=c;
        }
    }

    // XXX: Modify model!
    function loadPositions(bid) {
        let s=ssSettings.value("ss_"+bid, false)
        for (var i=0;i<4;i++) {
            let item=syncProxyRepeater.itemAt(i)

            let v=savedPosition[bid][i];
            let c=savedCrop[bid][i];

            item.setPositionVector3d(v);
            item.setCropVector4d(c);
        }
    }

    function animateSuperSource(bid) {
        preparePositions(bid)
        syncProxyRepeater.animateStart();
    }

    function syncBoxFromProxy(boxid, proxy) {
        var sb=syncProxyRepeater.itemAt(boxid);
        sb.setItemCenter(proxy.x, proxy.y)
        sb.setItemSize(proxy.s)
    }

    ListModelSuperSourceBoxes {
        id: ssModel
    }

    Repeater {
        id: syncProxyRepeater
        model: ssModel
        delegate: syncProxyComponent

        property bool keepSync: isLive // XXX or optionally separate toDevice / fromDevice ?

        property int animatingCount: 0

        readonly property bool isAnimating: animatingCount>0

        onIsAnimatingChanged: console.debug("IsAnimating", isAnimating)

        Component.onCompleted: {
            if (atem.connected) {
                console.debug("Initial sync from device")
                syncFromDevice()
            } else {
                console.debug("Not connected, using local defaults")
                // reset()
            }
        }

        function setItemCenter(cx, cy) {
            ssModel.setProperty(currentBoxIndex, "cx", cx);
            ssModel.setProperty(currentBoxIndex, "cy", cy);
        }

        function setItemSize(s) {
            ssModel.setProperty(currentBoxIndex, "cs", s);
        }

        function setItemCrop(ct, cb, cl, cr) {
            ssModel.setProperty(currentBoxIndex, "cs", s);
        }

        function syncItemToDevice(i) {
            let item=itemAt(i)
            item.syncBoxState();
            item.syncBoxBorderState();
        }

        function syncFromDevice() {
            for (var i=0;i<4;i++) {
                syncItemToDevice(i)
            }
        }

        function syncToDevice() {
            for (var i=0;i<4;i++) {
                let item=itemAt(i)
                item.syncToDevice();
            }
        }

        function animateStart() {
            for (var i=0;i<4;i++) {
                let item=itemAt(i)
                item.animateStart();
            }
        }

        function animateStop() {
            for (var i=0;i<4;i++) {
                let item=itemAt(i)
                item.animateStop();
            }
        }
    }

    // Model syncer, keeps model update with device changes and local changes
    Component {
        id: syncProxyComponent
        Item {
            id: spci
            visible: false
            enabled: false

            required property int index;
            required property var model;

            required property bool onair;
            required property int src;

            required property double cx;
            required property double cy;
            required property double cs;

            required property bool c;
            required property int cLeft;
            required property int cRight;
            required property int cTop;
            required property int cBottom;

            required property AtemSuperSourceBox assb;
            assb: ss.getSuperSourceBox(index)

            readonly property point atemPosition: Qt.point(Math.round(cx*3200), Math.round(-cy*1800))
            readonly property int atemSize: cs*1000
            readonly property vector4d atemCrop: Qt.vector4d(cTop, cBottom, cLeft, cRight)

            property vector3d animateFrom;
            property vector3d animateTo;

            property vector4d animateCropFrom;
            property vector4d animateCropTo;

            property vector4d anim;

            property alias animateEasing: boxAnimation.easing.type
            property alias animateDuration: boxAnimation.duration

            readonly property alias animateRunning: boxAnimation.running

            function animateStart() {
                boxAnimation.restart();
                if (c)
                    v4.restart();
            }

            function animateStop() {
                boxAnimation.stop();
                v4.stop();
            }

            function getPositionVector3d() {
                return Qt.vector3d(model.cx, model.cy, model.cs)
            }

            function getCropVector4d() {
                return Qt.vector4d(model.cTop, model.cBottom, model.cLeft, model.cRight)
            }

            function setPositionVector3d(pv) {
                model.cx=pv.x;
                model.cy=pv.y;
                model.cs=pv.z;
            }

            function setCropVector4d(cv) {
                model.cTop=cv.x
                model.cBottom=cv.y
                model.cLeft=cv.z
                model.cRight=cv.w
            }

            signal animationTick();

            onAnimChanged: {
                setPositionVector3d(anim)
                animationTick();
            }

            Vector4dAnimation {
                id: v4
                from: animateCropFrom
                to: animateCropTo
                onValueChanged: {
                    setCropVector4d(value);
                }

                onStarted: {

                }

                onStopped: {

                }
            }

            Vector3dAnimation {
                id: boxAnimation
                easing.type: Easing.InOutCubic
                target: spci
                duration: 1000
                property: "anim"
                from: animateFrom
                to: animateTo

                onStarted: {
                    syncProxyRepeater.animatingCount++
                }

                onStopped: {
                    syncProxyRepeater.animatingCount--
                }
            }

            onCChanged: {
                console.debug("Syncing cropping to device", c)
                assb.setCropEnabled(c)
            }

            onOnairChanged: {
                console.debug("Syncing ON AIR to device", onair)
                assb.setOnAir(onair)
            }

            onSrcChanged: {
                console.debug("Syncing input source to device", src)
                assb.setSource(src)
            }

            onAtemPositionChanged: {
                console.debug("Syncing position to device", atemPosition)
                assb.setPosition(atemPosition)
            }

            onAtemSizeChanged: {
                console.debug("Syncing size + position to device", atemSize)
                assb.setPosition(atemPosition, atemSize)
            }

            onAtemCropChanged: {
                console.debug("Syncing crop to device", atemCrop)
                assb.setCrop(atemCrop);
            }

            Connections {
                target: assb
                enabled: syncProxyRepeater.keepSync
                function onBoxPropertiesChanged() {
                    console.debug("Device sent box property update, syncing to model")
                    spci.syncBoxState();
                }
                function onBorderPropertiesChanged() {
                    console.debug("Device sent box border update, syncing to model")
                    spci.syncBoxBorderState();
                }
            }

            function syncBoxState() {
                console.debug("Syncing live ssbox properties", assb.position, assb.size, assb.crop, assb.source)
                console.debug("CROP:", assb.cropRect)

                // Model has normalized values (xxx for now, this needs fixing)
                model.cx=assb.position.x/3200.0
                model.cy=-assb.position.y/1800.0
                model.cs=assb.size/1000.0

                model.c=assb.crop
                model.cTop=assb.cropRect.x
                model.cBottom=assb.cropRect.y
                model.cLeft=assb.cropRect.z
                model.cRight=assb.cropRect.w

                model.src=assb.source;
                model.onair=assb.onAir
            }

            function syncBoxBorderState() {
                console.debug("Syncing live ssbox border properties", assb.border, assb.borderColor)
                model.borderEnabled=assb.border;
                model.borderColor=""+assb.borderColor;
            }

            function syncToDevice() {
                console.debug("Syncing all ssbox properties to device", assb)
                assb.setBox(model.onair, model.src, atemPosition, atemSize, model.c, atemCrop);
                syncBorderToDevice();
            }
            function syncBorderToDevice() {
                console.debug("Syncing ssbox border to device", model.borderEnabled, model.borderColor)
                assb.setBorder(model.borderEnabled);
                assb.setBorderColor(model.borderColor);
            }
        }
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

    onSelectedBoxChanged: {

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
                        property int currentIndex: currentBoxIndex
                        model: ssModel
                        delegate: SuperSourceBox {
                            required property int index;
                            required property int box;
                            // Current Pos
                            required property double cx;
                            required property double cy;
                            required property double cs;

                            // Default pos
                            required property double dx;
                            required property double dy;
                            required property double ds;

                            required property bool onair;
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
                            // keep selected on top, otherwise in reverse index order (1,2,3,4 as on mixer)
                            z: ssBoxParent.currentIndex==index ? 10 : 4-index

                            assb: ss.getSuperSourceBox(index)

                            boxId: box
                            defaultX: dx
                            defaultY: dy
                            defaultSize: ds

                            enabled: onair
                            onCxChanged: setCenterX(cx)
                            onCyChanged: setCenterY(cy)
                            onCsChanged: setSize(cs)
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
                                currentBoxIndex=index
                            }
                            onFocusChanged: {
                                if (focus)
                                    currentBoxIndex=index
                            }
                            onBoxCenterChanged: {
                                model.cx=boxCenter.x
                                model.cy=boxCenter.y
                            }
                            onBoxSizeChanged: {
                                model.cs=boxSize
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
                    property int activeBox: currentBoxIndex
                    onActiveBoxChanged: {
                        for (var i = 0; i < buttons.length; ++i) {
                            if (buttons[i].boxIndex == activeBox)
                                buttons[i].checked=true;
                        }
                    }
                    onClicked: {
                        currentBoxIndex=button.boxIndex
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Repeater {
                        model: ssModel
                        ColumnLayout {
                            required property int index;
                            required property bool onair;
                            required property bool c
                            required property bool borderEnabled
                            required property var borderColor
                            required property var model;

                            property AtemSuperSourceBox assb: ss.getSuperSourceBox(index);

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
                                checked: onair
                                onCheckedChanged: ssModel.setProperty(index, "onair", checked)
                            }
                            CheckBox {
                                id: ssCrops
                                checked: c
                                text: "Crop"
                                onCheckedChanged: ssModel.setProperty(index, "c", checked)
                            }
                            RowLayout {
                                // visible: ss.bordersSupported
                                CheckBox {
                                    id: ssBorder
                                    checked: borderEnabled
                                    text: "Border"
                                    onCheckedChanged: ssModel.setProperty(index, "borderEnabled", checked)
                                }
                                Rectangle {
                                    width: height
                                    height: ssBorder.height
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
                    enabled: selectedBox!=null
                    model: superSourceInputModel
                    textRole: "longText"
                    valueRole: "index"
                    onActivated: {
                        ssModel.setProperty(currentBoxIndex, "src", currentValue)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    enabled: selectedBox!=null
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
                    enabled: selectedBox!=null
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
                    enabled: selectedBox!=null
                    Button {
                        text: "F"
                        onClicked: {
                            ssModel.setProperty(currentBoxIndex, "cs", 1);
                            ssModel.setProperty(currentBoxIndex, "cx", 0);
                            ssModel.setProperty(currentBoxIndex, "cy", 0);
                        }
                    }
                    Button {
                        text: "I"
                        onClicked: {
                            selectedBox.snapInside()
                        }
                    }
                    Button {
                        text: "R"
                        onClicked: {
                            ssModel.setProperty(currentBoxIndex, "cs", 1);
                            ssModel.setProperty(currentBoxIndex, "cx", 0);
                            ssModel.setProperty(currentBoxIndex, "cy", 0);
                        }
                    }
                }

                RowLayout {
                    enabled: selectedBox!=null
                    SpinBox {
                        id: boxSize
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        wheelEnabled: true
                        value: selectedBox ? selectedBox.boxSize*100 : 0
                        onValueModified: {
                            ssModel.setProperty(currentBoxIndex, "cs", value/100);
                        }
                    }
                    Button {
                        text: "25%"
                        Layout.fillWidth: false
                        onClicked: ssModel.setProperty(currentBoxIndex, "cs", 0.25);
                    }
                    Button {
                        text: "50%"
                        Layout.fillWidth: false
                        onClicked: ssModel.setProperty(currentBoxIndex, "cs", 0.50);
                    }
                    Button {
                        text: "75%"
                        Layout.fillWidth: false
                        onClicked: ssModel.setProperty(currentBoxIndex, "cs", 0.75);
                    }
                    Button {
                        text: "100%"
                        Layout.fillWidth: false
                        onClicked: ssModel.setProperty(currentBoxIndex, "cs", 1.00);
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    enabled: selectedBox && selectedBox.crop
                    SpinBox {
                        from: 0
                        to: 18000
                        stepSize: 10
                        wheelEnabled: true
                        editable: true
                        inputMethodHints: Qt.ImhDigitsOnly
                        value: selectedBox ? selectedBox.cropTop : 0
                        onValueModified: ssModel.setProperty(currentBoxIndex, "cTop", value);
                    }
                    SpinBox {
                        from: 0
                        to: 18000
                        stepSize: 10
                        wheelEnabled: true
                        editable: true
                        inputMethodHints: Qt.ImhDigitsOnly
                        value: selectedBox ? selectedBox.cropBottom : 0
                        onValueModified: ssModel.setProperty(currentBoxIndex, "cBottom", value);
                    }
                    Button {
                        text: "0%"
                        onClicked: {
                            ssModel.setProperty(currentBoxIndex, "cTop", 0)
                            ssModel.setProperty(currentBoxIndex, "cBottom", 0)
                        }
                    }
                    Button {
                        text: "25%"
                        onClicked: {
                            ssModel.setProperty(currentBoxIndex, "cTop", 2250)
                            ssModel.setProperty(currentBoxIndex, "cBottom", 2250)
                        }
                    }
                    Button {
                        text: "50%"
                        onClicked: {
                            ssModel.setProperty(currentBoxIndex, "cTop", 4500)
                            ssModel.setProperty(currentBoxIndex, "cBottom", 4500)
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    enabled: selectedBox && selectedBox.crop
                    SpinBox {
                        from: 0
                        to: 32000
                        stepSize: 10
                        wheelEnabled: true
                        editable: true
                        inputMethodHints: Qt.ImhDigitsOnly
                        value: selectedBox ? selectedBox.cropLeft : 0
                        onValueModified: ssModel.setProperty(currentBoxIndex, "cLeft", value);
                    }
                    SpinBox {
                        from: 0
                        to: 32000
                        stepSize: 10
                        wheelEnabled: true
                        editable: true
                        inputMethodHints: Qt.ImhDigitsOnly
                        value: selectedBox ? selectedBox.cropRight : 0
                        onValueModified: ssModel.setProperty(currentBoxIndex, "cRight", value);
                    }
                    Button {
                        text: "0%"
                        onClicked: {
                            ssModel.setProperty(currentBoxIndex, "cLeft", 0)
                            ssModel.setProperty(currentBoxIndex, "cRight", 0)
                        }
                    }
                    Button {
                        text: "25%"
                        onClicked: {
                            ssModel.setProperty(currentBoxIndex, "cLeft", 4000)
                            ssModel.setProperty(currentBoxIndex, "cRight", 4000)
                        }
                    }
                    Button {
                        text: "50%"
                        onClicked: {
                            ssModel.setProperty(currentBoxIndex, "cLeft", 8000)
                            ssModel.setProperty(currentBoxIndex, "cRight", 8000)
                        }
                    }
                    Button {
                        text: "75%"
                        onClicked: {
                            ssModel.setProperty(currentBoxIndex, "cLeft", 12000)
                            ssModel.setProperty(currentBoxIndex, "cRight", 12000)
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
                            syncProxyRepeater.itemAt(currentBoxIndex).animateEasing=currentValue
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
                            syncProxyRepeater.itemAt(currentBoxIndex).animateDuration=value*1000;
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
                                            stop();
                                    }
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
                text: "Commit 1"
                enabled: selectedBox && !isLive
                onClicked: {
                    syncProxyRepeater.syncItemToDevice(currentBoxIndex)
                }
            }
            Button {
                text: "Commit A"
                enabled: !isLive
                onClicked: {
                    syncProxyRepeater.syncToDevice();
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
                enabled: !syncProxyRepeater.isAnimating
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
