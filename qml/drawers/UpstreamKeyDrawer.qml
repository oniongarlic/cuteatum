import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../models"

import org.bm 1.0

Drawer {
    id: uskDrawer
    width: parent.width/2
    height: root.height

    required property int key;
    required property AtemMixEffect me;    

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
                from: -2000
                to: 2000
                stepSize: 10
                wheelEnabled: true
                onValueModified: {
                    if (!enabled) return;
                    me.setUpstreamKeyDVEPosition(key, value/100.0, me.upstreamKeyDVEYPosition(0))
                }
            }

            SpinBox {
                id: dveYPos
                editable: true
                from: -2000
                to: 2000
                stepSize: 10
                wheelEnabled: true
                onValueModified: {
                    if (!enabled) return;
                    me.setUpstreamKeyDVEPosition(key, me.upstreamKeyDVEXPosition(0), value/100.0)
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
                to: 100
                wheelEnabled: true
                onValueModified: {
                    var v=value/100.0;
                    me.setUpstreamKeyDVESize(key, v, lockAspect ? v : me.upstreamKeyDVEYSize(0))
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
                to: 100
                wheelEnabled: true
                onValueModified: {
                    var v=value/100.0;
                    me.setUpstreamKeyDVESize(key, lockAspect ? v : me.upstreamKeyDVEXSize(0), v)
                    if (lockAspect.checked)
                        dveXSize.value=value
                }
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
