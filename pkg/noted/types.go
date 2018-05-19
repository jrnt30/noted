package noted

import "time"

type Link struct {
	ID          string    `json:"id" dynamodbav:"ID"`
	URL         string    `json:"url" dynamodbav:"URL"`
	CreatedBy   string    `json:"userId" dynamodbav:"CreatedBy"`
	Title       string    `json:"userTitle" dynamodbav:"Title"`
	Description string    `json:"userDescription" dynamodbav:"Description"`
	CreatedAt   time.Time `json:"createdAt" dynamodbav:"CreatedAt"`
	UpdatedAt   time.Time `json:"updatedAt" dynamodbav:"UpdatedAt"`
	DeletedAt   time.Time `json:"deletedAt" dynamodbav:"DeletedAt"`
}

type User struct {
	ID    int    `json:"id"`
	Name  string `json:"user_name"`
	Token string `json:"token"`
}

type LinkProcessor interface {
	Enabled() bool
	ProcessLink(*Link) error
}
