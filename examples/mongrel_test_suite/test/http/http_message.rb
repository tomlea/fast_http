require 'rfuzz/session'

context "4: HTTP Message" do
  setup do
    @sess = RFuzz::Session.new :host => "localhost", :port => 3000
  end

  specify "4.1: Message Types" do
    # In the interest of robustness, servers SHOULD ignore any empty line(s)
    # received where a Request-Line is expected.
  end


  specify "4.2: Message Headers" do
    # The field value MAY be preceded by any amount of LWS, though a single SP
    # is preferred.

    # leading or trailing LWS MAY be removed without changing the semantics of
    # the field value

    # Any LWS that occurs between field-content MAY be replaced with a single
    # SP before interpreting the field value or forwarding the message
    # downstream.
    # RANT: WTF, so the values basically have to be quoted to prevent this?

    # Multiple message-header fields with the same field-name MAY be present in
    # a message if and only if the entire field-value for that header field is
    # defined as a comma-separated list

    # It MUST be possible to combine the multiple header fields into one
    # "field-name: field-value" pair

    # a proxy MUST NOT change the order of these field values when a message is
    # forwarded
  end


  specify "4.3: Message Body" do
    # Transfer-Encoding MUST be used to indicate any transfer-codings applied
    # by an application to ensure safe and proper transfer of the message

    # Transfer-Encoding MAY be added or removed by any application along the
    # request/response chain 

    # A message-body MUST NOT be included in a request if the specification of
    # the request method (section 5.1.1) does not allow sending an entity-body
    # in requests.

    # A server SHOULD read and forward a message-body on any request 

    # if the request method does not include defined semantics for an
    # entity-body, then the message-body SHOULD be ignored when handling the
    # request

    # All responses to the HEAD request method MUST NOT include a message-body,
    # even though the presence of entity- header fields might lead one to
    # believe they do

    # All 1xx (informational), 204 (no content), and 304 (not modified)
    # responses MUST NOT include a message-body

    # All other responses do include a message-body, although it MAY be of zero
    # length.
  end


  specify "4.4: Message Length" do
    # The Content-Length header field MUST NOT be sent if these two lengths are
    # different (entity-length & transfer-length)

    # If a message is received with both a Transfer-Encoding header field and a
    # Content-Length header field, the latter MUST be ignored.

    # "multipart/byteranges" media type MUST NOT be used unless the sender
    # knows that the recipient can parse it

    # Closing the connection cannot be used to indicate the end of a request
    # body, since that would leave no possibility for the server to send back a
    # response.

    # HTTP/1.1 requests containing a message-body MUST include a valid
    # Content-Length header field unless the server is known to be HTTP/1.1
    # compliant

    # If a request contains a message-body and a Content-Length is not given,
    # the server SHOULD respond with 400 (bad request) if it cannot determine
    # the length of the message, or with 411 (length required) if it wishes to
    # insist on receiving a valid Content-Length.

    # All HTTP/1.1 applications that receive entities MUST accept the "chunked"
    # transfer-coding (section 3.6)
    # RANT: Applications meaning what?  clients? servers? both?

    # Messages MUST NOT include both a Content-Length header field and a
    # non-identity transfer-coding.

    # If the message does include a non- identity transfer-coding, the
    # Content-Length MUST be ignored.  RANT: They already said that, must be
    # really important.
    #
    # [Content-Length in messages which allow it] MUST exactly match the number
    # of OCTETs in the message-body. 

    # HTTP/1.1 user agents MUST notify the user when an invalid length is
    # received and detected.
  end


  specify "4.5: General Header Fields" do
    # These apply to both requests and responses:
    # general-header = Cache-Control            ; Section 14.9
    #                  | Connection               ; Section 14.10
    #                  | Date                     ; Section 14.18
    #                  | Pragma                   ; Section 14.32
    #                  | Trailer                  ; Section 14.40
    #                  | Transfer-Encoding        ; Section 14.41
    #                  | Upgrade                  ; Section 14.42
    #                  | Via                      ; Section 14.45
    #                  | Warning                  ; Section 14.46
  end

end
