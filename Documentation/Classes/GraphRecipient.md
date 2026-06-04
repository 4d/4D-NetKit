# GraphRecipient Class

## Overview

Represents a Microsoft Graph email recipient (`{emailAddress: {address; name}}`).
Validates the address on construction and throws a deferred error (code 2) when invalid.

## Table of Contents

### Initialization

* [cs.NetKit.GraphRecipient.new()](#csnetkitgraphrecipientnew)

### Properties

* [emailAddress](#emailaddress)

## **cs.NetKit.GraphRecipient.new()**

**cs.NetKit.GraphRecipient.new**( *$inAddress* : Text ; *$inName* : Text ) : cs.NetKit.GraphRecipient

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inAddress | Text | -> | Email address (validated via `_EmailAddress`) |
| $inName | Text | -> | Optional display name |
| Result | cs.NetKit.GraphRecipient | <- | Object of the GraphRecipient class |

### Description

Creates a Graph recipient object. Throws a deferred error with
`{code: 2; component: "4DNK"; attribute: "address"}` when the address is invalid.

### Properties

The returned `GraphRecipient` object contains the following properties:

| Property | Type | Description |
|---|---|---|
| emailAddress | Object |  |

