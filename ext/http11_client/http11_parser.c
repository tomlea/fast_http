#line 1 "ext/http11_client/http11_parser.rl"
/**
 * Copyright (c) 2005 Zed A. Shaw
 * You can redistribute it and/or modify it under the same terms as Ruby.
 */

#include "http11_parser.h"
#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#define LEN(AT, FPC) (FPC - buffer - parser->AT)
#define MARK(M,FPC) (parser->M = (FPC) - buffer)
#define PTR_TO(F) (buffer + parser->F)
#define L(M) fprintf(stderr, "" # M "\n");


/** machine **/
#line 91 "ext/http11_client/http11_parser.rl"


/** Data **/

#line 27 "ext/http11_client/http11_parser.c"
static int httpclient_parser_start = 0;

static int httpclient_parser_first_final = 26;

static int httpclient_parser_error = 1;

#line 95 "ext/http11_client/http11_parser.rl"

int httpclient_parser_init(httpclient_parser *parser)  {
  int cs = 0;
  
#line 39 "ext/http11_client/http11_parser.c"
	{
	cs = httpclient_parser_start;
	}
#line 99 "ext/http11_client/http11_parser.rl"
  parser->cs = cs;
  parser->body_start = 0;
  parser->content_len = 0;
  parser->mark = 0;
  parser->nread = 0;
  parser->field_len = 0;
  parser->field_start = 0;    

  return(1);
}


/** exec **/
size_t httpclient_parser_execute(httpclient_parser *parser, const char *buffer, size_t len, size_t off)  {
  const char *p, *pe;
  int cs = parser->cs;

  assert(off <= len && "offset past end of buffer");

  p = buffer+off;
  pe = buffer+len;

  assert(*pe == '\0' && "pointer does not end on NUL");
  assert(pe - p == len - off && "pointers aren't same distance");


  
#line 71 "ext/http11_client/http11_parser.c"
	{
	p -= 1;
	if ( ++p == pe )
		goto _out;
	switch ( cs )
	{
case 0:
	switch( (*p) ) {
		case 13: goto st2;
		case 59: goto st4;
		case 72: goto tr19;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto tr17;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto tr17;
	} else
		goto tr17;
	goto st1;
st1:
	goto _out1;
tr21:
#line 33 "ext/http11_client/http11_parser.rl"
	{ 
    parser->http_field(parser->data, PTR_TO(field_start), parser->field_len, PTR_TO(mark), LEN(mark, p));
  }
	goto st2;
tr24:
#line 49 "ext/http11_client/http11_parser.rl"
	{
    parser->chunk_size(parser->data, PTR_TO(mark), LEN(mark, p));
  }
	goto st2;
tr27:
#line 27 "ext/http11_client/http11_parser.rl"
	{ 
    parser->field_len = LEN(field_start, p);
  }
#line 31 "ext/http11_client/http11_parser.rl"
	{ MARK(mark, p); }
#line 33 "ext/http11_client/http11_parser.rl"
	{ 
    parser->http_field(parser->data, PTR_TO(field_start), parser->field_len, PTR_TO(mark), LEN(mark, p));
  }
	goto st2;
st2:
	if ( ++p == pe )
		goto _out2;
case 2:
#line 123 "ext/http11_client/http11_parser.c"
	if ( (*p) == 10 )
		goto tr32;
	goto st1;
tr32:
#line 53 "ext/http11_client/http11_parser.rl"
	{ 
    parser->body_start = p - buffer + 1; 
    if(parser->header_done != NULL)
      parser->header_done(parser->data, p + 1, pe - p - 1);
    goto _out26;
  }
	goto st26;
st26:
	if ( ++p == pe )
		goto _out26;
case 26:
#line 140 "ext/http11_client/http11_parser.c"
	goto st1;
tr17:
#line 23 "ext/http11_client/http11_parser.rl"
	{MARK(mark, p); }
	goto st3;
st3:
	if ( ++p == pe )
		goto _out3;
case 3:
#line 150 "ext/http11_client/http11_parser.c"
	switch( (*p) ) {
		case 13: goto tr24;
		case 59: goto tr26;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st3;
	} else if ( (*p) > 70 ) {
		if ( 97 <= (*p) && (*p) <= 102 )
			goto st3;
	} else
		goto st3;
	goto st1;
tr23:
#line 33 "ext/http11_client/http11_parser.rl"
	{ 
    parser->http_field(parser->data, PTR_TO(field_start), parser->field_len, PTR_TO(mark), LEN(mark, p));
  }
	goto st4;
tr26:
#line 49 "ext/http11_client/http11_parser.rl"
	{
    parser->chunk_size(parser->data, PTR_TO(mark), LEN(mark, p));
  }
	goto st4;
tr29:
#line 27 "ext/http11_client/http11_parser.rl"
	{ 
    parser->field_len = LEN(field_start, p);
  }
#line 31 "ext/http11_client/http11_parser.rl"
	{ MARK(mark, p); }
#line 33 "ext/http11_client/http11_parser.rl"
	{ 
    parser->http_field(parser->data, PTR_TO(field_start), parser->field_len, PTR_TO(mark), LEN(mark, p));
  }
	goto st4;
st4:
	if ( ++p == pe )
		goto _out4;
case 4:
#line 192 "ext/http11_client/http11_parser.c"
	switch( (*p) ) {
		case 33: goto tr9;
		case 124: goto tr9;
		case 126: goto tr9;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto tr9;
		} else if ( (*p) >= 35 )
			goto tr9;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto tr9;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto tr9;
		} else
			goto tr9;
	} else
		goto tr9;
	goto st1;
tr9:
#line 25 "ext/http11_client/http11_parser.rl"
	{ MARK(field_start, p); }
	goto st5;
st5:
	if ( ++p == pe )
		goto _out5;
case 5:
#line 224 "ext/http11_client/http11_parser.c"
	switch( (*p) ) {
		case 13: goto tr27;
		case 33: goto st5;
		case 59: goto tr29;
		case 61: goto tr30;
		case 124: goto st5;
		case 126: goto st5;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st5;
		} else if ( (*p) >= 35 )
			goto st5;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st5;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st5;
		} else
			goto st5;
	} else
		goto st5;
	goto st1;
tr30:
#line 27 "ext/http11_client/http11_parser.rl"
	{ 
    parser->field_len = LEN(field_start, p);
  }
#line 31 "ext/http11_client/http11_parser.rl"
	{ MARK(mark, p); }
	goto st6;
st6:
	if ( ++p == pe )
		goto _out6;
case 6:
#line 263 "ext/http11_client/http11_parser.c"
	switch( (*p) ) {
		case 33: goto tr10;
		case 124: goto tr10;
		case 126: goto tr10;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto tr10;
		} else if ( (*p) >= 35 )
			goto tr10;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto tr10;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto tr10;
		} else
			goto tr10;
	} else
		goto tr10;
	goto st1;
tr10:
#line 31 "ext/http11_client/http11_parser.rl"
	{ MARK(mark, p); }
	goto st7;
st7:
	if ( ++p == pe )
		goto _out7;
case 7:
#line 295 "ext/http11_client/http11_parser.c"
	switch( (*p) ) {
		case 13: goto tr21;
		case 33: goto st7;
		case 59: goto tr23;
		case 124: goto st7;
		case 126: goto st7;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st7;
		} else if ( (*p) >= 35 )
			goto st7;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st7;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st7;
		} else
			goto st7;
	} else
		goto st7;
	goto st1;
tr19:
#line 23 "ext/http11_client/http11_parser.rl"
	{MARK(mark, p); }
	goto st8;
st8:
	if ( ++p == pe )
		goto _out8;
case 8:
#line 329 "ext/http11_client/http11_parser.c"
	if ( (*p) == 84 )
		goto st9;
	goto st1;
st9:
	if ( ++p == pe )
		goto _out9;
case 9:
	if ( (*p) == 84 )
		goto st10;
	goto st1;
st10:
	if ( ++p == pe )
		goto _out10;
case 10:
	if ( (*p) == 80 )
		goto st11;
	goto st1;
st11:
	if ( ++p == pe )
		goto _out11;
case 11:
	if ( (*p) == 47 )
		goto st12;
	goto st1;
st12:
	if ( ++p == pe )
		goto _out12;
case 12:
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st13;
	goto st1;
st13:
	if ( ++p == pe )
		goto _out13;
case 13:
	if ( (*p) == 46 )
		goto st14;
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st13;
	goto st1;
st14:
	if ( ++p == pe )
		goto _out14;
case 14:
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st15;
	goto st1;
st15:
	if ( ++p == pe )
		goto _out15;
case 15:
	if ( (*p) == 32 )
		goto tr14;
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st15;
	goto st1;
tr14:
#line 45 "ext/http11_client/http11_parser.rl"
	{	
    parser->http_version(parser->data, PTR_TO(mark), LEN(mark, p));
  }
	goto st16;
st16:
	if ( ++p == pe )
		goto _out16;
case 16:
#line 396 "ext/http11_client/http11_parser.c"
	if ( 48 <= (*p) && (*p) <= 57 )
		goto tr4;
	goto st1;
tr4:
#line 23 "ext/http11_client/http11_parser.rl"
	{MARK(mark, p); }
	goto st17;
st17:
	if ( ++p == pe )
		goto _out17;
case 17:
#line 408 "ext/http11_client/http11_parser.c"
	if ( (*p) == 32 )
		goto tr12;
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st17;
	goto st1;
tr12:
#line 41 "ext/http11_client/http11_parser.rl"
	{ 
    parser->status_code(parser->data, PTR_TO(mark), LEN(mark, p));
  }
	goto st18;
st18:
	if ( ++p == pe )
		goto _out18;
case 18:
#line 424 "ext/http11_client/http11_parser.c"
	goto tr37;
tr37:
#line 23 "ext/http11_client/http11_parser.rl"
	{MARK(mark, p); }
	goto st19;
st19:
	if ( ++p == pe )
		goto _out19;
case 19:
#line 434 "ext/http11_client/http11_parser.c"
	if ( (*p) == 13 )
		goto tr36;
	goto st19;
tr34:
#line 33 "ext/http11_client/http11_parser.rl"
	{ 
    parser->http_field(parser->data, PTR_TO(field_start), parser->field_len, PTR_TO(mark), LEN(mark, p));
  }
	goto st20;
tr36:
#line 37 "ext/http11_client/http11_parser.rl"
	{ 
    parser->reason_phrase(parser->data, PTR_TO(mark), LEN(mark, p));
  }
	goto st20;
st20:
	if ( ++p == pe )
		goto _out20;
case 20:
#line 454 "ext/http11_client/http11_parser.c"
	if ( (*p) == 10 )
		goto st21;
	goto st1;
st21:
	if ( ++p == pe )
		goto _out21;
case 21:
	switch( (*p) ) {
		case 13: goto st2;
		case 33: goto tr20;
		case 124: goto tr20;
		case 126: goto tr20;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto tr20;
		} else if ( (*p) >= 35 )
			goto tr20;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto tr20;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto tr20;
		} else
			goto tr20;
	} else
		goto tr20;
	goto st1;
tr20:
#line 25 "ext/http11_client/http11_parser.rl"
	{ MARK(field_start, p); }
	goto st22;
st22:
	if ( ++p == pe )
		goto _out22;
case 22:
#line 494 "ext/http11_client/http11_parser.c"
	switch( (*p) ) {
		case 33: goto st22;
		case 58: goto tr8;
		case 124: goto st22;
		case 126: goto st22;
	}
	if ( (*p) < 45 ) {
		if ( (*p) > 39 ) {
			if ( 42 <= (*p) && (*p) <= 43 )
				goto st22;
		} else if ( (*p) >= 35 )
			goto st22;
	} else if ( (*p) > 46 ) {
		if ( (*p) < 65 ) {
			if ( 48 <= (*p) && (*p) <= 57 )
				goto st22;
		} else if ( (*p) > 90 ) {
			if ( 94 <= (*p) && (*p) <= 122 )
				goto st22;
		} else
			goto st22;
	} else
		goto st22;
	goto st1;
tr8:
#line 27 "ext/http11_client/http11_parser.rl"
	{ 
    parser->field_len = LEN(field_start, p);
  }
	goto st23;
st23:
	if ( ++p == pe )
		goto _out23;
case 23:
#line 529 "ext/http11_client/http11_parser.c"
	if ( (*p) == 32 )
		goto st24;
	goto st1;
st24:
	if ( ++p == pe )
		goto _out24;
case 24:
	if ( (*p) == 13 )
		goto tr34;
	goto tr38;
tr38:
#line 31 "ext/http11_client/http11_parser.rl"
	{ MARK(mark, p); }
	goto st25;
st25:
	if ( ++p == pe )
		goto _out25;
case 25:
#line 548 "ext/http11_client/http11_parser.c"
	if ( (*p) == 13 )
		goto tr34;
	goto st25;
	}
	_out1: cs = 1; goto _out; 
	_out2: cs = 2; goto _out; 
	_out26: cs = 26; goto _out; 
	_out3: cs = 3; goto _out; 
	_out4: cs = 4; goto _out; 
	_out5: cs = 5; goto _out; 
	_out6: cs = 6; goto _out; 
	_out7: cs = 7; goto _out; 
	_out8: cs = 8; goto _out; 
	_out9: cs = 9; goto _out; 
	_out10: cs = 10; goto _out; 
	_out11: cs = 11; goto _out; 
	_out12: cs = 12; goto _out; 
	_out13: cs = 13; goto _out; 
	_out14: cs = 14; goto _out; 
	_out15: cs = 15; goto _out; 
	_out16: cs = 16; goto _out; 
	_out17: cs = 17; goto _out; 
	_out18: cs = 18; goto _out; 
	_out19: cs = 19; goto _out; 
	_out20: cs = 20; goto _out; 
	_out21: cs = 21; goto _out; 
	_out22: cs = 22; goto _out; 
	_out23: cs = 23; goto _out; 
	_out24: cs = 24; goto _out; 
	_out25: cs = 25; goto _out; 

	_out: {}
	}
#line 126 "ext/http11_client/http11_parser.rl"

  parser->cs = cs;
  parser->nread += p - (buffer + off);

  assert(p <= pe && "buffer overflow after parsing execute");
  assert(parser->nread <= len && "nread longer than length");
  assert(parser->body_start <= len && "body starts after buffer end");
  assert(parser->mark < len && "mark is after buffer end");
  assert(parser->field_len <= len && "field has length longer than whole buffer");
  assert(parser->field_start < len && "field starts after buffer end");

  if(parser->body_start) {
    /* final \r\n combo encountered so stop right here */
    
#line 597 "ext/http11_client/http11_parser.c"
#line 140 "ext/http11_client/http11_parser.rl"
    parser->nread++;
  }

  return(parser->nread);
}

int httpclient_parser_finish(httpclient_parser *parser)
{
  int cs = parser->cs;

  
#line 610 "ext/http11_client/http11_parser.c"
#line 151 "ext/http11_client/http11_parser.rl"

  parser->cs = cs;

  if (httpclient_parser_has_error(parser) ) {
    return -1;
  } else if (httpclient_parser_is_finished(parser) ) {
    return 1;
  } else {
    return 0;
  }
}

int httpclient_parser_has_error(httpclient_parser *parser) {
  return parser->cs == httpclient_parser_error;
}

int httpclient_parser_is_finished(httpclient_parser *parser) {
  return parser->cs == httpclient_parser_first_final;
}
