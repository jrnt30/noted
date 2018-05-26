package main

import (
	"encoding/base64"
	"log"
	"os"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/kms"

	"github.com/jrnt30/noted/pkg/dynamo"
)

var notifier SlackNotifier

func init() {
	channel := os.Getenv(SLACK_CHANNEL)
	token := os.Getenv(SLACK_TOKEN)
	ciphertext, _ := base64.StdEncoding.DecodeString(token)

	k := kms.New(session.New())
	dec, err := k.Decrypt(&kms.DecryptInput{
		CiphertextBlob: ciphertext,
	})

	if err != nil {
		log.Fatal("Unable to decrypt the token provided", err)
	}

	log.Printf("Decrypted is: [%s]", string(dec.Plaintext))
	notifier = NewSlackNotifier(string(dec.Plaintext), channel)
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
