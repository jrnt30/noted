package main

import (
	"github.com/jrnt30/noted/pkg/noted"
)

// EsIndexer is a stub class that will  implement another processor step
// to actually index data into ES
type EsIndexer struct {
}

// Ensures EsIndexer stays in compliance with interface.
var _ noted.LinkProcessor = &EsIndexer{}

// Enabled indicates if it's...enabled
func (*EsIndexer) Enabled() bool {
	return false
}

// ProcessLink ensures that the noted link is persisted
// to ES
func (*EsIndexer) ProcessLink(*noted.Link) error {
	panic("implement me")
}

// NewESIndexer generates a new ESIndexer
func NewESIndexer() EsIndexer {
	return EsIndexer{}
}
