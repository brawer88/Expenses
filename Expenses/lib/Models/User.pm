package Models::User;
use strict;
use warnings;

#------------------------------------------
#  Constructor
#------------------------------------------
sub new
{
    my ( $class, %args ) = @_;
    my $self = \%args;

    bless $self, $class;
    return $self;
}

#------------------------------------------
#  UID
#------------------------------------------
sub UID
{
    my ( $self, $value ) = @_;
    if ( @_ == 2 )
    {
        $self->{ UID } = $value;
    }
    return $self->{ UID };
}

#------------------------------------------
#  username
#------------------------------------------
sub username
{
    my ( $self, $value ) = @_;
    if ( @_ == 2 )
    {
        $self->{ username } = $value;
    }
    return $self->{ username };
}

#------------------------------------------
#  firstname
#------------------------------------------
sub firstname
{
    my ( $self, $value ) = @_;
    if ( @_ == 2 )
    {
        $self->{ firstname } = $value;
    }
    return $self->{ firstname };
}

#------------------------------------------
#  lastname
#------------------------------------------
sub lastname
{
    my ( $self, $value ) = @_;
    if ( @_ == 2 )
    {
        $self->{ lastname } = $value;
    }
    return $self->{ lastname };
}

#------------------------------------------
#  usertype
#------------------------------------------
sub usertype
{
    my ( $self, $value ) = @_;
    if ( @_ == 2 )
    {
        $self->{ usertype } = $value;
    }
    return $self->{ usertype };
}

#------------------------------------------
#  logged_in
#------------------------------------------
sub logged_in
{
    my ( $self, $value ) = @_;
    if ( @_ == 2 )
    {
        $self->{ logged_in } = $value;
    }
    return $self->{ logged_in };
}

#------------------------------------------
#   Destructor
#------------------------------------------
sub DESTROY
{
    # DEFINE Destructors
    my ($self) = @_;
    print "User Destroyed :P";
}

1;
