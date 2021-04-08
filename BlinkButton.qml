import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

Button {
    id: btn
    checkable: true

    Timer {
        interval: 100
        repeat: true
        onTriggered: {

        }
    }
}
