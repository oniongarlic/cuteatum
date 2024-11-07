import QtQuick

ListModel {
    id: ssModel
    ListElement {
        box: 1; src: 1000;
        dx: -0.25; dy: -0.25; ds: 0.5; onair: true;
        cx: -0.25; cy: -0.25; cs: 0.5;
        c: false; cLeft: 0; cRight: 0; cTop: 0; cBottom: 0;
        borderEnabled: false; borderColor: "#ffffff"
    }
    ListElement {
        box: 2; src: 1001;
        dx: 0.25; dy: -0.25; ds: 0.5; onair: true;
        cx: 0.25; cy: -0.25; cs: 0.5;
        c: false; cLeft: 0; cRight: 0; cTop: 0; cBottom: 0;
        borderEnabled: false; borderColor: "#ffffff"
    }
    ListElement {
        box: 3; src: 1002;
        dx: -0.25; dy: 0.25; ds: 0.5; onair: true;
        cx: -0.25; cy: 0.25; cs: 0.5;
        c: false; cLeft: 0; cRight: 0; cTop: 0; cBottom: 0;
        borderEnabled: false; borderColor: "#ffffff"
    }
    ListElement {
        box: 4; src: 1003;
        dx: 0.25; dy: 0.25; ds: 0.5; onair: true;
        cx: 0.25; cy: 0.25; cs: 0.5;
        c: false; cLeft: 0; cRight: 0; cTop: 0; cBottom: 0;
        borderEnabled: false; borderColor: "#ffffff"
    }

    function toJSONat(i) {
        var o=get(i);
        return JSON.stringify(o);
    }
    function toJSON() {
        let o=[];
        for (let i=0;i<4;i++) {
            o[i]=get(i)
        }
        return JSON.stringify(o)
    }
    function fromJSON(j) {
        let o=JSON.parse(j);
        for (let i=0;i<4;i++) {
            set(i, o)
        }
    }
}
