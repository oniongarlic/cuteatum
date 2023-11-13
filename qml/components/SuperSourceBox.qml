import QtQuick

Rectangle {
    id: sizeRect
    x: parent.width*boxX
    y: parent.height*boxY
    width: parent.width*boxSize
    height: parent.height*boxSize
    color: "#4c57d4e1"
    border.color: enabled ? "#20ff20" : "#ff2020"
    border.width: activated ? 2 : 1
    opacity: enabled ? 1 : 0.2
    activeFocusOnTab: true

    property int dragMargin: 16

    property bool selected: false

    property bool activated: focus || selected

    property bool enabled: true

    property bool keepCenter: true
    property bool keepInside: false

    property bool crop: false
    property double cropTop: 0
    property double cropBottom: 0
    property double cropLeft: 0
    property double cropRight: 0

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
    readonly property double cropRatio: 2048

    // Position & crop in mixer values
    readonly property point atemPosition: Qt.point(boxCenterX*3200, -boxCenterY*1800)
    readonly property int atemSize: boxSize*1000
    readonly property rect atemCrop: Qt.rect(cropLeft/cropRatio*18000,
                                    cropTop/cropRatio*18000,
                                    cropRight/cropRatio*18000,
                                    cropBottom/cropRatio*18000)

    onAtemCropChanged: console.debug("atemCrop "+ atemCrop)
    onAtemPositionChanged: console.debug("AtemPos "+ atemPosition)

    onBoxXChanged: x=parent.width*boxX
    onBoxYChanged: y=parent.height*boxY

    readonly property double _phw: parent.width+parent.height

    on_PhwChanged: {
        _updateXY();
    }

    onParentChanged: {
        _updateXY();
    }

    function _updateXY() {
        x=parent.width*boxX
        y=parent.height*boxY
        width=parent.width*boxSize
        height=parent.height*boxSize
    }

    signal clicked()

    onDefaultSizeChanged: boxSize=defaultSize
    Component.onCompleted: {
        reset()
        _updateXY();
    }

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

    function setAtemPosition(p) {
        setCenter(p.x/3200, -p.y/1800)
    }

    function mapNormalizedRect() {
        return Qt.rect(sizeRect.x/parent.width,
                       sizeRect.y/parent.height,
                       sizeRect.width/parent.width,
                       sizeRect.height/parent.height)
    }
    function cropNormalizedRect() {
        return Qt.rect(cropLeft/cropRatio,
                       cropTop/cropRatio,
                       cropRight/cropRatio,
                       cropBottom/cropRatio)
    }

    function setSize(s) {
        boxSize=s;
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

    property vector3d anim;

    onAnimChanged: {
        setPositionVector3d(anim)
    }

    // Position animation
    property vector3d animateFrom;
    property vector3d animateTo;
    property alias animateEasing: boxAnimation.easing.type
    property alias animateDuration: boxAnimation.duration

    readonly property alias animateRunning: boxAnimation.running

    function animate() {
        boxAnimation.restart();
    }

    function animateStop() {
        boxAnimation.stop();
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

    Keys.onLeftPressed: setX-=0.001
    Keys.onRightPressed: setX+=0.001
    Keys.onUpPressed: setY-=0.001
    Keys.onDownPressed: setY+=0.001
    Keys.onSpacePressed: sizeRect.enabled=!enabled
    Keys.onAsteriskPressed: sizeRect.crop=!crop
    Keys.onPressed: (event) => {
        switch (event.key) {
        case Qt.Key_Plus:
            boxSize+=0.01
            break;
        case Qt.Key_Minus:
            boxSize-=0.01
            break;
        case Qt.Key_PageUp:
            boxSize+=0.1
            break;
        case Qt.Key_PageDown:
            boxSize-=0.1
            break;
        case Qt.Key_Home:
            boxSize=1
            break;
        case Qt.Key_End:
            boxSize=0.5
            break;
        case Qt.Key_Delete:
            boxSize=0.0
            break;
        }
    }

    Rectangle {
        id: cropCenterRectangle
        anchors.centerIn: parent
        anchors.margins: dragMargin
        width: parent.width
        height: parent.height
        color: "white"
        opacity: (cropCenterArea.pressed || sizeRect.focus || selected) ? 0.2 : 0.0
    }
    Rectangle {
        x: 0+((parent.width/cropRatio)*cropLeft)
        y: 0+((parent.height/cropRatio)*cropTop)
        width: parent.width-((parent.width/cropRatio)*cropRight)-x
        height: parent.height-((parent.height/cropRatio)*cropBottom)-y
        color: "transparent"
        border.color: "black"
        border.width: crop ? 1 : 0
    }

    property bool dragOutside: true

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
        boxSize=defaultSize
        setX=defaultX
        setY=defaultY
    }

    MouseArea {
        id: cropCenterArea
        anchors.fill: cropCenterRectangle
        anchors.margins: 8
        drag.target: sizeRect
        drag.minimumX: dragOutside ? -sizeRect.parent.width : 0
        drag.maximumX: dragOutside ? sizeRect.parent.width : sizeRect.parent.width-sizeRect.width

        drag.minimumY: dragOutside ? -sizeRect.parent.height : 0
        drag.maximumY: dragOutside ? sizeRect.parent.height : sizeRect.parent.height-sizeRect.height

        cursorShape: Qt.DragMoveCursor

        onWheel: {            
            if (boxSize<=0)
                boxSize=0.01;
            boxSize=boxSize+(wheel.angleDelta.y/4800.0)
            if (boxSize<=0)
                boxSize=0.01;
            if (boxSize>1)
                boxSize=1
        }

        drag.onActiveChanged: {
            if (!drag.active) {                
                var bx=sizeRect.x/sizeRect.parent.width
                var by=sizeRect.y/sizeRect.parent.height
                setX=(boxSize/2)+bx-0.5
                setY=(boxSize/2)+by-0.5
            } else {
                sizeRect.focus=true
            }
        }

        onClicked: {
            sizeRect.focus=true
            sizeRect.clicked()
        }

        onPressAndHold: {
            //reset();
        }

        onDoubleClicked: {
            sizeRect.enabled=!sizeRect.enabled
        }        
    }

    Text {
        text: '#'+boxId+(crop ? "c" : "")
        anchors.centerIn: parent
        color: sizeRect.enabled ? "green" : "black"
        font.bold: activated
        font.strikeout: !sizeRect.enabled
        font.pixelSize: 24
    }

    DragBox {
        id: bottomRightDrag
        dragItem: sizeRect
        anchors.horizontalCenter: sizeRect.right
        anchors.verticalCenter: sizeRect.bottom
    }

}
