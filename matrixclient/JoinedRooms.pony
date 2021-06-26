use "http"
use "net_ssl"
use "json"
use "debug"
use "buffered"

class JoinedRooms
  let cb: CBType

  new val create(cb': CBType) =>
    cb = cb'

  fun val callback(json: String) =>
    cb(this, json)

  fun apply(json: String): Array[String] ? =>
    var roomarray: Array[String] = Array[String]
    let doc: JsonDoc = JsonDoc
    doc.parse(json)?
    let ja: Array[JsonType] = ((doc.data as JsonObject).data("joined_rooms")? as JsonArray).data

    for roomname in ja.values() do
      match roomname
      | let x: String => roomarray.push(x)
      end
    end
    roomarray
