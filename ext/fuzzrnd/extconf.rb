require 'mkmf'

dir_config("fuzzrnd")
have_library("c", "main")

create_makefile("fuzzrnd")
