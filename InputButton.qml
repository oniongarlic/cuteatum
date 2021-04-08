import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

Button {
    id: btn
    autoExclusive: true
    checkable: true

    property int inputID: 0

    onCheckedChanged: console.debug("ABC"+checked)

}
