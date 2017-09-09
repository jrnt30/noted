package noted

import "time"

type Link struct {
	ID          string    `json:"id" dynamodbav:"ID"`
	URL         string    `json:"url" dynamodbav:"URL"`
	CreatedBy   string    `json:"user_id" dynamodbav:"CreatedBy"`
	Title       string    `json:"user_title" dynamodbav:"Title"`
	Description string    `json:"user_description" dynamodbav:"Description"`
	CreatedAt   time.Time `json:"created_at" dynamodbav:"CreatedAt"`
	UpdatedAt   time.Time `json:"updated_at" dynamodbav:"UpdatedAt"`
	DeletedAt   time.Time `json:"deleted_at" dynamodbav:"DeletedAt"`
}

type User struct {
	ID    int    `json:"id"`
	Name  string `json:"user_name"`
	Token string `json:"token"`
}
