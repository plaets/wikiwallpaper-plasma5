import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.4 as QtControls

Item {
    function get(addr, callback) { //i love programming in js without promises
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            callback(doc);
        };
        doc.open("GET", addr);
        doc.send();
    }

    function pickArticle(callback) {
        get("https://" + wallpaper.configuration.LanguageCode + ".wikipedia.org/w/api.php?action=query&prop=extracts|imageinfo|pageimages&iiprop=url&piprop=original&generator=random&format=json&grnnamespace=0&exlimit=20",
            function(doc) {
                if(doc.readyState === XMLHttpRequest.DONE) {
                    try {
                        var json = JSON.parse(doc.responseText);
                        var pageData = json.query.pages[Object.keys(json.query.pages)[0]];
                        callback(pageData);
                    } catch(e) {
                        console.log(typeof(e), e); //usually json parse error, might mean a network connectivity problem
                        console.log(doc.responseText);
                        mainTimer.restart(); //try again in some time
                        //another timer just for restarts with a diffrent interval would be cool here
                    }
                }
            }
        );
    }

    function setArticle(pageData, limit) {
        if(pageData.original !== undefined && wallpaper.configuration.ShowImage) {
            backgroundImage.source = pageData.original.source; //important note: svgs might not work
        } else if(pageData.original === undefined && wallpaper.configuration.ShowImage && ((!wallpaper.configuration.ShowText && (limit > 0 || limit === undefined)) || wallpaper.configuration.ForceImage)) {
            //too much convoluted logic, there has to be a bug somewhere there
            console.log("no image, trying another article. triesLeft:", limit === undefined ? 5 : limit);
            pickArticle(function(pageData) {
                setArticle(pageData, limit === undefined ? 5 : limit-1);
            });
            return;
        } else {
            backgroundImage.source = "";
        }

        title.text = pageData.title;
        mainText.text = pageData.extract;
        mainTimer.restart(); //ok so there shouldn't be two pickArticle running at the same time now. i hope
    }

    Component.onCompleted: {
        pickArticle(setArticle);
        mainTimer.restart();
    }

    Timer {
        id: mainTimer
        repeat: false
        interval: wallpaper.configuration.Interval * 1000
        onTriggered: {
            try {
                pickArticle(setArticle);
            } catch(e) {
                console.log(typeof(e), e);
                mainTimer.restart(); //force restart if an unhandled error occurs
            }
        }
    }

    Control {
        anchors.fill: parent
        Layout.fillHeight: true
        contentItem: Control {
        id: control
        Layout.fillHeight: true
            ColumnLayout {
                id: column
                Layout.preferredWidth: parent.width-(wallpaper.configuration.TextMargin*2)
                anchors.horizontalCenter: parent.horizontalCenter
                height: wallpaper.configuration.BottomTitle && !wallpaper.configuration.ShowText ? parent.height : undefined //ikr?
                Rectangle {
                    opacity: (wallpaper.configuration.TitleBackground && wallpaper.configuration.ShowTitle) && !wallpaper.configuration.ShowText ? wallpaper.configuration.BackgroundOpacity : 0
                    color: wallpaper.configuration.BackgroundColor
                    Layout.preferredWidth: title.width
                    height: title.height
                    id: titleBackground
                    anchors.bottom: wallpaper.configuration.BottomTitle && !wallpaper.configuration.ShowText ? parent.bottom : undefined
                    //^technically illegal & undefined behavior but i have no idea how to fix it
                    //but it works, so... or does it?
                }
                Text {
                    id: title
                    text: qsTr("")
                    font.pointSize: wallpaper.configuration.TextSize*2
                    Layout.preferredWidth: parent.Layout.preferredWidth
                    wrapMode: Text.WordWrap
                    color: wallpaper.configuration.TextColor
                    visible: wallpaper.configuration.ShowText || (wallpaper.configuration.ShowTitle && wallpaper.configuration.ShowImage && !wallpaper.configuration.ShowText) //overengineered wikipedia wallpaper
                    horizontalAlignment: wallpaper.configuration.CenterTitle ? Text.AlignHCenter : Text.AlignLeft
                    anchors.centerIn: titleBackground
                    opacity: wallpaper.configuration.TextOpacity
                }
                Text {
                    color: wallpaper.configuration.TextColor
                    Layout.preferredWidth: parent.Layout.preferredWidth
                    id: mainText
                    anchors.top: title.bottom
                    anchors.margins: { top: 20 }
                    text: qsTr("")
                    font.pointSize: wallpaper.configuration.TextSize
                    wrapMode: Text.WordWrap
                    visible: wallpaper.configuration.ShowText
                    opacity: wallpaper.configuration.TextOpacity
                }
            }
        }

        background:
            Rectangle {
                id: backgroundRectangle
                anchors.fill: parent
                color: wallpaper.configuration.BackgroundColor
                opacity: wallpaper.configuration.TitleBackground && !wallpaper.configuration.ShowText ? 1 : wallpaper.configuration.BackgroundOpacity
                Image {
                    id: backgroundImage
                    visible: wallpaper.configuration.ShowImage
                    anchors.fill: parent
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.centerIn: backgroundRectangle
                    fillMode: wallpaper.configuration.CropAndFillImage ? Image.PreserveAspectCrop : Image.PreserveAspectFit
                }
            }
    }
}
