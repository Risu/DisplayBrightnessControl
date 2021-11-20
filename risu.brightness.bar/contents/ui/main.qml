//contact: piotr4@gmail.com
//GPLv3
import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.6 as Controls1
import QtQuick.Window 2.0
import QtQuick.Dialogs 1.2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: main
    property var brigthnessMax : 0
    property Item seekbar
    property bool dimmed : false
    property var lastReal: -1

    Plasmoid.icon: {
        source: {
            if(plasmoid.configuration.slimIcon) plasmoid.Layout.maximumWidth = 20;
            return "lighttable"
        }
    }
    
    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
    Plasmoid.fullRepresentation: Item {
        id: popup
        width: 90
        height: (Screen.desktopAvailableHeight/2)
        GroupBox {
            anchors.fill: parent
            background: Rectangle {
                    y: bControl.topPadding - bControl.padding
                    width: parent.width
                    height: parent.height - bControl.topPadding + bControl.padding
                    color: "transparent"
                    border.color: "lightblue"
                    radius: 2
                }
            Text {
                anchors.centerIn: parent
                color: "lightblue"
                font.bold: true;
                text:"<<<>>>";
            }
            Controls1.Slider {
                id: bControl
                anchors.centerIn: parent
                height: parent.height;
                orientation: Qt.Vertical
                value: { if(!dimmed) {lastReal = powerMan.data["PowerDevil"]["Screen Brightness"]; return (lastReal - brigthnessMax); } else return (lastReal - brigthnessMax); }
                stepSize: 1
                minimumValue: -(brigthnessMax *2)
                maximumValue: 0
                wheelEnabled: false
                onPressedChanged:
                {
                    if(!pressed) {
                        cmd.exec("xrandr -q");
                        var realValue = (brigthnessMax +  bControl.value);
                        if(realValue >= 0) { 
                            dimmed = false;
                            if(realValue > plasmoid.configuration.limitBrightnessMax) realValue = plasmoid.configuration.limitBrightnessMax;
                            if(realValue < plasmoid.configuration.limitBrightnessMin) realValue = plasmoid.configuration.limitBrightnessMin;
                            cmd.exec("qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/BrightnessControl setBrightness "+realValue+";");
                            cmd.exec('xrandr --output "'+plasmoid.configuration.output+'" --brightness 1.0;');
                        } else{ 
                            var floatValue = -realValue;
                            var ranValue = floatValue / brigthnessMax;
                            ranValue = (1.000-ranValue).toFixed(3);
                            if(ranValue < plasmoid.configuration.limitDimness)  ranValue = plasmoid.configuration.limitDimness;
                            cmd.exec("qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/BrightnessControl setBrightness 1;");
                            cmd.exec('xrandr --output "'+plasmoid.configuration.output+'" --brightness '+ranValue+';');
                            dimmed = true;
                        }
                        lastReal = realValue;
                    }
                }

            }
        }
        Component.onCompleted: {
            if(seekbar == null) seekbar = bControl;
        }
    }

    Connections {
        target: cmd
        onExited: {
            if(exitCode == 0 && exitStatus == 0){
                if(stdout != null && stdout.length > 5){
                    if(stdout.substring(0, 6) === "Screen"){
                        for (const line of stdout.split('\n')) {
                            const pos = line.indexOf(" connected")
                            if (pos > -1) {
                                const output = line.substring(0, pos);
                                plasmoid.configuration.output = output;
                                break;
                            }
                        }
                    }
                }

            }
            if(stderr.indexOf("not found") > -1){
                if( exitCode == 1 && exitStatus == 0){
                    //warning: output ... not found; ignoring
                    //xrandr: Need crtc to set gamma on.
                }
                if( exitCode == 127 && exitStatus == 0) errorDialog.visible = true;
            }
        }
    }

    MessageDialog {
        id: errorDialog
        title: "Component is missing"
        text: "Components xrandr and qdbus are required. Please install the missing one in your package manager."
        icon: StandardIcon.Critical
        onAccepted: {
            console.log("onAccepted")
        }
    }

    Plasmoid.compactRepresentation: PlasmaCore.IconItem {
        source: Plasmoid.icon
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: {
                if (mouse.button === Qt.LeftButton) {
                    if (plasmoid.expanded) {
                        plasmoid.expanded = false;
                    } else {
                        if(powerMan.data["PowerDevil"] && powerMan.data["PowerDevil"]["Screen Brightness Available"]) {
                            var maxBr = (powerMan.data["PowerDevil"]["Maximum Screen Brightness"]);
                            if (maxBr > plasmoid.configuration.limitBrightnessMax) maxBr = plasmoid.configuration.limitBrightnessMax;
                            brigthnessMax = maxBr;
                            plasmoid.expanded = true;
                        }
                    }
                }
            }
        }
    }
    
    property QtObject powerMan: PlasmaCore.DataSource {
        id: powerMan
        engine: "powermanagement"
        connectedSources: sources
        onSourceAdded: {
            disconnectSource(source);
            connectSource(source);
        }
        onSourceRemoved: {
            disconnectSource(source);
        }
        onDataChanged: {
            if(seekbar != null) {
                if(powerMan.data["PowerDevil"] && powerMan.data["PowerDevil"]["Screen Brightness Available"]) {
                    var tmpBri = powerMan.data["PowerDevil"]["Screen Brightness"];
                    if (tmpBri > 1) {
                        lastReal = tmpBri;
                        seekbar.value = (lastReal - brigthnessMax);
                        if(dimmed) {
                            cmd.exec('xrandr --output "'+plasmoid.configuration.output+'" --brightness 1.0;');
                            dimmed = false;
                        }
                    }
                }
            }
        }

    }

    PlasmaCore.DataSource {
        id: cmd
        engine: "executable"
        connectedSources: []
        onNewData: {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(exitCode, exitStatus, stdout, stderr)
            disconnectSource(sourceName)
        }
        function exec(cmdstr) {
            connectSource(cmdstr)
        }
        signal exited(int exitCode, int exitStatus, string stdout, string stderr)
    }
    
    Plasmoid.toolTipSubText: {"Check settings for safe limits."}
    
}
