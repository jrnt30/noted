package main

import (
	"fmt"
	"os"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/satori/go.uuid"

	"github.com/jrnt30/noted-apex/pkg/noted"
)

type DynamoLinkSaver struct {
	enabled bool
	dynamo  *dynamodb.DynamoDB
}

var _ noted.LinkProcessor = &DynamoLinkSaver{}

func (d *DynamoLinkSaver) Enabled() bool {
	return d.enabled
}

func (d *DynamoLinkSaver) ProcessLink(link *noted.Link) error {
	link.ID = uuid.NewV4().String()
	link.CreatedAt = time.Now()
	link.UpdatedAt = time.Now()

	av, err := dynamodbattribute.MarshalMap(link)
	if err != nil {
		return err
	}

	res, err := d.dynamo.PutItem(&dynamodb.PutItemInput{
		TableName: aws.String("dev-NotedLinks"),
		Item:      av,
	})

	if err != nil {
		fmt.Fprintf(os.Stderr, "Error writing to dynamo: %+v", err)
		return err
	}

	newLink := &noted.Link{}
	if err = dynamodbattribute.UnmarshalMap(res.Attributes, newLink); err != nil {
		fmt.Fprintf(os.Stderr, "Error unmarshalling from dynamo: %+v", err)
		return err
	}

	return nil
}

func NewDynamoLinkSaver() DynamoLinkSaver {
	session, err := session.NewSession()

	return DynamoLinkSaver{
		enabled: err != nil,
		dynamo:  dynamodb.New(session),
	}
}
