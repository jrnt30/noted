package main

import (
	"github.com/aws/aws-lambda-go/lambda"

	"github.com/jrnt30/noted-apex/pkg/dynamo"
)

var notifier SlackNotifier

func init() {
	notifier = NewSlackNotifier()
}

func main() {
	lambda.Start(handleDyanmoEvent)
}

func handleDyanmoEvent(e dynamo.DynamoEvent) error {
	if !notifier.enabled {
		return nil
	}

	var errors error
	for _, link := range dynamo.UnmarshalLinks(e) {
		notifier.ProcessLink(&link)
	}

	return errors
}
