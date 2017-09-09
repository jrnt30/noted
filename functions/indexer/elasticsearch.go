package main

import "github.com/jrnt30/noted-apex/pkg/noted"

type EsIndexer struct {
}

// Ensures EsIndexer stays in compliance with interface.
var _ noted.LinkProcessor = &EsIndexer{}

func (*EsIndexer) Enabled() bool {
	return false
}

func (*EsIndexer) ProcessLink(*noted.Link) error {
	panic("implement me")
}

func NewESIndexer() *EsIndexer {
	return &EsIndexer{}
}
