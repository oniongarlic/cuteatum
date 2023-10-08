import QtQuick

Rectangle {
    id: sizeRect
    x: parent.width*boxX
    y: parent.height*boxY
    width: parent.width*boxSize
    height: parent.height*boxSize
    color: "#4c57d4e1"
    border.color: enabled ? "#40f440e0" : "#f44040e0"
    border.width: 4

    property int dragMargin: 16

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

    onBoxXChanged: x=parent.width*boxX
    onBoxYChanged: y=parent.height*boxY

    onDefaultSizeChanged: boxSize=defaultSize
    Component.onCompleted: {
        console.debug("onCompleted: "+boxSize)
        console.debug("onCompleted: "+defaultX)
        console.debug("onCompleted: "+defaultY)
        boxSize=defaultSize
        boxX=defaultX
        boxY=defaultY
        x=parent.width*boxX
        y=parent.height*boxY
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
        console.debug("onBoxSizeChanged: "+boxSize)
        if (bRD.drag.active)
            return;
        sizeRect.width=sizeRect.parent.width*boxSize
        sizeRect.height=sizeRect.parent.height*boxSize
    }

    Keys.onLeftPressed: boxX-=0.01
    Keys.onRightPressed: boxX+=0.01
    Keys.onUpPressed: boxY-=0.01
    Keys.onDownPressed: boxY+=0.01
    Keys.onSpacePressed: sizeRect.enabled=!enabled

    Rectangle {
        id: cropCenterRectangle
        anchors.centerIn: parent
        anchors.margins: dragMargin
        width: parent.width
        height: parent.height
        color: "white"
        opacity: (cropCenterArea.pressed || sizeRect.focus) ? 0.2 : 0.0
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

    MouseArea {
        id: cropCenterArea
        anchors.fill: cropCenterRectangle
        anchors.margins: 8
        drag.target: sizeRect
        drag.minimumX: 0
        drag.maximumX: sizeRect.parent.width-sizeRect.width

        drag.minimumY: 0
        drag.maximumY: sizeRect.parent.height-sizeRect.height

        onWheel: {
            console.debug(boxSize)
            if (boxSize<=0)
                boxSize=0.01;
            boxSize=boxSize+(wheel.angleDelta.y/4800.0)
            if (boxSize<=0)
                boxSize=0.01;
            if (boxSize>1)
                boxSize=1
            console.debug(boxSize)
        }

        drag.onActiveChanged: {
            if (!drag.active) {
                console.debug("Drag ended: "+boxId)
                console.debug(mapNormalizedRect());
            }
        }

        onClicked: {
            sizeRect.focus=true
            sizeRect.clicked()
        }

        onPressAndHold: {
            reset();
        }

        onDoubleClicked: {
            sizeRect.enabled=!sizeRect.enabled
        }

        function reset() {
            boxSize=defaultSize
            sizeRect.x=sizeRect.parent.width*defaultX;
            sizeRect.y=sizeRect.parent.height*defaultY;
            sizeRect.width=sizeRect.parent.width*boxSize
            sizeRect.height=sizeRect.parent.height*boxSize
        }
    }

    Text {
        text: '#'+boxId+(crop ? "c" : "")
        anchors.centerIn: parent
        color: sizeRect.enabled ? "green" : "black"
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

                    boxSize=sizeRect.width/sizeRect.parent.width

                    if (sizeRect.width < dragMargin)
                        sizeRect.width = dragMargin
                    else if (sizeRect.width > sizeRect.parent.width-sizeRect.x)
                        sizeRect.width=sizeRect.parent.width-sizeRect.x

                    if (sizeRect.height < dragMargin)
                        sizeRect.height = dragMargin
                    else if (sizeRect.height > sizeRect.parent.height-sizeRect.y)
                        sizeRect.height=sizeRect.parent.height-sizeRect.y
                } else {

                }
            }
        }
    }
}
