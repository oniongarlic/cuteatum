import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.bm 1.0

Slider {
    id: control

    Layout.fillHeight: true
    Layout.maximumHeight: parent.height/2
    Layout.alignment: Qt.AlignHCenter

    required property AtemMixEffect me;

    property alias easingType: easingTransition.easing.type
    property alias easingDuration: easingTransition.duration

    enabled: !easingTransition.running

    orientation: Qt.Vertical
    to: 10000
    from: 0
    stepSize: 100
    handle: Rectangle {
        color: control.enabled ? "green" : "grey"
        border.color: "black"
        implicitHeight: 32
        implicitWidth: 80
        x: control.leftPadding + (control.horizontal ? control.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.visualPosition * (control.availableHeight - height))
        radius: 8
    }
    onValueChanged: {
        if (easingTransition.running) {
            me.setTransitionPosition(value);
            if (atem.macroRecording) {
                atem.addMacroPause(1)
            }
        }
    }
    onMoved: {
        me.setTransitionPosition(value);
    }
    onPressedChanged: {
        if (!pressed) {
            value=0;
            me.setTransitionPosition(0);
        }
    }

    function start() {
        easingTransition.start()
    }

    function stop() {
        easingTransition.stop()
    }

    PropertyAnimation {
        id: easingTransition
        duration: 2000
        easing.type: Easing.InCubic
        target: control
        property: "value"
        from: 0
        to: 10000
    }
}
