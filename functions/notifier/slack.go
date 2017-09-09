package main

import (
	"fmt"
	"os"

	"github.com/hashicorp/go-multierror"
	"github.com/nlopes/slack"

	"github.com/jrnt30/noted-apex/pkg/noted"
)

const (
	SLACK_TOKEN   = "SLACK_TOKEN"
	SLACK_CHANNEL = "SLACK_CHANNEL"
	LINK_COLOR    = "#94F89E"
)

type SlackNotifier struct {
	channel string
	client  *slack.Client
	enabled bool
}

// Ensures that SlackNotifier continues to implement the Notifier interface
var _ noted.LinkProcessor = &SlackNotifier{}

func (s *SlackNotifier) Enabled() bool {
	return s.enabled
}

func (s *SlackNotifier) ProcessLink(link *noted.Link) error {
	var errors error
	_, _, err := s.client.PostMessage(s.channel, "", slack.PostMessageParameters{
		Attachments: []slack.Attachment{convertToAttachment(link)},
	})

	if err != nil {
		errors = multierror.Append(errors, err)
		fmt.Fprintf(os.Stderr, "Error posting message to slack: %+v", err)
	}
	return errors
}

func convertToAttachment(link *noted.Link) slack.Attachment {
	desc := "(no description provided)"
	if len(link.Description) > 0 {
		desc = link.Description
	}

	author := "TODO (Map Users)"

	return slack.Attachment{
		AuthorName: author,
		Color:      LINK_COLOR,
		Fallback:   fmt.Sprintf("%s posted a new link: %s", author, link.URL),
		Pretext:    "",
		Text:       fmt.Sprintf("%s\n%s", desc, link.URL),
		Title:      link.Title,
		TitleLink:  link.URL,
	}
}

func NewSlackNotifier() SlackNotifier {
	token := os.Getenv(SLACK_TOKEN)
	channel := os.Getenv(SLACK_CHANNEL)

	if len(token) == 0 || len(channel) == 0 {
		fmt.Fprint(os.Stderr, "There was no configuration provided for Slack, skipping activiation")
		return SlackNotifier{}
	}

	client := slack.New(token)
	_, authErr := client.AuthTest()

	return SlackNotifier{
		channel: channel,
		client:  client,
		enabled: authErr == nil,
	}
}
