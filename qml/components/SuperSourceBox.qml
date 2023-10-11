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

    property bool crop: false
    property double cropTop: 0
    property double cropBottom: 0
    property double cropLeft: 0
    property double cropRight: 0

    property int boxId: 1
    property double defaultX: 0
    property double defaultY: 0
    property double defaultSize: 0.5

    // Normalized
    property double boxX;
    property double boxY;
    property double boxSize;

    property double boxCenterX: (boxSize/2)+boxX-0.5
    property double boxCenterY: (boxSize/2)+boxY-0.5

    property point boxCenter: Qt.point(boxCenterX, boxCenterY)

    property int inputSource: 1000;

    // Position & crop in mixer values
    property point atemPosition: Qt.point(boxCenterX*3200, -boxCenterY*1800)
    property int atemSize: boxSize*1000
    property rect atemCrop: Qt.rect(cropLeft/cropRatio*18000,
                                    cropTop/cropRatio*18000,
                                    cropRight/cropRatio*18000,
                                    cropBottom/cropRatio*18000)

    onAtemCropChanged: console.debug("atemCrop "+ atemCrop)
    onAtemPositionChanged: console.debug("AtemPos "+ atemPosition)

    readonly property double ratio: 16.0/9.0
    readonly property double cropRatio: 2048

    signal clicked()

    readonly property int _pwh: parent.width+parent.height

    on_PwhChanged: updateBox()
    onParentChanged: updateBox();

    function updateBox() {
        x=parent.width*boxX
        y=parent.height*boxY
        width=parent.width*boxSize
        height=parent.height*boxSize
    }

    function setCenter(x,y) {
        setCenterX(x)
        setCenterY(y)
    }

    function setCenterX(x) {
        boxX=-(boxSize/2)+0.5+x
    }

    function setCenterY(y) {
        boxY=-(boxSize/2)+0.5+y
    }

    onBoxXChanged: x=parent.width*boxX
    onBoxYChanged: y=parent.height*boxY

    onDefaultSizeChanged: boxSize=defaultSize
    Component.onCompleted: {        
        reset()
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
        if (bRD.drag.active)
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

    property vector3d animateFrom;
    property vector3d animateTo;

    function animate() {
        boxAnimation.start();
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

    Keys.onLeftPressed: boxX-=0.01
    Keys.onRightPressed: boxX+=0.01
    Keys.onUpPressed: boxY-=0.01
    Keys.onDownPressed: boxY+=0.01
    Keys.onSpacePressed: sizeRect.enabled=!enabled
    Keys.onAsteriskPressed: sizeRect.crop=!crop

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
        if (sizeRect.x<0)
            sizeRect.x=0
        if (sizeRect.y<0)
            sizeRect.y=0

        if (x>sizeRect.parent.width-sizeRect.width)
            x=sizeRect.parent.width-sizeRect.width
        if (y>sizeRect.parent.height-sizeRect.height)
            y=sizeRect.parent.height-sizeRect.height;

        boxX=sizeRect.x/sizeRect.parent.width
        boxY=sizeRect.y/sizeRect.parent.height
    }

    function reset() {
        boxSize=defaultSize
        boxX=defaultX
        boxY=defaultY
        x=parent.width*boxX
        y=parent.height*boxY
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
                boxX=sizeRect.x/sizeRect.parent.width
                boxY=sizeRect.y/sizeRect.parent.height
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

    Rectangle {
        id: bottomRightDrag
        anchors.horizontalCenter: sizeRect.right
        anchors.verticalCenter: sizeRect.bottom
        color: "#4c57d4e1"
        border.color: "#8c57d4e1"
        border.width: 2
        width: dragMargin
        height: dragMargin
        radius: dragMargin/2

        MouseArea {
            id: bRD
            anchors.fill: bottomRightDrag
            drag.target: parent
            drag.threshold: 1

            onPositionChanged: {
                if (drag.active) {
                    sizeRect.width = sizeRect.width + mouseX
                    //sizeRect.height = sizeRect.height + mouseY
                    sizeRect.height = sizeRect.width/ratio

                    sizeRect.width = sizeRect.height*ratio

                    // Update normalized values
                    boxSize=sizeRect.width/sizeRect.parent.width
                    if (boxSize>1) {
                        boxSize=1
                        sizeRect.width=sizeRect.parent.width
                        sizeRect.height=sizeRect.parent.height
                    }

                    /*
                    if (sizeRect.width < dragMargin)
                        sizeRect.width = dragMargin
                    else if (sizeRect.width > sizeRect.parent.width-sizeRect.x)
                        sizeRect.width=sizeRect.parent.width-sizeRect.x

                    if (sizeRect.height < dragMargin)
                        sizeRect.height = dragMargin
                    else if (sizeRect.height > sizeRect.parent.height-sizeRect.y)
                        sizeRect.height=sizeRect.parent.height-sizeRect.y
                    */
                } else {

                }
            }
        }
    }
}
