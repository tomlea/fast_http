require 'rfuzz/session'

context "3: Protocol Parameters" do
  setup do
    @sess = RFuzz::Session.new :host => "localhost", :port => 3000
  end

  specify "3.1: HTTP Version" do
    # "HTTP" "/" 1*DIGIT "." 1*DIGIT
  end


  specify "3.2: Uniform Resource Identifiers" do

  end


  specify "3.2.1: General Syntax" do
    # Valid URIs are from RFC 2396:
    # "URI-reference", "absoluteURI", "relativeURI", "port",
    # "host","abs_path", "rel_path", and "authority"

    # MUST be able to handle the URI of any resource they serve

    # SHOULD be able to handle URIs of unbounded length if they
    # provide GET-based forms that could generate such URIs. 

    # A server SHOULD return 414 (Request-URI Too Long) status if a URI is longer
    # than the server can handle (see section 10.4.15).
  end


  specify "3.2.2: http URL" do
    # http_URL = "http:" "//" host [ ":" port ] [ abs_path [ "?" query ]]

    # The use of IP addresses in URLs SHOULD be avoided whenever possible

    # If the abs_path is not present in the URL, it MUST be given as "/" when
    # used as a Request-URI for a resource (section 5.1.2).  

    # If a proxy receives a host name which is not a fully qualified domain
    # name, it MAY add its domain to the host name it received.

    # If a proxy receives a fully qualified domain name, the proxy MUST NOT
    # change the host name.
  end


  specify "3.2.3: URI Comparison" do
    # When comparing two URIs to decide if they match or not, a client SHOULD
    # use a case-sensitive octet-by-octet comparison of the entire URIs, with
    # these exceptions:

    # - A port that is empty or not given is equivalent to the default port for
    # that URI-reference;

    # - Comparisons of host names MUST be case-insensitive;

    # - Comparisons of scheme names MUST be case-insensitive;

    # - An empty abs_path is equivalent to an abs_path of "/".

    #  http://abc.com:80/~smith/home.html
    #  http://ABC.com/%7Esmith/home.html
    #  http://ABC.com:/%7esmith/home.html
  end


  specify "3.3: Date/Time Formats" do
  end


  specify "3.3.1: Full Date" do
    # HTTP/1.1 clients and servers that parse the date value MUST accept
    # all three formats:

    #   Sun, 06 Nov 1994 08:49:37 GMT  ; RFC 822, updated by RFC 1123
    #   Sunday, 06-Nov-94 08:49:37 GMT ; RFC 850, obsoleted by RFC 1036
    #   Sun Nov  6 08:49:37 1994       ; ANSI C's asctime() format

    # MUST only generate the RFC 1123 format for representing HTTP-date values
    # in header fields

    # MUST be represented in Greenwich Mean Time (GMT), without exception

    # MUST be assumed when reading the asctime format

    # HTTP-date is case sensitive and MUST NOT include
    # additional LWS beyond that specifically included as SP in the
    # grammar.
  end


  specify "3.3.2: Delta Seconds" do
    # delta-seconds  = 1*DIGIT  (for some http headers)
  end


  specify "3.4: Character Sets" do
    # MIME character set name MUST fully specify the mapping to be performed
    # from octets to characters.

    # any token that has a predefined value within the IANA Character Set
    # registry [19] MUST represent the character set defined by that registry
  end

  specify "3.4.1: Missing Charset" do
    # Some HTTP/1.0 software has interpreted a Content-Type header without
    # charset parameter incorrectly to mean "recipient should guess."
    # Senders wishing to defeat this behavior

    # MAY include a charset parameter even when the charset is ISO-8859-1 and
    # SHOULD do so when it is known that it will not confuse the recipient.

    # HTTP/1.1 recipients MUST respect the charset label provided by the
    # sender; and 

    # those user agents that have a provision to "guess" a charset MUST use the
    # charset from the content-type field if they support that charset, rather
    # than the recipient's preference, when initially displaying a document.

    # See section 3.7.1.
  end


  specify "3.5: Content Codings" do
    # All content-coding values are case-insensitive

    # gzip
    # compress
    # deflate
    # identity

    # New content-coding value tokens SHOULD be registered
  end


  specify "3.6: Transfer Codings" do
    # the transfer-coding is a property of the message, not of the original entity.

    #   transfer-coding         = "chunked" | transfer-extension
    #   transfer-extension      = token *( ";" parameter )

    # Parameters are in  the form of attribute/value pairs.

    #   parameter               = attribute "=" value
    #   attribute               = token
    #   value                   = token | quoted-string

    # All transfer-coding values are case-insensitive

    # Whenever a transfer-coding is applied to a message-body, the set of
    # transfer-codings MUST include "chunked", unless the message is terminated
    # by closing the connection

    # "chunked" MUST be the last transfer-coding applied to the message-body

    # A server which receives an entity-body with a transfer-coding it does not
    # understand SHOULD return 501 (Unimplemented), and close the connection.

    # A server MUST NOT send transfer-codings to an HTTP/1.0 client.
  end


  specify "3.6.1: Chunked Transfer Coding" do
    # AMBIGUITY: It's not clear whether clients can use chunked encoding on requests.

    # MUST NOT use the trailer for any header fields unless at least one of the
    # following is true:

    # - The TE header includes "trailers"
    # - server is origin, trailer is all optional, recipient can use if discarded

    # All HTTP/1.1 applications MUST be able to receive and decode the
    # "chunked" transfer-coding, and MUST ignore chunk-extension extensions
    # they do not understand.
    # AMBIGUITY:  "applications"?  WTF is that?  client? server?
  end


  specify "3.7: Media Types" do
    # Parameters MAY follow the type/subtype in the form of attribute/value pairs

    # Linear white space (LWS) MUST NOT be used between the type and subtype,
    # nor between an attribute and its value

    # When sending data to older HTTP applications, implementations SHOULD only
    # use media type parameters when they are required by that type/subtype
    # definition.
    # AMBIGUITY: How the hell do we determine that an app is old?
  end


  specify "3.7.1: Canonicalization and Text Defaults" do
    # RANT: The majority of this section is impossible to test.

    # The entire paragraph about CR,LF,and CRLF is garbage.  Basically,
    # if you set a media subtype of "text" then the client has to deal
    # with just about any 'line break' combo humanly possible.

    # If an entity-body is encoded with a content-coding, the underlying data
    # MUST be in a form defined above prior to being encoded.

    # Data in character sets other than "ISO-8859-1" or its subsets MUST be
    # labeled with an appropriate charset value. See section 3.4.1 for
    # compatibility problems.
  end


  specify "3.7.2: Multipart Types" do
    # MUST include a boundary parameter as part of the media type value.

    # MUST therefore use only CRLF to represent line breaks between body-parts

    # Unlike in RFC 2046, the epilogue of any multipart message MUST be empty; 

    # HTTP applications MUST NOT transmit the epilogue (even if the original
    # multipart contains an epilogue).

    # ... "multipart/byteranges" type (appendix 19.2) when it appears in a 206
    # (Partial Content) response, which will be interpreted by some HTTP
    # caching mechanisms as described in sections 13.5.4 and 14.16

    # an HTTP user agent SHOULD follow the same or similar behavior as a MIME
    # user agent would upon receipt of a multipart type

    # If an application receives an unrecognized multipart subtype, the
    # application MUST treat it as being equivalent to "multipart/mixed".
  end


  specify "3.8: Product Tokens" do
    # product         = token ["/" product-version]
    # product-version = token

    # SHOULD be short and to the point

    # MUST NOT be used for advertising or other non-essential information

    #  Although any token character MAY appear in a product-version, this token
    #  SHOULD only be used for a version identifier
  end


  specify "3.9: Quality Values" do
    # HTTP/1.1 applications MUST NOT generate more than three digits after the
    # decimal point.

    # User configuration of these values SHOULD also be limited in this
    # fashion.
  end


  specify "3.10: Language Tags" do
    # language-tag  = primary-tag *( "-" subtag )
    # primary-tag   = 1*8ALPHA
    # subtag        = 1*8ALPHA

    # White space is not allowed within the tag and all tags are case-
    # insensitive.
  end


  specify "3.11: Entity Tags" do
    # An entity tag MUST be unique across all versions of all entities
    # associated with a particular resource.

    # A given entity tag value MAY be used for entities obtained by requests on
    # different URIs.
  end


  specify "3.12: Range Units" do
    # range-unit       = bytes-unit | other-range-unit
    # bytes-unit       = "bytes"
    # other-range-unit = token

    # The only range unit defined by HTTP/1.1 is "bytes". HTTP/1.1
    # implementations MAY ignore ranges specified using other units.
  end


end
