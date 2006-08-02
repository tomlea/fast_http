/**
 * Copyright (c) 2005 Zed A. Shaw
 * You can redistribute it and/or modify it under the same terms as Ruby.
 */

#include "ruby.h"
#include "ext_help.h"
#include <assert.h>
#include <string.h>
#include <ctype.h>

static VALUE mRFuzz;
static VALUE cFuzzRnd;
static VALUE eFuzzRndError;


/**
 * We use one source of ArcFour data for now.  This means that things aren't
 * thread safe yet, but since the ArcFour is just for the current weaker implementation
 * I'm not investing any more time making it thread safe.
 */
static struct
{
  unsigned char  i,j;                        /* ArcFour variables */
  unsigned char  sbox[256];                  /* ArcFour s-box */
} ArcFour;


/** 
 * call-seq:
 *    rnd.seed -> rnd
 *
 * Returns a String of random bytes of length that you can use 
 * for generating randomness.  It uses the ArcFour cipher to 
 * make the randomness, so the same seeds produce the same 
 * random bits, and the randomness is reasonably high quality.
 *
 * Don't use this for secure random generation.  It probably would
 * work if you seeded from a /dev/random that worked, but don't
 * blame me if you get hacked.
 *
 * The main motiviation for using ArcFour without automated reseed
 * is to produce lots of random bytes quickly, make them high enough
 * quality for good random tests, and to make sure that we can replay
 * possible sequences if there's a sequence that we want to test.
 */
VALUE FuzzRnd_data(VALUE self, VALUE length)
{

  unsigned int n;
  unsigned char a,b;
  size_t len = 0;
  VALUE data;
  char *p = NULL;

  REQUIRE_TYPE(length, T_FIXNUM);

  len = FIX2INT(length);
  data = rb_str_buf_new(len);
  p = RSTRING(data)->ptr;
  rb_str_resize(data, len);

  for (n=0;n<len;n++)             /* run the ArcFour algorithm as long as it needs */
  {
    ArcFour.i++;
    a     =         ArcFour.sbox[ArcFour.i];
    ArcFour.j = (unsigned char) (ArcFour.j + a);     /* avoid MSVC picky compiler warning */
    b     =         ArcFour.sbox[ArcFour.j];
    ArcFour.sbox[ArcFour.i] = b;
    ArcFour.sbox[ArcFour.j] = a;
    p[n]  = ArcFour.sbox[(a+b) & 0xFF];
  }

  return data;
}


/** 
 * call-seq:
 *    rnd.seed -> rnd
 *
 * Seeds the global ArcFour random generator with the given seed.  The same seeds
 * should produce the exact same stream of random data so that you can get 
 * large amounts of randomness but replay possible interactions using just 
 * an initial key.
 *
 * This function also doubles as the FuzzRnd.initialize method since they
 * do nearly the same thing.
 *
 * Taken from http://www.mozilla.org/projects/security/pki/nss/draft-kaukonen-cipher-arcfour-03.txt
 * sample code, but compared with the output of the ArcFour implementation in
 * the Phelix test code to make sure it is the same initialization.  The main
 * difference is that this init takes an arbitrary keysize while the original
 * Phelix ArcFour only took a 32bit key.
 *
 * Returns itself so you can seed and then get data easily.
 */
VALUE FuzzRnd_seed(VALUE self, VALUE data) {

  unsigned int t, u;
  unsigned int keyindex;
  unsigned int stateindex;
  unsigned char *state;
  unsigned int counter;
  char *key = NULL;
  size_t key_len = 0;

  REQUIRE_TYPE(data, T_STRING);

  key = RSTRING(data)->ptr;
  key_len = RSTRING(data)->len;

  state = ArcFour.sbox;
  ArcFour.i = 0;
  ArcFour.j = 0;

  for (counter = 0; counter < 256; counter++)
    state[counter] = counter;

  keyindex = 0;
  stateindex = 0;
  for (counter = 0; counter < 256; counter++)
  {
    t = state[counter];
    stateindex = (stateindex + key[keyindex] + t) & 0xff;
    u = state[stateindex];
    state[stateindex] = t;
    state[counter] = u;
    if (++keyindex >= key_len)
      keyindex = 0;
  }

  return self;
}

void Init_fuzzrnd()
{
  mRFuzz = rb_define_module("RFuzz");

  eFuzzRndError = rb_define_class_under(mRFuzz, "FuzzRndError", rb_eIOError);

  cFuzzRnd = rb_define_class_under(mRFuzz, "FuzzRnd", rb_cObject);
  rb_define_method(cFuzzRnd, "initialize", FuzzRnd_seed, 1);
  rb_define_method(cFuzzRnd, "seed", FuzzRnd_seed,1);
  rb_define_method(cFuzzRnd, "data", FuzzRnd_data,1);
}


