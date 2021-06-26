use "http"
use "net_ssl"
use "json"
use "debug"
use "buffered"
use "collections"

type CBType is {(DecodeType val, String): None} val
type DecodeType is (JoinedRooms | WhoAmI | MSync)

actor MatrixClient
  var readerBuffer: Reader ref = Reader
  let auth: AmbientAuth
  let homeserver: String
  let access_token: String
  let sslctx: SSLContext = recover SSLContext.>set_client_verify(false) end

  new create(auth': AmbientAuth, homeserver': String, access_token': String) =>
    auth = auth'
    homeserver = homeserver'
    access_token = access_token'

  be joined_rooms(cb': CBType) =>
    var httpclient: HTTPClient = HTTPClient.create(auth)
//    Debug.out("be joined_rooms: " + (digestof cb').string())
    try
      let url: URL = URL.build(homeserver + "/_matrix/client/r0/joined_rooms?access_token=" + access_token)?
      let req: Payload = Payload.request("GET", url)
      let jr: JoinedRooms val = JoinedRooms.create(cb')
      let dumpMaker = recover val NotifyFactory.create(jr) end
      let sentreq = httpclient(consume req, dumpMaker)?
    end

  be sync(cb': CBType) =>
    var httpclient: HTTPClient = HTTPClient.create(auth)
    Debug.out("be initial_sync: " + (digestof cb').string())
    try
      let url: URL = URL.build(homeserver + "/_matrix/client/r0/sync?access_token=" + access_token)?
      let req: Payload = Payload.request("GET", url)
      let msync: MSync val = MSync.create(cb')
      let dumpMaker = recover val NotifyFactory.create(msync) end
      let sentreq = httpclient(consume req, dumpMaker)?
    end

/* API Call that identifies our Matrix Username for provided token */
  be whoami(cb': CBType) =>
    var httpclient: HTTPClient = HTTPClient.create(auth)
    Debug.out("be whoami: " + (digestof cb').string())
    try
      let url: URL = URL.build(homeserver + "/_matrix/client/r0/account/whoami?access_token=" + access_token)?
      let req: Payload = Payload.request("GET", url)
      let wai: WhoAmI val = WhoAmI.create(cb')
      let dumpMaker = recover val NotifyFactory.create(wai) end
      let sentreq = httpclient(consume req, dumpMaker)?
    end

/* Send a message to a room */
//  be room_send(cb': CBType, roomid: String, message: String) =>
//    var httpclient: HTTPClient = HTTPClient.create(auth)
//    Debug.out("be room_send: " + (digestof cb').string())
//    try
//      let doc = JsonDoc
//      let obj = JsonObject
//      obj.data("msgtype") = "m.text"
//      obj.data("body") = message
//      doc.data = obj
//
//      let url: URL = URL.build(homeserver + "/_matrix/client/r0/rooms/" + roomid + "/send/m.room.message?access_token=" + access_token)?
//      let req: Payload = Payload.request("POST", url)
//      req.add_chunk(doc.string())
//      let dumpMaker = recover val NotifyFactory.create(cb') end
//      let sentreq = httpclient(consume req, dumpMaker)?
//
//    end




class NotifyFactory is HandlerFactory
  let decoder: DecodeType val

  new iso create(decoder': DecodeType val) =>
    decoder = decoder'

  fun apply(session: HTTPSession): HTTPHandler ref^ =>
    HttpNotify.create(decoder, session)

class HttpNotify is HTTPHandler
  let decoder: DecodeType val
  let _session: HTTPSession
  let readerBuffer: Reader ref = Reader

  new ref create(decoder': DecodeType val, session: HTTPSession) =>
    decoder = decoder'
//    Debug.out("HttpNotify: " + (digestof cb).string() + " " + (digestof session).string())
    _session = session

  fun ref apply(response: Payload val) =>
    try
      let body = response.body()?
      for piece in body.values() do
        readerBuffer.append(piece)
      end
    end

  fun ref chunk(data: ByteSeq val) =>
//    Debug.out("HttpNotify.chunk: " + (digestof _session).string())
    readerBuffer.append(data)

  fun ref finished() =>
    let size: USize = readerBuffer.size()
      try
        let block: Array[U8] val = readerBuffer.block(size)?
        let string: String = String.from_array(block)
//        Debug.out("ST: " + string)
        _session.dispose()
        Debug.out("HttpNotify.finish: " + (digestof _session).string())
        decoder.callback(string)
//        cb(decoder)
      end

  fun ref cancelled() =>
    None

  fun ref failed(reason: HTTPFailureReason) =>
    None

