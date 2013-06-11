package POFOMD;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    Unicode::Encoding
    ConfigLoader
    Static::Simple
/;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in pofomd.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'POFOMD',

    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    default_view                                => 'TT',
    enable_catalyst_header                      => 1,      # Send X-Catalyst header
    'View::TT'                                  => {
        ENCODING => 'utf-8',
        INCLUDE_PATH => [
            map { __PACKAGE__->path_to(@$_) }[
                qw(root
                    src)
            ],
            [qw(root lib)]
        ]
    }
);

# Start the application
__PACKAGE__->setup();

=head1 NAME

POFOMD - Catalyst based application

=head1 SYNOPSIS

    script/pofomd_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<POFOMD::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Thiago Rondon

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
