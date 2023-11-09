import QtQuick

Rectangle {
    id: dragBox
    color: "#4c57d4e1"
    border.color: "#8c57d4e1"
    border.width: 2

    property int dragMargin: 16    
    property bool keepInside: false
    property double ratio: 16/9
    required property Item dragItem;

    property alias dragActive: bRD.drag.active

    width: dragMargin
    height: dragMargin
    radius: dragMargin/2

    MouseArea {
        id: bRD
        anchors.fill: parent
        drag.target: parent
        drag.threshold: 1

        cursorShape: Qt.SizeFDiagCursor

        drag.onActiveChanged: {
            dragItem.forceActiveFocus();
        }

        onPositionChanged: {
            if (drag.active) {

                dragItem.width = dragItem.width + mouseX
                //sizeRect.height = sizeRect.height + mouseY

                if (keepInside) {
                    if (dragItem.width < dragMargin)
                        dragItem.width = dragMargin
                    else if (dragItem.width > dragItem.parent.width-dragItem.x)
                        dragItem.width=dragItem.parent.width-dragItem.x

                    if (dragItem.height < dragMargin)
                        dragItem.height = dragMargin
                    else if (dragItem.height > dragItem.parent.height-dragItem.y)
                        dragItem.height=dragItem.parent.height-dragItem.y
                }

                dragItem.height = dragItem.width/ratio
                dragItem.width = dragItem.height*ratio

                // Update normalized values
                dragItem.boxSize=dragItem.width/dragItem.parent.width
                if (dragItem.boxSize>1) {
                    dragItem.boxSize=1
                    dragItem.width=dragItem.parent.width
                    dragItem.height=dragItem.parent.height
                }
            }
        }
    }
}
