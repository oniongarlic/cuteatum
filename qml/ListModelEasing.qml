import QtQuick 2.12

ListModel {
    ListElement { easingType: Easing.Linear; text: "Linear" }
    ListElement { easingType: Easing.InQuad; text: "InQuad" }
    ListElement { easingType: Easing.OutQuad; text: "OutQuad" }
    ListElement { easingType: Easing.InOutQuad; text: "InOutQuad" }
    ListElement { easingType: Easing.OutInQuad; text: "OutInQuad" }
    ListElement { easingType: Easing.InCubic; text: "InCubic" }
    ListElement { easingType: Easing.OutCubic; text: "OutCubic" }
    ListElement { easingType: Easing.InOutCubic; text: "InOutCubic" }
    ListElement { easingType: Easing.OutInCubic; text: "OutInCubic" }
    ListElement { easingType: Easing.InBounce; text: "InBounce" }
    ListElement { easingType: Easing.OutBounce; text: "OutBounce" }
    ListElement { easingType: Easing.InOutBounce; text: "InOutBounce" }
    ListElement { easingType: Easing.InSine; text: "InSine" }
    ListElement { easingType: Easing.OutSine; text: "OutSine" }
}
