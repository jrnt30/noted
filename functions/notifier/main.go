package main

import (
	"fmt"
	"os"

	"github.com/apex/go-apex"
	"github.com/apex/go-apex/dynamo"
	"github.com/nlopes/slack"
	"github.com/hashicorp/go-multierror"

	"github.com/jrnt30/noted-apex/pkg/noted"
	"github.com/jrnt30/noted-apex/pkg/utils"
)

func main() {
	token := os.Getenv("SLACK_TOKEN")
	channel := os.Getenv("SLACK_CHANNEL")

	api := slack.New(token)

	if _, authErr := api.AuthTest(); authErr != nil {
		panic(authErr)
	}

	dynamo.HandleFunc(func(event *dynamo.Event, context *apex.Context) error {
		var errors error
		for _, link := range utils.UnmarshalLinks(event) {
			_, _, err := api.PostMessage(channel, "", slack.PostMessageParameters{
				Attachments: []slack.Attachment{convertToAttachment(link)},
			})

			if err != nil {
				errors = multierror.Append(errors, err)
				fmt.Fprintf(os.Stderr, "Error posting message to slack: %+v", err)
			}
		}

		return errors
	})
}

func convertToAttachment(link noted.Link) slack.Attachment {
	desc := "(no description provided)"
	if len(link.Description) > 0 {
		desc = link.Description
	}

	author := "TODO (Map Users)"

	return slack.Attachment{
		AuthorName: author,
		Color:      "#94F89E",
		Fallback:   fmt.Sprintf("%s posted a new link: %s", author, link.URL),
		Pretext:    "",
		Text:       fmt.Sprintf("%s\n%s", desc, link.URL),
		Title:      link.Title,
		TitleLink:  link.URL,
	}
}
