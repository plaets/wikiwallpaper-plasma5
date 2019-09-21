import QtQuick 2.0
import QtQuick.Controls 1.4 as QtControls
import QtQuick.Layouts 1.11
import QtQuick.Dialogs 1.3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrols 2.0 as KQuickControls

Column {
    id: root
    property alias cfg_Interval: intervalText.text
    property string cfg_LanguageCode
    property alias cfg_TextMargin: textMargin.text
    property alias cfg_BackgroundColor: backgroundColorButton.color
    property alias cfg_TextColor: textColorButton.color
    property alias cfg_BackgroundOpacity: backgroundOpacitySlider.value
    property alias cfg_TextSize: textSize.text
    property alias cfg_TextOpacity: textOpacitySlider.value
    property bool cfg_ShowText
    property bool cfg_ShowImage
    property alias cfg_ForceImage: forceImage.checked
    property alias cfg_ShowTitle: showTitle.checked
    property alias cfg_CenterTitle: centerTitle.checked
    property alias cfg_BottomTitle: bottomTitle.checked
    property alias cfg_TitleBackground: titleBackground.checked
    property alias cfg_CropAndFillImage: cropAndFillImage.checked

    function updateMode() {
        cfg_ShowText = modeImageAndText.checked || modeText.checked;
        cfg_ShowImage = modeImageAndText.checked || modeImage.checked;
    }

    function get(addr, callback) { //code duplication?????
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            callback(doc);
        };
        doc.open("GET", addr);
        doc.send();
    }

    Component.onCompleted: {
        get("https://commons.wikimedia.org/w/api.php?action=sitematrix&smtype=language&format=json", function(doc) {
            if(doc.readyState === XMLHttpRequest.DONE) {
                var json = JSON.parse(doc.responseText);
                Object.keys(json.sitematrix).forEach(function(key){
                    if(key !== "count" && json.sitematrix[key].code !== "en") { //if i don't add something to the combobox immediately, i will just get empty names, idk why
                        langs.append({ text: json.sitematrix[key].code }); //i could have the name of the lanugage set as the text but for some reason (problably encoding) it breaks scrolling
                    }
                });
            }
        });

        langs.append({text: "en"});
    }

    QtControls.ScrollView {
        height: parent.height
        width: parent.width
        GridLayout {
            columns: 2

            QtControls.GroupBox {
                title: "Mode"
                Layout.fillWidth: parent
                ColumnLayout {
                    QtControls.ExclusiveGroup { id: modeGroup }
                    QtControls.RadioButton {
                        id: modeImageAndText
                        text: "Image and Text"
                        exclusiveGroup: modeGroup
                        onCheckedChanged: updateMode()
                        checked: (cfg_ShowImage && cfg_ShowText)
                    }
                    QtControls.RadioButton {
                        id: modeText
                        text: "Text only"
                        exclusiveGroup: modeGroup
                        onCheckedChanged: updateMode()
                        checked: (cfg_ShowText && !cfg_ShowImage)
                    }
                    QtControls.RadioButton {
                        id: modeImage
                        text: "Image only"
                        exclusiveGroup: modeGroup
                        onCheckedChanged: updateMode()
                        checked: (!cfg_ShowText && cfg_ShowImage)
                    }
                }
            }
            QtControls.GroupBox {
                title: "Mode settings"
                Layout.fillWidth: parent
                Layout.fillHeight: parent

                GridLayout {
                    columns: 2
                    QtControls.Label {
                        width: formAlignment - units.largeSpacing
                        horizontalAlignment: Text.AlignLeft
                        text: "Pick only articles with an image: "
                        visible: modeImageAndText.checked
                    }
                    QtControls.CheckBox {
                        id: forceImage
                        visible: modeImageAndText.checked
                    }

                    QtControls.Label {
                        width: formAlignment - units.largeSpacing
                        horizontalAlignment: Text.AlignLeft
                        text: "Show title of the article: "
                        visible: modeImage.checked
                    }
                    QtControls.CheckBox {
                        id: showTitle
                        visible: modeImage.checked
                    }
                    QtControls.Label {
                        width: formAlignment - units.largeSpacing
                        horizontalAlignment: Text.AlignLeft
                        text: "Move the title to the bottom: "
                        visible: modeImage.checked
                    }
                    QtControls.CheckBox {
                        id: bottomTitle
                        visible: modeImage.checked
                    }
                    QtControls.Label {
                        width: formAlignment - units.largeSpacing
                        horizontalAlignment: Text.AlignLeft
                        text: "Add background only to the title: "
                        visible: modeImage.checked
                    }
                    QtControls.CheckBox {
                        id: titleBackground
                        visible: modeImage.checked
                    }

                    QtControls.Label {
                        width: formAlignment - units.largeSpacing
                        horizontalAlignment: Text.AlignLeft
                        text: "Crop the image to fill the screen: "
                        visible: modeImage.checked || modeImageAndText.checked
                    }
                    QtControls.CheckBox {
                        id: cropAndFillImage
                        visible: modeImage.checked || modeImageAndText.checked
                    }
                }
            }

            QtControls.Label {
                width: formAlignment - units.largeSpacing
                horizontalAlignment: Text.AlignLeft
                text: "Update interval (seconds): "
            }
            QtControls.TextField {
                id: intervalText
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                validator: IntValidator{bottom: 1}
            }

            QtControls.Label {
                width: formAlignment - units.largeSpacing
                horizontalAlignment: Text.AlignLeft
                text: "Language code: "
            }
            //QtControls.TextField {
            //    id: languageCode
            //    validator: RegExpValidator{ regExp: /[a-z]{2}/ }
            //}
            QtControls.ComboBox {
                id: langsCombo
                model: ListModel {
                    id: langs
                }
                onCurrentIndexChanged: function() {
                    cfg_LanguageCode = langs.get(langsCombo.currentIndex).text
                }
            }

            QtControls.Label {
                width: formAlignment - units.largeSpacing
                horizontalAlignment: Text.AlignLeft
                text: "Background color: "
            }
            KQuickControls.ColorButton {
                id: backgroundColorButton
                dialogTitle: i18nd("plasma_wallpaper_org.kde.color", "Select background color")
            }

            QtControls.Label {
                width: formAlignment - units.largeSpacing
                horizontalAlignment: Text.AlignLeft
                text: "Background opacity: "
            }
            QtControls.Slider {
                id: backgroundOpacitySlider
                minimumValue: 0
                maximumValue: 1
                stepSize: 0.05
            }

            QtControls.Label {
                width: formAlignment - units.largeSpacing
                horizontalAlignment: Text.AlignLeft
                text: "Text color: "
            }
            KQuickControls.ColorButton {
                id: textColorButton
                dialogTitle: i18nd("plasma_wallpaper_org.kde.color", "Select text color")
            }

            QtControls.Label {
                width: formAlignment - units.largeSpacing
                horizontalAlignment: Text.AlignLeft
                text: "Text opacity: "
            }
            QtControls.Slider {
                id: textOpacitySlider
                minimumValue: 0
                maximumValue: 1
                stepSize: 0.05
            }

            QtControls.Label {
                width: formAlignment - units.largeSpacing
                horizontalAlignment: Text.AlignLeft
                text: "Text size: "
            }
            QtControls.TextField {
                id: textSize
                validator: IntValidator{ bottom: 5; top: 60 }
            }

            QtControls.Label {
                width: formAlignment - units.largeSpacing
                horizontalAlignment: Text.AlignLeft
                text: "Text margin: "
            }
            QtControls.TextField {
                id: textMargin
                validator: IntValidator{ bottom: 1; top: 1000 }
            }

            QtControls.Label {
                width: formAlignment - units.largeSpacing
                horizontalAlignment: Text.AlignLeft
                text: "Center the title: "
            }
            QtControls.CheckBox{
                id: centerTitle
            }

            //QtControls.Label {
            //    width: formAlignment - units.largeSpacing
            //    horizontalAlignment: Text.AlignLeft
            //    text: "Font: "
            //}
            //QtControls.Button {
            //    id: fontButton
            //    text: fontDialog.font
            //    onClicked: {
            //        fontDialog.visible = true;
            //    }
            //}

            //FontDialog {
            //    id: fontDialog
            //    title: "Please choose a font"
            //    font: Text.font
            //    onAccepted: {
            //        Qt.quit()
            //    }
            //    onRejected: {
            //        Qt.quit()
            //    }
            //    Component.onCompleted: visible = false
            //}
        }
    }
}
