import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../models"

import org.bm 1.0

Drawer {
    id: uskDrawer
    interactive: visible
    width: parent.width/2
    height: root.height

    required property int key;
    required property AtemMixEffect me;

    onOpened: {
        dveXPos.value=me.upstreamKeyDVEXPosition(key)*1000
        dveYPos.value=me.upstreamKeyDVEYPosition(key)*1000
        dveXSize.value=me.upstreamKeyDVEXSize(key)*100
        dveYSize.value=me.upstreamKeyDVEYSize(key)*100
    }

    Connections {
        id: me0
        target: me

        onUpstreamKeyDVEXPositionChanged: {
            console.debug("X:", xPosition, keyer)
            dveXPos.enabled=false
            dveXPos.value=Math.floor(xPosition*1000)
            dveXPos.enabled=true
        }

        onUpstreamKeyDVEYPositionChanged: {
            console.debug("Y:", yPosition, keyer)
            dveYPos.enabled=false
            dveYPos.value=Math.round(yPosition*1000)
            dveYPos.enabled=true
        }

        onUpstreamKeyDVEXSizeChanged: {
            console.debug("XS:", xSize, keyer)
            dveXSize.value=Math.round(xSize*100)
        }

        onUpstreamKeyDVEYSizeChanged: {
            console.debug("YS:", ySize, keyer)
            dveYSize.value=Math.round(ySize*100)
        }
    }

    ParallelAnimation {
        id: dveAnimation

        property real xPosStart: 0
        property real xPosEnd: 0

        property real yPosStart: 0
        property real yPosEnd: 0

        property real sizeStart: 0
        property real sizeEnd: 0

        property int duration: 1000

        NumberAnimation { from: dveAnimation.xPosStart; to: dveAnimation.xPosEnd; duration: dveAnimation.duration; properties: "value"; target: dveXPos }
        NumberAnimation { from: dveAnimation.yPosStart; to: dveAnimation.yPosEnd; duration: dveAnimation.duration; properties: "value"; target: dveYPos }
        NumberAnimation { from: dveAnimation.sizeStart; to: dveAnimation.sizeEnd; duration: dveAnimation.duration; properties: "value"; targets: [ dveXSize, dveYSize ]}
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        Label {
            text: "Upstream key properties"
        }
        Label {
            text: "Position"
        }
        RowLayout {
            SpinBox {
                id: dveXPos
                editable: true
                from: -100000
                to: 100000
                stepSize: 100
                wheelEnabled: true
                onValueModified: {
                    if (!enabled) return;
                    me.setUpstreamKeyDVEPosition(key, value/1000, me.upstreamKeyDVEYPosition(key))
                }
            }

            SpinBox {
                id: dveYPos
                editable: true
                from: -100000
                to: 100000
                stepSize: 100
                wheelEnabled: true
                onValueModified: {
                    if (!enabled) return;
                    me.setUpstreamKeyDVEPosition(key, me.upstreamKeyDVEXPosition(key), value/1000)
                }
            }
        }
        Label {
            text: "Size"
        }
        RowLayout {
            SpinBox {
                id: dveXSize
                editable: true
                from: 0
                to: 3200
                wheelEnabled: true
                onValueModified: {
                    var v=value/100.0;
                    me.setUpstreamKeyDVESize(key, v, lockAspect ? v : me.upstreamKeyDVEYSize(key))
                    if (lockAspect.checked)
                        dveYSize.value=value
                }
            }

            CheckBox {
                id: lockAspect
                // text: "Lock"
                checked: true
            }

            Binding {
                target: dveYSize
                property: "value"
                value: dveXSize.value
                when: lockAspect.checked
            }

            SpinBox {
                id: dveYSize
                editable: true
                enabled: !lockAspect.checked
                from: 0
                to: 3200
                stepSize: 1
                wheelEnabled: true
                onValueModified: {
                    var v=value/100.0;
                    me.setUpstreamKeyDVESize(key, lockAspect ? v : me.upstreamKeyDVEXSize(key), v)
                    if (lockAspect.checked)
                        dveXSize.value=value
                }
            }

            Button {
                text: "100%"
                onClicked: dveXSize.value=100;
            }
            Button {
                text: "50%"
                onClicked: dveXSize.value=50;
            }
            Button {
                text: "25%"
                onClicked: dveXSize.value=25;
            }
            Button {
                text: "200%"
                onClicked: dveXSize.value=200;
            }
        }
        GridLayout {
            rows: 3
            columns: 2

            Button {
                text: "FS"
                Layout.fillWidth: true
                Layout.minimumWidth: 50
                onClicked: {
                    me.runUpstreamKeyTo(key, 3, 0)
                }
            }
            Button {
                text: "INF"
                Layout.fillWidth: true
                Layout.minimumWidth: 50
                onClicked: {
                    me.runUpstreamKeyTo(key, 4, 0) // center
                }
            }
            Button {
                text: "A"
                Layout.fillWidth: true
                Layout.minimumWidth: 50
                onClicked: {
                    me.runUpstreamKeyTo(key, 1, 0)
                }
            }
            Button {
                text: "B"
                Layout.fillWidth: true
                Layout.minimumWidth: 50
                onClicked: {
                    me.runUpstreamKeyTo(key, 2, 0)
                }
            }
            Button {
                text: "Animate"
                Layout.fillWidth: true
                Layout.minimumWidth: 100
                Layout.columnSpan: 2
                onClicked: {
                    me.setUpstreamKeyDVEKeyFrame(0, 2)
                }
            }
            DelayButton {
                text: "Set A"
                Layout.fillWidth: true
                Layout.minimumWidth: 50
                onActivated: {
                    me.setUpstreamKeyDVEKeyFrame(key, 1)
                    checked=false
                }
            }
            DelayButton {
                text: "Set B"
                Layout.fillWidth: true
                Layout.minimumWidth: 50
                onActivated: {
                    me.setUpstreamKeyDVEKeyFrame(key, 2)
                    checked=false
                }
            }
        }
    }
}
