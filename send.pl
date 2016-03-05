#!/usr/bin/env perl

use v5.20;
use utf8;
use strict;
use warnings;

use HTTP::Tiny;
use JSON;

my $id       = "3e80ba4a-9358-41bf-979d-7d6b319ec6f6";
my $hostname = "bebop-i5";
my $data     = "Hello World\n";

my $url = "http://localhost:3000/log.json";

my $json = {
    id       => $id,
    hostname => $hostname,
    data     => $data,
};

my $res = HTTP::Tiny->new->post(
    $url,
    {
        content => JSON::encode_json($json),
        headers => {
            "content-type" => "application/json",
        },
    }
);

use DDP; p $res;
