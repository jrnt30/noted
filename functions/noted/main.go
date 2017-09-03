package main

import (
	"fmt"
	"github.com/mitchellh/packer/common/json"
	"io/ioutil"
	"net/http"
	"os"
	"github.com/apex/go-apex"
	"github.com/apex/go-apex/proxy"
)

type Link struct {
	ID          int    `json:"id"`
	URL         string `json:"url"`
	Title       string `json:"user_title"`
	Description string `json:"user_description"`
}

type User struct {
	ID          int    `json:"id"`
	Name		string `json:"user_name"`
	Token		string `json:"token"`
}

func main() {
	srv := http.NewServeMux()
	srv.HandleFunc("/", http.NotFound)
	srv.HandleFunc("/links", func(w http.ResponseWriter, r *http.Request) {
		switch r.Method {
		case http.MethodPost:
			postLink(w,r)
		default:
			http.NotFound(w,r)
		}
	})

	apex.Handle(proxy.Serve(srv))
}

func postLink(w http.ResponseWriter, r *http.Request) {
	body, err := ioutil.ReadAll(r.Body)
	defer r.Body.Close()
	if err != nil {
		http.Error(w, "Unable to read body", http.StatusInternalServerError)
		return
	}

	link := Link{}
	err = json.Unmarshal(body, &link)
	if err != nil {
		fmt.Fprintf(os.Stderr, err.Error())
		http.Error(w, fmt.Sprintf("Unable to unmarshall respose properly: %v", body), http.StatusInternalServerError)
	}

	// TODO Actually handle response
	w.Write([]byte("Jump in, the water is warm"))
}
