import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.4 as QtControls
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    property string currentPageId:  "";
    property bool showToolTip: false;
    property int triesLimit: 16;

    function get(addr, callback) { //i love programming in js without promises
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            callback(doc);
        };
        doc.open("GET", addr);
        doc.send();
    }

    function pickArticle(callback, errorCallback) {
        resetStatus();
        statusBusy.visible = true;
        get("https://" + wallpaper.configuration.LanguageCode + ".wikipedia.org/w/api.php?action=query&prop=extracts|imageinfo|pageimages&iiprop=url&piprop=original&generator=random&format=json&grnnamespace=0&exlimit=20",
            function(doc) {
                if(doc.readyState === XMLHttpRequest.DONE && doc.status === 200) {
                    try {
                        var json = JSON.parse(doc.responseText);
                        var pageData = json.query.pages[Object.keys(json.query.pages)[0]];
                        callback(pageData);
                    } catch(e) {
                        errorCallback(doc, e);
                    }
                } else if(doc.readyState === XMLHttpRequest.DONE && doc.status !== 200) {
                    errorCallback(doc);
                }
            }
        );
    }

    function setArticle(pageData, limit) {
        if(pageData.original !== undefined && wallpaper.configuration.ShowImage) {
            backgroundImage.source = pageData.original.source; //important note: svgs might not work
        } else if(pageData.original === undefined && wallpaper.configuration.ShowImage && ((limit > 0 || limit === undefined) && wallpaper.configuration.ForceImage)) {
            //too much convoluted logic, there has to be a bug somewhere there
            console.log("no image, trying another article. triesLeft:", limit === undefined ? triesLimit : limit);
            pickArticle(function(pageData) {
                setArticle(pageData, limit === undefined ? triesLimit : limit-1);
            }, handleConnectivityError);
            return;
        } else {
            backgroundImage.source = "";
        }

        title.text = pageData.title;
        mainText.text = pageData.extract.replace(/<p class="mw-empty-elt">\n<\/p>/g, ""); //bad idea
        currentPageId = pageData.pageid;
        mainTimer.restart(); //ok so there shouldn't be two pickArticle running at the same time now. i hope
        resetStatus();
    }

    function handleConnectivityError(doc, e) {
        if(e !== undefined) {
            console.log(typeof(e), e); //usually json parse error, might mean a network connectivity problem
            console.log(doc.responseText);
        } else {
            console.log("connectivity error", doc.statusText);
        }

        setWarning("Connectivity error");
        mainTimer.restart();
    }

    function resetStatus() {
        if(!wallpaper.configuration.ShowImage)
            statusBusy.visible = false;

        showToolTip = false;
        status.ToolTip.text = "";
        statusIcon.visible = false;
        statusIcon.source = "";
    }

    function setWarning(text) {
        statusBusy.visible = false;
        showToolTip = true;
        status.ToolTip.text = text;
        statusIcon.visible = true;
        statusIcon.source = "emblem-warning"
    }

    function action_next() {
        mainTimer.restart();
        pickArticle(setArticle, handleConnectivityError);
    }

    function action_copy_url() {
        var url = "https://" + wallpaper.configuration.LanguageCode + ".wikipedia.org/?curid=" + currentPageId;
        copyTextEdit.text = url;
        copyTextEdit.selectAll();
        copyTextEdit.copy(); //this is sketchy but *apparently* it works
    }

    Component.onCompleted: {
        pickArticle(setArticle, handleConnectivityError);
        wallpaper.setAction("next", "Next article", "arrow-right");
        wallpaper.setAction("copy_url", "Copy article url", "edit-copy");
    }

    Timer {
        id: mainTimer
        repeat: false
        interval: wallpaper.configuration.Interval * 1000
        onTriggered: {
            try {
                pickArticle(setArticle, handleConnectivityError);
            } catch(e) {
                console.log(typeof(e), e);
                mainTimer.restart(); //force restart if an unhandled error occurs
            }
        }
    }

    TextEdit {
        visible: false;
        id: copyTextEdit;
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
                    Layout.preferredHeight: title.contentHeight
                    height: title.contentHeight
                    id: titleBackground
                    anchors.bottom: wallpaper.configuration.BottomTitle && !wallpaper.configuration.ShowText ? parent.bottom : undefined
                    anchors.bottomMargin: wallpaper.configuration.BottomMargin
                    //^technically illegal & undefined behavior but i have no idea how to fix it
                    //but it works, so... or does it?
                }
                Text {
                    id: title
                    font.pointSize: wallpaper.configuration.TextSize*2
                    Layout.preferredWidth: parent.Layout.preferredWidth
                    wrapMode: Text.Wrap
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
                    text: qsTr("")
                    Layout.topMargin: -20
                    font.pointSize: wallpaper.configuration.TextSize
                    wrapMode: Text.Wrap
                    visible: wallpaper.configuration.ShowText
                    opacity: wallpaper.configuration.TextOpacity
                }
            }

            MouseArea {
                id: status
                width: 50
                height: 50

                hoverEnabled: true
                onHoveredChanged: {
                    ToolTip.visible = showToolTip && !ToolTip.visible
                }

                ToolTip.delay: 500

                anchors.bottom: parent.bottom
                anchors.left: column.right
                anchors.leftMargin: 10
                anchors.bottomMargin: wallpaper.configuration.BottomMargin

                z: 2 //not proud

                PlasmaCore.IconItem {
                    id: statusIcon

                    width: 50
                    height: 50
                    opacity: 0.5

                    anchors.centerIn: status
                    visible: false
                }

                BusyIndicator {
                    id: statusBusy

                    width: 50
                    height: 50
                    opacity: 0.5

                    anchors.centerIn: status
                    visible: true
                    background: Rectangle {
                        color: "#ffffff"
                        width: 50
                        height: 50
                    }
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
                    onProgressChanged: {
                        if(progress == 1) {
                            statusBusy.visible = false;
                        }
                    }
                }
            }
    }
}
