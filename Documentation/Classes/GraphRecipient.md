# GraphRecipient Class

## Overview

Represents a Microsoft Graph email recipient (`{emailAddress: {address; name}}`).
Validates the address on construction and throws a deferred error (code 2) when invalid.

## Properties

A `GraphRecipient` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| emailAddress | Object |  |
