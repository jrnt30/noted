package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/jrnt30/noted-apex/pkg/noted"
)

var ls DynamoLinkSaver

func init() {
	ls = NewDynamoLinkSaver()
}

func main() {
	lambda.Start(handleLinkPost)
}

func handleLinkPost(context context.Context, r events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	link := &noted.Link{}
	err := json.Unmarshal([]byte(r.Body), link)

	if err != nil {
		log.Printf(err.Error())
		return events.APIGatewayProxyResponse{StatusCode: 500}, fmt.Errorf("Unable to decode the request properly for a Link posting: %v", r.RequestContext.RequestID)
	}

	err = ls.ProcessLink(link)

	if err != nil {
		log.Printf(err.Error())
		return events.APIGatewayProxyResponse{StatusCode: 500}, fmt.Errorf("Error persisiting link to dynamo: %v", err)
	}

	res, _ := json.Marshal(link)
	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Body:       string(res),
		Headers:    map[string]string{"Content-Type": "application/json"},
	}, nil
}
