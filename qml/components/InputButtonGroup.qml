import QtQuick
import QtQuick.Controls

ButtonGroup {
    id: programGroup
    property int activeInput: meCon.program;    
    onActiveInputChanged: {
        for (var i = 0; i < buttons.length; ++i) {
            if (buttons[i].inputID == activeInput)
                buttons[i].checked=true;
        }
    }
}
