package main

import (
	"github.com/apex/go-apex"
	"github.com/apex/go-apex/dynamo"

	"github.com/jrnt30/noted-apex/pkg/utils"
)

func main() {
	notifier := NewSlackNotifier()

	dynamo.HandleFunc(func(event *dynamo.Event, context *apex.Context) error {
		if !notifier.enabled {
			return nil
		}

		var errors error
		for _, link := range utils.UnmarshalLinks(event) {
			notifier.ProcessLink(&link)
		}

		return errors
	})
}
