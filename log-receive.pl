#!/usr/bin/env perl

use utf8;
use Mojolicious::Lite;

use Mojo::JSON;
use Path::Tiny;
use UUID::Tiny;

app->defaults(
    %{ plugin "Config" => {
            default => {
                log_dir => "process_id",
                secrets => [ "2016-03-05 18:04:46 Asia/Seoul" ],
            }
        }
    }
);

my $LOG_DIR = app->config->{log_dir};
app->log->info("log dir: $LOG_DIR");
path($LOG_DIR)->mkpath;

plugin "AssetPack" => { source_paths => [qw( assets )] };

app->asset(
    "app.css" => qw(
        sass/main.scss
        ),
);

app->asset(
    "app.js" => qw(
        http://code.jquery.com/jquery-2.2.0.min.js

        /vendor/Materialize/js/initial.js
        /vendor/Materialize/js/jquery.easing.1.3.js
        /vendor/Materialize/js/animation.js
        /vendor/Materialize/js/velocity.min.js
        /vendor/Materialize/js/hammer.min.js
        /vendor/Materialize/js/jquery.hammer.js
        /vendor/Materialize/js/global.js
        /vendor/Materialize/js/collapsible.js
        /vendor/Materialize/js/dropdown.js
        /vendor/Materialize/js/leanModal.js
        /vendor/Materialize/js/materialbox.js
        /vendor/Materialize/js/parallax.js
        /vendor/Materialize/js/tabs.js
        /vendor/Materialize/js/tooltip.js
        /vendor/Materialize/js/waves.js
        /vendor/Materialize/js/toasts.js
        /vendor/Materialize/js/sideNav.js
        /vendor/Materialize/js/scrollspy.js
        /vendor/Materialize/js/forms.js
        /vendor/Materialize/js/slider.js
        /vendor/Materialize/js/cards.js
        /vendor/Materialize/js/chips.js
        /vendor/Materialize/js/pushpin.js
        /vendor/Materialize/js/buttons.js
        /vendor/Materialize/js/transitions.js
        /vendor/Materialize/js/scrollFire.js
        /vendor/Materialize/js/date_picker/picker.js
        /vendor/Materialize/js/date_picker/picker.date.js
        /vendor/Materialize/js/character_counter.js
        /vendor/Materialize/js/carousel.js

        /coffee/main.coffee
        ),
);

get "/" => "index";

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

post "/log" => [ format => ["json"] ] => sub {
    my $c = shift;

    my $json = $c->req->json;

    my $id       = $json->{"id"};
    my $hostname = $json->{"hostname"};
    my $data     = $json->{"data"};

    my $validation = $c->validation;
    $validation->input($json);
    unless ( $validation->has_data ) {
        $c->respond_to(
            json => {
                status => 400, # bad request
                json   => {
                    ret    => 0,
                    reason => "http body json is required",
                },
            },
        );
    }

    my $hex = qr/[A-Za-z0-9]/;
    $validation->required("id")->like(qr/^$hex{8}-$hex{4}-$hex{4}-$hex{4}-$hex{12}$/);
    $validation->required("hostname");
    $validation->required("data");

    if ( $validation->has_error ) {
        $c->respond_to(
            json => {
                status => 400, # bad request
                json   => {
                    ret    => 0,
                    reason => "invalid parameter: " . join( ", ", @{ $validation->failed } ),
                },
            },
        );
        return;
    }

    my $file = path("$LOG_DIR/$id/$hostname");
    $file->touchpath;
    $file->append_utf8($data);

    $c->respond_to( json => { json => { ret => 1, }, }, );
};

app->secrets( app->config->{secrets} );
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
