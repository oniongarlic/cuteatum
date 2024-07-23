import QtQuick

ParallelAnimation {
    id: v4
    property double x;
    property double y;
    property double z;
    property double w;

    property vector4d from;
    property vector4d to;

    readonly property vector4d value: Qt.vector4d(x,y,z,w)

    property int duration: 1000;
    property int easing: Easing.InOutCubic;

    PropertyAnimation { target: v4; property: "x"; from: v4.from.x; to: v4.to.x; duration: v4.duration; easing.type: v4.easing;}
    PropertyAnimation { target: v4; property: "y"; from: v4.from.y; to: v4.to.y; duration: v4.duration; easing.type: v4.easing;}
    PropertyAnimation { target: v4; property: "z"; from: v4.from.z; to: v4.to.z; duration: v4.duration; easing.type: v4.easing;}
    PropertyAnimation { target: v4; property: "w"; from: v4.from.w; to: v4.to.w; duration: v4.duration; easing.type: v4.easing;}
}
