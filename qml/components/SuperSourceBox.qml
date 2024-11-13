import QtQuick
import QtQuick.Layouts

import org.bm 1.0

Rectangle {
    id: sizeRect
    x: parent.width*boxX
    y: parent.height*boxY
    width: parent.width*boxSize
    height: parent.height*boxSize
    color: crop ? "#214ddf4d" : "#914ddf4d"
    border.color: enabled ? "#20ff20" : "#ff2020"
    border.width: activated ? 2 : 1
    opacity: enabled ? 1 : 0.2
    activeFocusOnTab: true

    required property AtemSuperSourceBox assb;

    property int dragMargin: 16

    property bool selected: false

    property bool activated: focus || selected

    property bool enabled: true

    property bool keepCenter: true
    property bool keepInside: false

    property bool keepSync: true

    property bool crop: false
    property double cropTop: 0
    property double cropBottom: 0
    property double cropLeft: 0
    property double cropRight: 0

    property bool borderEnabled: false
    property color borderColor: "#ffffff"
    property int borderWidthInner: 0
    property int borderWidthOuter: 0

    property int boxId: 1
    property double defaultX: 0
    property double defaultY: 0
    property double defaultSize: 0.5

    // Normalized position 0-1
    readonly property double boxX: -(boxSize/2)+0.5+setX;
    readonly property double boxY: -(boxSize/2)+0.5+setY;
    property double boxSize: 0.5;

    readonly property double boxCenterX: (boxSize/2)+boxX-0.5
    readonly property double boxCenterY: (boxSize/2)+boxY-0.5

    // The set position -1 - 0 - 1
    property double setY;
    property double setX;

    property point boxCenter: Qt.point(boxCenterX, boxCenterY)

    property int inputSource: 1000;

    readonly property double ratio: 16.0/9.0
    readonly property double cropRatioTB: 18000
    readonly property double cropRatioLR: 32000

    // Position & crop in mixer values
    readonly property point atemPosition: Qt.point(boxCenterX*3200, -boxCenterY*1800)
    readonly property int atemSize: boxSize*1000
    readonly property vector4d atemCrop: Qt.vector4d(cropTop, cropBottom, cropLeft, cropRight)

    onAtemCropChanged: console.debug("AtemCrop", atemCrop)
    onAtemSizeChanged: console.debug("AtemSize", atemSize)
    onAtemPositionChanged: console.debug("AtemPos", atemPosition)

    //onBoxXChanged: x=parent.width*boxX
    //onBoxYChanged: y=parent.height*boxY

    readonly property double _phw: parent.width+parent.height

    onDefaultSizeChanged: boxSize=defaultSize
    Component.onCompleted: {
        if (atem.connected) {
            console.debug("Initial sync from device")
        } else {
            console.debug("Not connected, using local defaults")
            reset()
        }
    }

    signal clicked()

    function setCenter(cx,cy) {
        setX=cx;
        setY=cy;
    }

    function setCenterX(cx) {
        setX=cx;
    }

    function setCenterY(cy) {
        setY=cy;
    }

    function _setCrop(ct, cb, cl, cr) {
        console.debug("*************** XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX *********************")
        cropLeft=cl;
        cropRight=cr;
        cropTop=ct;
        cropBottom=cb;
    }

    function setSize(s) {
        boxSize=s;
    }

    function updatePositionData() {
        var bx=x/parent.width
        var by=y/parent.height
        setX=(boxSize/2)+bx-0.5
        setY=(boxSize/2)+by-0.5
    }

    onBoxSizeChanged: {        
        if (bottomRightDrag.dragAactive)
            return;
        if (boxSize>1)
            boxSize=1
        else if (boxSize<0)
            boxSize=0

        sizeRect.width=sizeRect.parent.width*boxSize
        sizeRect.height=sizeRect.parent.height*boxSize
    }

    function getPositionVector3d() {
        return Qt.vector3d(boxCenterX, boxCenterY, boxSize)
    }

    function setPositionVector3d(v) {
        setCenter(v.x,v.y)
        setSize(v.z)
    }

    function getCropVector4d() {
        return Qt.vector4d(cropTop, cropBottom, cropLeft, cropRight)
    }

    function _setCropVector4d(c) {
        // XXX
        setCrop(c.x, c.y, c.z, c.w)
    }

    property vector3d anim;
    signal animationTick();

    onAnimChanged: {
        setPositionVector3d(anim)
        animationTick();
    }

    // Position animation
    property vector3d animateFrom;
    property vector3d animateTo;

    property vector4d animateCropFrom;
    property vector4d animateCropTo;

    property alias animateEasing: boxAnimation.easing.type
    property alias animateDuration: boxAnimation.duration

    readonly property alias animateRunning: boxAnimation.running

    property bool slowDown: false
    property bool snapToGrid: false
    property bool dragOutside: true

    property bool locked: false

    function animate() {
        boxAnimation.restart();
        if (crop)
            v4.restart();
    }

    function animateStop() {
        boxAnimation.stop();        
        v4.stop();
    }

    Vector4dAnimation {
        id: v4
        from: animateCropFrom
        to: animateCropTo
        // XXX onValueChanged: setCropVector4d(value)
    }

    Vector3dAnimation {
        id: boxAnimation
        easing.type: Easing.InOutCubic
        target: sizeRect
        duration: 1000
        property: "anim"
        from: animateFrom
        to: animateTo
    }

    readonly property double keyMove: snapToGrid ? 0.02 : 0.001

    Keys.onLeftPressed: setX-=keyMove
    Keys.onRightPressed: setX+=keyMove
    Keys.onUpPressed: setY-=keyMove
    Keys.onDownPressed: setY+=keyMove
    Keys.onSpacePressed: sizeRect.enabled=!enabled
    Keys.onAsteriskPressed: sizeRect.crop=!crop
    Keys.onPressed: (event) => {
        if (event.modifiers & Qt.AltModifier)
            dragOutside=false;
        switch (event.key) {
        case Qt.Key_Plus:
            boxSize+=0.01
            event.accepted = true;
            break;
        case Qt.Key_Minus:
            boxSize-=0.01
            event.accepted = true;
            break;
        case Qt.Key_PageUp:
            boxSize+=0.1
            event.accepted = true;
            break;
        case Qt.Key_PageDown:
            boxSize-=0.1
            event.accepted = true;
            break;
        case Qt.Key_Home:
            boxSize=1
            event.accepted = true;
            break;
        case Qt.Key_End:
            boxSize=0.5
            event.accepted = true;
            break;
        case Qt.Key_Delete:
            boxSize=0.0
            event.accepted = true;
            break;
        }
    }

    Keys.onReleased: {
        setKeyboardDefaults()
        if (snapToGrid) {
            setX=snapX.output
            setY=snapY.output
        }
    }

    function setKeyboardDefaults() {
        slowDown=false;        
        dragOutside=true;
    }

    function snapGrid() {
        setX=snapX.output
        setY=snapY.output
    }

    function snapInside() {
        var s=0.5-boxSize/2
        if (setX<-s)
            setX=-s
        if (setY<-s)
            setY=-s;
        if (setX>s)
            setX=s;
        if (setY>s)
            setY=s;
    }

    function reset() {
        console.debug("Reset ssbox", defaultX, defaultY, defaultSize)
        boxSize=defaultSize
        setX=defaultX
        setY=defaultY
    }

    Rectangle {
        id: cropCenterRectangle
        anchors.centerIn: parent
        anchors.margins: dragMargin
        width: parent.width
        height: parent.height
        color: "white"
        opacity: (dragArea.pressed || sizeRect.focus || selected) ? 0.2 : 0.0
    }

    // XXX
    Rectangle {        
        x: 0+((parent.width/cropRatioLR)*cropLeft)
        y: 0+((parent.height/cropRatioTB)*cropTop)
        width: parent.width-((parent.width/cropRatioLR)*cropRight)-x
        height: parent.height-((parent.height/cropRatioTB)*cropBottom)-y
        color: "#914ddf4d"
        visible: crop
        border.color: "black"
        border.width: crop ? 1 : 0
    }

    function externalWheelEventHandler(wheel) {
        dragArea.wheelEventHandler(wheel)
    }

    MouseArea {
        id: dragArea
        anchors.fill: cropCenterRectangle
        anchors.margins: 8
        drag.target: sizeRect
        drag.minimumX: dragOutside ? -sizeRect.parent.width : 0
        drag.maximumX: dragOutside ? sizeRect.parent.width : sizeRect.parent.width-sizeRect.width

        drag.minimumY: dragOutside ? -sizeRect.parent.height : 0
        drag.maximumY: dragOutside ? sizeRect.parent.height : sizeRect.parent.height-sizeRect.height

        cursorShape: Qt.DragMoveCursor

        focus: true

        enabled: !locked

        function wheelSizeAdjust(delta) {
            if (boxSize<=0)
                boxSize=0.01;
            boxSize=boxSize+(delta)
            if (boxSize<=0)
                boxSize=0.01;
            if (boxSize>1)
                boxSize=1
        }

        function adjustXCrop(delta) {
            sizeRect.cropLeft=sizeRect.cropLeft+delta
            sizeRect.cropRight=sizeRect.cropRight+delta
            if (sizeRect.cropLeft<0)
                sizeRect.cropLeft=0
            if (sizeRect.cropRight<0)
                sizeRect.cropRight=0
        }

        function adjustYCrop(delta) {
            sizeRect.cropTop=sizeRect.cropTop+delta
            sizeRect.cropBottom=sizeRect.cropBottom+delta
            if (sizeRect.cropTop<0)
                sizeRect.cropTop=0
            if (sizeRect.cropBottom<0)
                sizeRect.cropBottom=0
        }

        function wheelEventHandler(wheel) {
            if (wheel.modifiers==Qt.NoModifier) {
                wheelSizeAdjust(wheel.angleDelta.y/4800.0)
            } else if ((wheel.modifiers & Qt.ShiftModifier) && (wheel.modifiers & Qt.ControlModifier)) {
                wheelSizeAdjust(wheel.angleDelta.y/9600.0)
            } else if (wheel.modifiers & Qt.ControlModifier) {
                adjustYCrop(wheel.angleDelta.y/180)
            } else if (wheel.modifiers & Qt.ShiftModifier) {
                adjustXCrop(wheel.angleDelta.y/180)
            }
        }

        onWheel: {
            wheelEventHandler(wheel)
            wheel.accepted=true
        }

        drag.onActiveChanged: {
            var bx=sizeRect.x/sizeRect.parent.width
            var by=sizeRect.y/sizeRect.parent.height

            if (!drag.active) {
                setX=(boxSize/2)+bx-0.5
                setY=(boxSize/2)+by-0.5
                if (snapToGrid) { //xxx
                    setX=snapX.output
                    setY=snapY.output
                }
            } else {
                sizeRect.focus=true

            }
        }

        onClicked: {
            sizeRect.focus=true
            sizeRect.clicked()
        }

        onPressAndHold: {
            sizeRect.locked=true
        }

        onDoubleClicked: {
            sizeRect.enabled=!sizeRect.enabled
        }

        SnapToGrid {
            id: snapX
            input: setX
            size: 20
        }
        SnapToGrid {
            id: snapY
            input: setY
            size: 20
        }
    }

    MouseArea {
        id: lockedArea
        anchors.fill: cropCenterRectangle
        enabled: !dragArea.enabled
        onDoubleClicked: {
            sizeRect.locked=false
        }
    }

    RowLayout {
        anchors.centerIn: parent
        Text {
            id: boxLabel
            text: '#'+boxId+(crop ? "c" : "")
            color: sizeRect.enabled ? "white" : "black"
            font.bold: activated
            font.strikeout: !sizeRect.enabled
            font.italic: sizeRect.locked
            font.pixelSize: boxSize < 0.3 ? 22 : 32
        }
        Text {
            id: inputLabel
            color: sizeRect.enabled ? "white" : "black"
            font.pixelSize: boxSize < 0.3 ? 18 : 24
        }
    }


    DragBox {
        id: bottomRightDrag
        dragItem: sizeRect
        border.width: activated ? 2 : 1
        anchors.horizontalCenter: sizeRect.right
        anchors.verticalCenter: sizeRect.bottom
    }

}
