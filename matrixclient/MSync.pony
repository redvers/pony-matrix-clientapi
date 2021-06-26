use "debug"
use "collections"
use "json"

class MSync
  let cb: CBType

  new val create(cb': CBType) =>
    cb = cb'

  fun val callback(json: String) =>
    cb(this, json)

  fun apply(json: String): (Map[String, String], String) ? =>
    let aliasmap: Map[String, String] = Map[String, String]
    let doc: JsonDoc = JsonDoc
    doc.parse(json)?

    let jsono: JsonObject = doc.data as JsonObject
    let roommap: JsonObject = (jsono.data("rooms")? as JsonObject).data("join")? as JsonObject
    for (rid, jo) in roommap.data.pairs() do
//      Debug.out(rid)
      match aliasname(jo as JsonObject)?
      | let x: None => None
      | let x: String => aliasmap.insert(x, rid)
      end
    end

    let nb: String = jsono.data("next_batch")? as String
    (aliasmap, nb)

  fun aliasname(jo: JsonObject): (String | None) ? =>
    try
      let evlist: Array[JsonType] = ((jo.data("state")? as JsonObject).data("events")? as JsonArray).data
      for event in evlist.values() do
        let s: String = (event as JsonObject).data("type")? as String
        match s
        | let x: String if (s == "m.room.canonical_alias") =>
          return ((event as JsonObject).data("content")? as JsonObject).data("alias")? as String
        end
      end
    else
      Debug.out("Failed in process_channel")
      error
    end
    None
