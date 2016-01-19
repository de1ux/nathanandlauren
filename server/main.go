package main

import (
    "github.com/mailgun/mailgun-go"
    "github.com/rs/cors"
    "github.com/gorilla/mux"
    "net/http"
    "fmt"
    "io/ioutil"
    "log"
    "encoding/json"
)

type WeddingResponse struct {
    FirstName string `json:"firstName"`
    LastName string `json:"lastName"`
    Attending bool `json:"attending"`
    Meal int `json:"mealChoice,omitempty"`
    GuestInfoBlob string `json:"guestInfo,omitempty"`
    AdditionalInfoBlob string `json:"additionalInfo,omitempty"`
}

func (w *WeddingResponse) ToEmail() string {
    meal := ""
    if w.Meal == 0 {
        meal = "chicken"
    } else if w.Meal == 1 {
        meal = "beef"
    } else if w.Meal == 2 {
        meal = "gnocchi"
    } else {
        meal = "other"
    }

    return fmt.Sprintf("Name: %s %s\n Attending: %t\n Meal: %s\n Guest info:\n %s\n Additional info:\n %s\n",
        w.FirstName, w.LastName,
        w.Attending,
        meal,
        w.GuestInfoBlob,
        w.AdditionalInfoBlob)
}

func main() {
    r := mux.NewRouter()
    r.HandleFunc("/response", responseHandler).Methods("POST")
    http.Handle("/", r)
    log.Print("Running!")

    c := cors.New(cors.Options{
        AllowCredentials: true,
    })

    router := c.Handler(r)
    log.Fatal(http.ListenAndServe(":9090", router))
}

func responseHandler(w http.ResponseWriter, r *http.Request) {
    weddingResponse := &WeddingResponse{}
    bytes, err := ioutil.ReadAll(r.Body)
    if err != nil {
        log.Printf("Failed to read body (%s): %v", r.Body, err)
    }

    if err = json.Unmarshal(bytes, weddingResponse); err != nil {
        log.Printf("Failed to umarshal body (%s): %v", string(bytes), err)
    }

    sendEmail(weddingResponse)
}

func sendEmail(w *WeddingResponse) {
    body := w.ToEmail()

    gun := mailgun.NewMailgun(mailgun_domain, mailgun_priv_key, mailgun_pub_key)
    m := mailgun.NewMessage(
        fmt.Sprintf("Sender <mailgun@%s>", mailgun_domain),
        "New Registration on nathanandlauren.com",
        body,
        nathan, lauren,

    )

    response, id, err := gun.Send(m)
    if err != nil {
        log.Printf("Failed to mail gun: %v", err)
    }
    log.Printf("Response ID: %s", id)
    log.Printf("Message from server: %s", response)
    log.Printf("Body: %s", body)
}

