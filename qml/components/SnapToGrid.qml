import QtQuick

QtObject {
    property double input;
    readonly property double output: snapToGrid(input*scale)/scale;
    property double size: 10
    property double scale: 1000

    onInputChanged: console.debug("SnapIn", input, input*scale, snapToGrid(input*scale)/scale)
    onOutputChanged: console.debug("SnapOut", output)

    function snapToGrid(i) {
        return Math.round(i / size) * size;
    }
}
