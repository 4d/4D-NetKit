# OAuth2Authorization Class

## Overview

The `OAuth2Authorization` class allows you to manage authentication reponses. 

The `OAuth2Authorization` class is a shared singleton, meaning a single instance is globally available without needing manual creation. You can access it directly via the `.me` property without instantiating a new instance.


## Table of contents

- [getResponse()](#getResponse)


## .getResponse()

**cs.NetKit.OAuth2Authorization.me.getResponse**() : Object

### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|email|Object|->| Microsoft message object to append|
|folderId|Text|->| Id of the destination folder. Can be a folder id or a [Well-known folder name](#well-known-folder-name).|
|Result|Object|<-| [Status object](#status-object)  |

### Description



### Returned object



### Example




## See also

[Google Class](./Google.md)<br/>
[Office365 Class](./Office365.md)