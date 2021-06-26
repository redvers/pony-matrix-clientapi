# pony-matrix-clientapi

Pony implementation for a subsection of the Matrix Client API

## Status

[![CircleCI](https://circleci.com/gh/redvers/pony-matrix-clientapi.svg?style=svg)](https://circleci.com/gh/redvers/pony-matrix-clientapi)

pony-matrix-clientapi is pre-alpha software.

## Installation

* Install [pony-stable](https://github.com/ponylang/pony-stable)
* Update your `bundle.json`

```json
{
  "type": "github",
  "repo": "redvers/pony-matrix-clientapi"
}
```

* `stable fetch` to fetch your dependencies
* `use "matrixclient"` to include this package
* `stable env ponyc` to compile your application
