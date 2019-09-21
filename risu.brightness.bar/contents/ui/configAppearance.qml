//contact: piotr4@gmail.com
//GPLv3
import QtQuick 2.5
import QtQuick.Controls 1.4 as Controls1
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.2

Item {
    id: settings
    signal configurationChanged

    function saveConfig() {
        plasmoid.configuration.limitBrightnessMax = limitBrightnessMaxConfig.value
        plasmoid.configuration.limitBrightnessMin = limitBrightnessMinConfig.value
        plasmoid.configuration.limitDimness = limitDimnessConfig.value
        plasmoid.configuration.slimIcon = slimIconConfig.checked;
    }

    ColumnLayout {

        id: layout
        spacing: 20
        x: 5

        GroupBox {
            title:  "Safe limits:"
            font.underline: true
            Layout.fillWidth: true

            ColumnLayout {

                RowLayout {    //limitBrightnessMax

                    spacing: 20
                    Label {
                        text: "Limit maximal brigthness:"
                    }
                    
                    Item {
                         Layout.fillWidth: true
                    }
                    
                    Controls1.SpinBox {
                        id: limitBrightnessMaxConfig
                        value: plasmoid.configuration.limitBrightnessMax
                        minimumValue: 2
                        maximumValue: 9999
                        stepSize: 1
                        implicitWidth: 80
                    }
                }

                RowLayout {  //limitBrightnessMin


                    spacing: 20
                    Label {
                        text: "Limit minimal brigthness:"
                    }
                    
                    Item {
                         Layout.fillWidth: true
                    }
                    
                    Controls1.SpinBox {
                        id: limitBrightnessMinConfig
                        value: plasmoid.configuration.limitBrightnessMin
                        minimumValue: 1
                        maximumValue: 9998
                        stepSize: 1
                        implicitWidth: 80
                    }
                }

                RowLayout {  //limitDimness

                    spacing: 20

                    Label {
                        text: "Limit minimal dimness:"
                    }
                    
                    Item {
                         Layout.fillWidth: true
                    }
                    
                    Controls1.SpinBox {
                        id: limitDimnessConfig
                        value: plasmoid.configuration.limitDimness
                        minimumValue: 0.1
                        maximumValue: 1.0
                        stepSize: 0.1
                        implicitWidth: 80
                        decimals: 3
                    }

                }

            }
        }
        
        CheckBox {
            id: slimIconConfig
            text: "Slim icon (restart required)"
            checked: plasmoid.configuration.slimIcon
        }
        
    }
}
