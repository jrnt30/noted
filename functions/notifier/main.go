package main

import (
	"github.com/aws/aws-lambda-go/lambda"

	"github.com/jrnt30/noted/pkg/dynamo"
)

var notifier SlackNotifier

func init() {
	notifier = NewSlackNotifier()
}

func main() {
	lambda.Start(handleDyanmoEvent)
}

func handleDyanmoEvent(e dynamo.Event) error {
	if !notifier.enabled {
		return nil
	}

	var errors error
	for _, link := range dynamo.UnmarshalLinks(e) {
		notifier.ProcessLink(&link)
	}

	return errors
}
