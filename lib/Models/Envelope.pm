package Models::Envelope;
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
#  envelopeid
#------------------------------------------
sub envelopeid
{
    my ( $self, $value ) = @_;
    if ( @_ == 2 )
    {
        $self->{ envelopeid } = $value;
    }
    return $self->{ envelopeid };
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
#  goalamount
#------------------------------------------
sub goalamount
{
    my ( $self, $value ) = @_;
    if ( @_ == 2 )
    {
        $self->{ goalamount } = $value;
    }
    return $self->{ goalamount };
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
#  autofillamount
#------------------------------------------
sub autofillamount
{
    my ( $self, $value ) = @_;
    if ( @_ == 2 )
    {
        $self->{ autofillamount } = $value;
    }
    return $self->{ autofillamount };
}

#------------------------------------------
#  duedate
#------------------------------------------
sub duedate
{
    my ( $self, $value ) = @_;
    if ( @_ == 2 )
    {
        $self->{ duedate } = $value;
    }
    return $self->{ duedate };
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
