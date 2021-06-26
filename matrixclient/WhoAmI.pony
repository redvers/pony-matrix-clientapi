use "http"
use "net_ssl"
use "json"
use "debug"
use "buffered"

class WhoAmI
  let cb: CBType

  new val create(cb': CBType) =>
    cb = cb'

  fun val callback(json: String) =>
    cb(this, json)

  fun apply(json: String): String ? =>
      let doc: JsonDoc = JsonDoc
      doc.parse(json)?
      (doc.data as JsonObject).data("user_id")? as String
