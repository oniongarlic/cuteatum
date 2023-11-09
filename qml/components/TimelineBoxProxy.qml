import QtQuick

QtObject {    
    property double x;
    property double y;
    property double s;
    property int frame: 0;
    property int box: 0;
    property var keyFrames: []

    signal newFrame(var v)

    function append(f) {
        //let v={ "f": Math.round(f), "x": x.toFixed(2), "y": y.toFixed(2), "s": s.toFixed(2) }
        let v={ "f": frame++, "x": x.toFixed(4), "y": y.toFixed(4), "s": s.toFixed(4) }
        keyFrames.push(v)
        newFrame(v)
    }

    function clear() {
        frame=0;
        keyFrames=[]
    }    
}
