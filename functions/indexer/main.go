package main

import (
	"github.com/apex/go-apex"
	"github.com/apex/go-apex/dynamo"

	"github.com/jrnt30/noted-apex/pkg/utils"
)

func main() {
	processor := NewESIndexer()
	dynamo.HandleFunc(func(event *dynamo.Event, ctx *apex.Context) error {
		if !processor.Enabled() {
			return nil
		}

		for _, rec := range utils.UnmarshalLinks(event) {
			processor.ProcessLink(&rec)
		}
		return nil
	})
}
