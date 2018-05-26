package main

import (
	"github.com/aws/aws-lambda-go/lambda"

	"github.com/jrnt30/noted/pkg/dynamo"
)

var processor EsIndexer

func init() {
	processor = NewESIndexer()
}

func main() {
	lambda.Start(handleLinkIndexing)
}

func handleLinkIndexing(event dynamo.Event) error {
	if !processor.Enabled() {
		return nil
	}

	for _, rec := range dynamo.UnmarshalLinks(event) {
		processor.ProcessLink(&rec)
	}
	return nil
}
