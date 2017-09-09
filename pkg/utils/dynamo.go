package utils

import (
	"fmt"
	"os"

	"github.com/apex/go-apex/dynamo"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"

	"github.com/jrnt30/noted-apex/pkg/noted"
)

func UnmarshalLinks(evn *dynamo.Event) []noted.Link {
	var links []noted.Link
	for _, rec := range evn.Records {
		link := noted.Link{}

		if err := dynamodbattribute.UnmarshalMap(rec.Dynamodb.NewImage, &link); err != nil {
			fmt.Fprintf(os.Stderr, "Error decoding link from Dynamo events: %+v", err)
			continue
		}

		links = append(links, link)
	}
	return links
}
