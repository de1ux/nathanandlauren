import "package:react/react.dart" as react;
import "package:react/react_client.dart";
import "dart:html";

int pictureCount = 5;
List<String> descriptions = [
    "Nathan, Lauren, Siri and Lena",
    "Nathan and Lauren in the meadows",
    "Nathan and Lauren by a babbling brook",
    "December 26th, 2014 - the night of our engagement!",
    "Collecting the first christmas tree in 2013",
];

class _FancyImagePicker extends react.Component {

    int get imageIndex => state["imageIndex"];
    String get imageDescription => state["imageDescription"];

    getInitialState() {
        return {
            "imageIndex": 0,
            "imageDescription": descriptions[0]
        };
    }

    List getImageThumbnails() {
        List thumbnails = new List();
        for (var i = 0; i < pictureCount; i++) {
            thumbnails.add(
                react.img({
                    "src": "images/thumb/${i}.jpg", "className": "thumbnail",
                    "onClick": selectImage,
                    "id": "${i}"
                })
            );
        }
        return thumbnails;
    }

    void selectImage(e) {
        int i = int.parse(e.target.id);
        setState({
            "imageIndex": i,
            "imageDescription": descriptions[i]
        });
    }

    render() {
        // Thumbnails that allow changing the image in the viewport
        var thumbs = getImageThumbnails();

        return react.div({}, [
            react.div({
                "className": "image-sidebar"
            }, thumbs),
            react.img({
                "src": "images/full/${imageIndex}.jpg", "className": "media"
            }),
            react.div({
                "className": "description-text"
            }, imageDescription)
        ]);
    }
}

var FancyImagePicker = react.registerComponent(() => new _FancyImagePicker());

void main() {
    setClientConfiguration();
    react.render(FancyImagePicker({}), querySelector("#fancy-image-picker"));
}
