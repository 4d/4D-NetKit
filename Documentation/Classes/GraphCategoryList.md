# GraphCategoryList Class

## Overview

`GraphCategoryList` is a paginated list of Outlook master categories returned by [`Office365.category.list()`](./Office365.md#office365categorylist). It exposes the category objects via the `categories` property.

## Properties

A `GraphCategoryList` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| categories | Collection | Collection of category objects on the current page. Each object contains: |
| | id (Text) | ID of the category. |
| | displayName (Text) | Unique name identifying the category in the user's mailbox. Once set, this name cannot be changed. |
| | color (Text) | A pre-set color constant mapped to one of 25 predefined Outlook colors (e.g., `"Preset0"`, `"Preset12"`). See [color constants](https://learn.microsoft.com/en-us/graph/api/resources/outlookcategory?view=graph-rest-1.0#properties). |
| isLastPage | Boolean | `true` if the last page of results has been reached. |
| page | Integer | Current page number. Starts at `1`. |
| next() | 4D.Function | Loads the next page and increments `page` by 1. Returns `true` if successful, `false` if no additional pages are available. |
| previous() | 4D.Function | Loads the previous page and decrements `page` by 1. Returns `true` if successful, `false` if no previous pages are available. |
| success | Boolean | `true` if the operation was successful. |
| statusText | Text | Status message returned by the Microsoft server or the last error from the 4D error stack. |
| errors | Collection | Collection of 4D error items (if any): `errcode`, `message`, `componentSignature`. |

## See also

* [Office365Category](./Office365Category.md)
* [Office365](./Office365.md)
