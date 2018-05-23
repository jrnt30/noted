package dynamo

import (
	"fmt"
	"os"

	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/jrnt30/noted/pkg/noted"
)

// EventChange is an override of the mapping
// to allow proper use of the UnmarshallMap
type EventChange struct {
	NewImage map[string]*dynamodb.AttributeValue `json:"NewImage"`
	// ... more fields if needed: https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_streams_GetRecords.html
}

// EventRecord is an override of the mapping
// to allow proper use of the UnmarshallMap
type EventRecord struct {
	Change    EventChange `json:"dynamodb"`
	EventName string      `json:"eventName"`
	EventID   string      `json:"eventID"`
	// ... more fields if needed: https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_streams_GetRecords.html
}

// Event is an override of the mapping
// to allow proper use of the UnmarshallMap
type Event struct {
	Records []EventRecord `json:"records"`
}

// UnmarshalLinks simply manages extracting and converting
// dynamo event records to noted.Link events
// NOTE: Custom deserialization due to the
// mismatch of the Go AWS Lambda event types (github.com/aws/aws-lambda-go/events)
// and github.com/aws/aws-sdk-go/service/dynamodb
func UnmarshalLinks(evn Event) []noted.Link {
	var links []noted.Link
	for _, rec := range evn.Records {
		link := noted.Link{}

		if err := dynamodbattribute.UnmarshalMap(rec.Change.NewImage, &link); err != nil {
			fmt.Fprintf(os.Stderr, "Error decoding link from Dynamo events: %+v", err)
			continue
		}

		links = append(links, link)
	}
	return links
}
