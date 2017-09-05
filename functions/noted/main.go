package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"time"

	"github.com/apex/go-apex"
	"github.com/apex/go-apex/proxy"
)

type Link struct {
	ID          string    `json:"id" dynamodbav:"ID"`
	URL         string    `json:"url" dynamodbav:"URL"`
	CreatedBy   string    `json:"user_id" dynamodbav:"CreatedBy"`
	Title       string    `json:"user_title" dynamodbav:"Title"`
	Description string    `json:"user_description" dynamodbav:"Description"`
	CreatedAt   time.Time `json:"created_at" dynamodbav:"CreatedAt"`
	UpdatedAt   time.Time `json:"updated_at" dynamodbav:"UpdatedAt"`
	DeletedAt   time.Time `json:"deleted_at" dynamodbav:"DeletedAt"`
}

type User struct {
	ID    int    `json:"id"`
	Name  string `json:"user_name"`
	Token string `json:"token"`
}

func main() {
	ls, err := NewDynamoLinkSaver()
	if err != nil {
		panic(err)
	}

	srv := http.NewServeMux()
	srv.HandleFunc("/", http.NotFound)
	srv.HandleFunc("/links", func(w http.ResponseWriter, r *http.Request) {
		switch r.Method {
		case http.MethodPost:
			postLink(ls, w, r)
		default:
			http.NotFound(w, r)
		}
	})

	apex.Handle(proxy.Serve(srv))
}

func postLink(ls LinkSaver, w http.ResponseWriter, r *http.Request) {
	body, err := ioutil.ReadAll(r.Body)
	defer r.Body.Close()
	if err != nil {
		http.Error(w, "Unable to read body", http.StatusBadRequest)
		return
	}

	link := &Link{}
	err = json.Unmarshal(body, link)
	if err != nil {
		fmt.Fprintf(os.Stderr, err.Error())
		http.Error(w, fmt.Sprintf("Unable to unmarshall respose properly: %v", body), http.StatusBadRequest)
	}

	err = ls.SaveLink(link)
	if err != nil {
		fmt.Fprintf(os.Stderr, err.Error())
		http.Error(w, fmt.Sprint("Error persisting link"), http.StatusInternalServerError)
	}

	res, _ := json.Marshal(link)
	w.Header().Set("Content-Type", "application/json")
	w.Write(res)
}
