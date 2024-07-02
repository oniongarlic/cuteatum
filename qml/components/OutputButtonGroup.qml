import QtQuick
import QtQuick.Controls

ButtonGroup {
    id: outputSourceGroup
    property int activeSource: -1
    property int outputIndex: 0
    onActiveSourceChanged: {
        for (var i = 0; i < buttons.length; ++i) {
            if (buttons[i].inputID == activeSource)
                buttons[i].checked=true;
        }
    }
}
