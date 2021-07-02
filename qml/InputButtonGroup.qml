import QtQuick 2.12
import QtQuick.Controls 2.12

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
