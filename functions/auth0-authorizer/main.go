package main

import (
	"crypto/rsa"
	"encoding/json"
	"errors"
	"net/http"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/dgrijalva/jwt-go"
)

var auth0domain, auth0audience string
var auth0parser *jwt.Parser

func init() {
	auth0audience = os.Getenv("AUTH0_AUDIENCE")
	auth0domain = os.Getenv("AUTH0_DOMAIN")
	auth0parser = &jwt.Parser{
		ValidMethods: []string{jwt.SigningMethodRS256.Name},
	}
}

func main() {
	handler := func(e events.APIGatewayCustomAuthorizerRequest) (events.APIGatewayCustomAuthorizerResponse, error) {
		return handleAuth(auth0parser, auth0domain, auth0audience, e.AuthorizationToken, e.MethodArn)
	}

	lambda.Start(handler)
}

func handleAuth(parser *jwt.Parser, domain string, audience string, auth string, arn string) (events.APIGatewayCustomAuthorizerResponse, error) {
	if auth[:7] != "Bearer " && auth[:7] != "bearer " {
		return events.APIGatewayCustomAuthorizerResponse{}, errors.New("Need to provide a properly formatted Authorization header")
	}

	bearerToken := auth[7:]
	stdClaims := &jwt.StandardClaims{}

	// ParseWithClaims performs validation on the claims of the JWT along with validation of the signing method inherently
	_, err := parser.ParseWithClaims(bearerToken, stdClaims, func(jwtToken *jwt.Token) (interface{}, error) {
		var pubKey *rsa.PublicKey
		if !stdClaims.VerifyAudience(audience, true) {
			return pubKey, errors.New("invalid token audience provided")
		}
		if !stdClaims.VerifyIssuer("https://"+domain+"/", true) {
			return pubKey, errors.New("invalid token issuer provided")
		}

		cert, err := getPemCert(domain, jwtToken)
		if err != nil {
			return pubKey, err
		}

		pubKey, err = jwt.ParseRSAPublicKeyFromPEM([]byte(cert))
		return pubKey, nil
	})

	if err != nil {
		return events.APIGatewayCustomAuthorizerResponse{}, err
	}
	return buildCustomAuthResponse(stdClaims.Audience, "Allow", arn), nil
}

// Lifted from https://github.com/auth0/auth0-golang

type Response struct {
	Message string `json:"message"`
}

type Jwks struct {
	Keys []JSONWebKeys `json:"keys"`
}

type JSONWebKeys struct {
	Kty string   `json:"kty"`
	Kid string   `json:"kid"`
	Use string   `json:"use"`
	N   string   `json:"n"`
	E   string   `json:"e"`
	X5c []string `json:"x5c"`
}

func buildCustomAuthResponse(principal, effect, arn string) events.APIGatewayCustomAuthorizerResponse {
	return events.APIGatewayCustomAuthorizerResponse{
		PrincipalID: principal,
		PolicyDocument: events.APIGatewayCustomAuthorizerPolicy{
			Version: "2012-10-17",
			Statement: []events.IAMPolicyStatement{
				{
					Effect:   effect,
					Action:   []string{"execute-api:Invoke"},
					Resource: []string{arn},
				},
			},
		},
	}
}

func getPemCert(domain string, token *jwt.Token) (string, error) {
	cert := ""
	resp, err := http.Get("https://" + domain + "/.well-known/jwks.json")

	if err != nil {
		return cert, err
	}
	defer resp.Body.Close()

	var jwks = Jwks{}
	err = json.NewDecoder(resp.Body).Decode(&jwks)

	if err != nil {
		return cert, err
	}

	for k := range jwks.Keys {
		if token.Header["kid"] == jwks.Keys[k].Kid {
			cert = "-----BEGIN CERTIFICATE-----\n" + jwks.Keys[k].X5c[0] + "\n-----END CERTIFICATE-----"
		}
	}

	if cert == "" {
		err := errors.New("unable to find appropriate key")
		return cert, err
	}

	return cert, nil
}
