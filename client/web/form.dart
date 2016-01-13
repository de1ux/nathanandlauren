import "dart:html";
import 'package:react/react_client.dart' as reactClient;
import 'package:react/react.dart' as react;

void main() {
    reactClient.setClientConfiguration();
    var output = querySelector("#form");
    react.render(FancyForm({}), output);
}

var FancyForm = react.registerComponent(() => new _FancyForm());
class _FancyForm extends react.Component {

    String firstName;
    String lastName;
    int mealChoice;
    bool hasGuest;
    bool get attending => state['attending'];


    getInitialState() {
        return {
            "attending": false,
            "firstName": "",
            "lastName": "",
            "mealChoice": -1,
        };
    }

    onDecision(e) {
        String value = e.target.value;
        print("Got target ${e.target.value}");
        if (["yes", "no"].contains(value)) {
            // an attendance response!
            if (value == "yes") {
                setState({"attending": true});
            } else {
                setState({"attending": false});
            }
            return;
        } else {
            setState({"mealChoice": int.parse(e.target.value)});
        }
    }

    onSubmit(_) {
        print("DO SOMETHING");
    }

    getAttendanceQuestions() {
        if (!attending) {
            return [];
        }

        return [
            "Name*",
            react.br({}),
            react.input({
                "id": "first-name",
                "placeholder": "First",
            }),
            react.input({
                "id": "last-name",
                "placeholder": "Last",
            }),
            react.br({}),
            "Meal of choice",
            react.select({
                "onChange": onDecision
            }, [
                react.option({
                    "selected": true,
                    "disabled": true,
                }, "-Not selected-"),
                react.option({
                    "value": "1"
                }, "Chicken Breast"),
                react.option({
                    "value": "2"
                }, "Prime Rib"),
                react.option({
                    "value": "3"
                }, "Gnocchi")
            ]),
            react.br({}),
            "Additional guests and their meal of choice?",
            react.br({}),
            react.textarea({}),
            react.br({}),
            "Anything you want us to know? Dietary requirements? ",
            react.br({}),
            react.textarea({})
        ];
    }

    getSubmitButton() {
        return react.button(
            {
                "onClick": onSubmit,
            }, "Submit");
    }

    react.ReactElement render() {
        return react.div({}, [
            react.div({
                "className": "first-name"
            }, [
                "Attending?*",
                react.br({}),
                react.select({
                    "onChange": onDecision
                }, [
                    react.option({
                        "selected": true,
                        "disabled": true,
                    }, "-Not selected-"),
                    react.option({
                        "value": "yes"
                    }, "Yes, I'm attending"),
                    react.option({
                        "value": "no"
                    }, "No, I can't make it")
                ]),
                react.br({}),
            ]
                ..addAll(getAttendanceQuestions())
            ),
            getSubmitButton(),
            react.br({}),
            react.span({}, "* required")
        ]);
    }
}

