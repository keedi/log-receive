#!/usr/bin/env perl

use utf8;
use Mojolicious::Lite;

use Mojo::JSON;
use Path::Tiny;
use UUID::Tiny;

app->defaults( %{ plugin "Config" => { default => { log_dir => "process_id", } } } );

my $LOG_DIR = app->config->{log_dir};
app->log->info("log dir: $LOG_DIR");
path($LOG_DIR)->mkpath;

post "/id" => [ format => ["json"] ] => sub {
    my $c = shift;

    my $id = UUID::Tiny::create_uuid_as_string(UUID::Tiny::UUID_V1);

    $c->respond_to(
        json => {
            json => {
                id  => $id,
                ret => 1,
            },
        },
    );
};

post "/log" => sub {
    my $c = shift;

    my $json = $c->req->json;

    my $id       = $json->{"id"};
    my $hostname = $json->{"hostname"};
    my $data     = $json->{"data"};

    my $file = path("$LOG_DIR/$id/$hostname");
    $file->touchpath;
    $file->append_utf8($data);

    $c->respond_to(
        json => {
            json => {
                ret => 1,
            },
        },
    );
};

app->start;

__DATA__

@@ not_found.html.ep
% layout 'default';
% title '404 Not Found';
<h1>404 Not Found</h1>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
