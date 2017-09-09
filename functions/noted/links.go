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

type LinkSaver interface {
	SaveLink(link *noted.Link) error
}

type DynamoLinkSaver struct {
	dynamo *dynamodb.DynamoDB
}

func (d DynamoLinkSaver) SaveLink(link *noted.Link) error {
	link.ID = uuid.NewV4().String()
	link.CreatedAt = time.Now()
	link.UpdatedAt = time.Now()

	av, err := dynamodbattribute.MarshalMap(&link)
	if err != nil {
		return err
	}

	fmt.Fprint(os.Stderr, av)

	res, err := d.dynamo.PutItem(&dynamodb.PutItemInput{
		TableName: aws.String("dev-NotedLinks"),
		Item:      av,
	})

	if err != nil {
		fmt.Fprintf(os.Stderr, "Error writing to dynamo: %+v", err)
		return err
	}

	newLink := &noted.Link{}
	err = dynamodbattribute.UnmarshalMap(res.Attributes, newLink)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error unmarshalling from dynamo: %+v", err)
		return err
	}

	return err
}

func NewDynamoLinkSaver() (LinkSaver, error) {
	session, err := session.NewSession()
	if err != nil {
		return nil, err
	}

	ls := DynamoLinkSaver{
		dynamo: dynamodb.New(session),
	}

	return ls, nil
}
