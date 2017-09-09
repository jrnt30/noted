package main

import (
	"fmt"
	"os"

	"github.com/apex/go-apex"
	"github.com/apex/go-apex/dynamo"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"

	"github.com/jrnt30/noted-apex/pkg/noted"
)

func main() {
	dynamo.HandleFunc(func(event *dynamo.Event, ctx *apex.Context) error {
		for _, rec := range event.Records {
			newLink := &noted.Link{}
			err := dynamodbattribute.UnmarshalMap(rec.Dynamodb.NewImage, newLink)
			if err != nil {
				fmt.Fprintf(os.Stderr, "Error decoding event from Dynamo stream: %+v", err)
				return err
			}

			fmt.Fprintf(os.Stderr, "Successfully decoded event from Dynamo: %+v", newLink)
		}
		return nil
	})
}
