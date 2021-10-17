package Models::Bank;
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
#  name
#------------------------------------------
sub name
{
    my ( $self, $value ) = @_;
    if ( @_ == 2 )
    {
        $self->{ name } = $value;
    }
    return $self->{ name };
}

#------------------------------------------
#  balance
#------------------------------------------
sub balance
{
    my ( $self, $value ) = @_;
    if ( @_ == 2 )
    {
        $self->{ balance } = $value;
    }
    return $self->{ balance };
}


#------------------------------------------
#  bankid
#------------------------------------------
sub bankid
{
    my ( $self, $value ) = @_;
    if ( @_ == 2 )
    {
        $self->{ bankid } = $value;
    }
    return $self->{ bankid };
}




#------------------------------------------
#   Destructor
#------------------------------------------
sub DESTROY
{
    # DEFINE Destructors
    my ($self) = @_;
}

1;
