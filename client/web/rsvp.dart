import "dart:html";
import 'dart:convert';
import 'package:react/react_client.dart' as reactClient;
import 'package:react/react.dart' as react;

var backendURL = "http://sv.nathanandlauren.com:9090";

void main() {
    reactClient.setClientConfiguration();
    var output = querySelector("#form");
    react.render(FancyForm({}), output);
}

var FancyForm = react.registerComponent(() => new _FancyForm());
class _FancyForm extends react.Component {

    bool get attending => state['attending'];
    String get firstName => state['firstName'];
    String get lastName => state['lastName'];
    int get mealChoice => state['mealChoice'];
    String get guestInfo => state['guestInfo'];
    String get additionalInfo => state['additionalInfo'];
    bool get valid => state['valid'];
    String get error => state['error'];

    getInitialState() {
        return {
            "attending": null,
            "firstName": "",
            "lastName": "",
            "mealChoice": -1,
            "guestInfo": "",
            "additionalInfo": "",
            "valid": false,
            "error": "",
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
        var form = {
            "attending": attending,
            "firstName": querySelector("#first-name").value,
            "lastName": querySelector("#last-name").value,
        };

        if (attending) {
            form.addAll({
                "mealChoice": int.parse(querySelector("#meal-choice").value),
                "guestInfo": querySelector("#guest-info").value,
                "additionalInfo": querySelector("#additional-info").value,
            });
        } else {
            form['mealChoice'] = -1;
        }

        String errMsg = validate(form);
        if (errMsg == "") {
            postForm(form);
            form['valid'] = true;
        } else {
            form['error'] = errMsg;
        }

        setState(form);
    }

    String validate(Map form) {
        if (form['firstName'] == "") {
            return "Missing first name";
        }
        if (form['lastName'] == "") {
            return "Missing last name";
        }
        if (form['attending'] == null) {
            return "Please select yes/no if you're attending";
        }
        if (form['mealChoice'] == -1 && form['attending']) {
            return "Please select a meal choice";
        }
        return "";
    }

    void postForm(Map form) {
        HttpRequest request = new HttpRequest();
        var url = "${backendURL}/response";
        request.open("POST", url);
        String jsonData = JSON.encode(form);
        request.send(jsonData);
    }

    getAttendanceQuestions() {
        if (attending == null || !attending) {
            return [];
        }

        return [
            react.br({}),
            "Meal of choice: ",
            react.select({
                "id": "meal-choice",
                "onChange": onDecision
            }, [
                react.option({
                    "selected": true,
                    "disabled": true,
                    "value": -1
                }, "-Not selected-"),
                react.option({
                    "value": "0"
                }, "Chicken Breast"),
                react.option({
                    "value": "1"
                }, "Prime Rib"),
                react.option({
                    "value": "2"
                }, "Gnocchi (GF, vegetarian)")
            ]),
            react.span({"className": "required"}, ["*"]),
            react.br({}),
            react.br({}),
            "Additional guests and their meal of choice?",
            react.br({}),
            react.textarea({
                "rows": 8,
                "cols": 100,
                "id": "guest-info",
            }),
            react.br({}),
            react.br({}),
            "Anything you want us to know? Dietary requirements, etc.",
            react.br({}),
            react.textarea({
                "rows": 8,
                "cols": 100,
                "id": "additional-info",
            }),
            react.br({}),
        ];
    }

    getSubmitButton() {
        return react.button(
            {
                "onClick": onSubmit,
                "className": "submit-button"
            }, "Submit");
    }

    render() {
        if (valid) {
            return react.span(
                {"className": "submitted"},
                ["Submitted! Thanks for responding."]
            );
        }

        var errorMsg;
        if (errorMsg != "") {
            errorMsg = react.span({
                "className": "error-message",
            }, [error, react.br({}), react.br({})]);
        }

        return react.div({}, [
            react.div({
            }, [
                "Name",
                react.span({"className": "required"}, ["*"]),
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
                react.br({}),
                "Attending?",
                react.span({"className": "required"}, ["*"]),
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
            react.br({}),
            errorMsg,
            getSubmitButton(),
            react.br({}),
            react.br({}),
            react.span({"className": "required"}, ["*"]),
            react.span({}, " required")
        ]);
    }
}

