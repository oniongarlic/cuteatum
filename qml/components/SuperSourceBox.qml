import QtQuick 2.15

Rectangle {
    id: cropRect
    x: parent.width*defaultX
    y: parent.height*defaultY
    width: parent.width*defaulWidth
    height: parent.height*defaulHeight
    color: "#4c57d4e1"
    border.color: enabled ? "#40f440e0" : "#f44040e0"
    border.width: 4

    property int dragMargin: 16

    property bool enabled: true

    property int boxId: 1
    property double defaultX: 0
    property double defaultY: 0
    property double defaulWidth: 0.5
    property double defaulHeight: 0.5

    signal clicked()

    function mapNormalizedRect() {
        return Qt.rect(cropRect.x/parent.width,
                       cropRect.y/parent.height,
                       cropRect.width/parent.width,
                       cropRect.height/parent.height)
    }

    Keys.onLeftPressed: cropRect.x--
    Keys.onRightPressed: cropRect.x++
    Keys.onUpPressed: cropRect.y--
    Keys.onDownPressed: cropRect.y++
    Keys.onSpacePressed: cropRect.enabled=!enabled

    Rectangle {
        id: cropCenterRectangle
        anchors.centerIn: parent
        anchors.margins: dragMargin
        width: parent.width
        height: parent.height
        color: "white"
        opacity: (cropCenterArea.pressed || cropRect.focus) ? 0.2 : 0.0
    }

    MouseArea {
        id: cropCenterArea
        anchors.fill: cropCenterRectangle
        anchors.margins: 8
        drag.target: cropRect
        drag.minimumX: 0
        drag.maximumX: cropRect.parent.width-cropRect.width

        drag.minimumY: 0
        drag.maximumY: cropRect.parent.height-cropRect.height

        onWheel: {
            console.debug(wheel.angleDelta)
        }

        drag.onActiveChanged: {
            if (!drag.active) {
                console.debug("Drag ended: "+boxId)
                console.debug(mapNormalizedRect());
            }
        }

        onClicked: {
            cropRect.focus=true
            cropRect.clicked()
        }

        onPressAndHold: {
            reset();
        }

        onDoubleClicked: {
            cropRect.enabled=!cropRect.enabled
        }

        function reset() {
            cropRect.x=cropRect.parent.width*defaultX;
            cropRect.y=cropRect.parent.height*defaultY;
            cropRect.width=cropRect.parent.width*defaulWidth
            cropRect.height=cropRect.parent.height*defaulHeight
        }
    }

    Text {
        text: '#'+boxId
        anchors.centerIn: parent
        color: cropRect.enabled ? "green" : "black"
        font.pixelSize: 24
    }

    Rectangle {
        id: bottomRightDrag
        anchors.horizontalCenter: cropRect.right
        anchors.verticalCenter: cropRect.bottom
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
                if(drag.active){
                    cropRect.width = cropRect.width + mouseX
                    cropRect.height = cropRect.height + mouseY

                    if (cropRect.width < dragMargin)
                        cropRect.width = dragMargin
                    else if (cropRect.width > cropRect.parent.width-cropRect.x)
                        cropRect.width=cropRect.parent.width-cropRect.x

                    if (cropRect.height < dragMargin)
                        cropRect.height = dragMargin
                    else if (cropRect.height > cropRect.parent.height-cropRect.y)
                        cropRect.height=cropRect.parent.height-cropRect.y
                }
            }
        }
    }
}
