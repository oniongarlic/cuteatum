import QtQuick

QtObject {    
    property double x;
    property double y;
    property double s;
    property bool cropEnabled: false;
    property int cropTop: 0;
    property int cropBottom: 0;
    property int cropLeft: 0;
    property int cropRight: 0;
    property int frame: 0;
    property int box: 0;
    property var keyFrames: [];

    signal newFrame(var v)
    signal updated()

    function setFrame(f) {
        updated()
    }

    function append(f) {
        //let v={ "f": Math.round(f), "x": x.toFixed(2), "y": y.toFixed(2), "s": s.toFixed(2) }
        let v={ "f": frame++,
            "x": x.toFixed(4),
            "y": y.toFixed(4),
            "s": s.toFixed(4),
            "c": cropEnabled,
            "cl": cropLeft,
            "cr": cropRight,
            "ct": cropTop,
            "cb": cropBottom }
        console.debug(v)
        keyFrames.push(v)
        newFrame(v)
    }

    function clear() {
        frame=0;
        keyFrames=[]
    }    
}
