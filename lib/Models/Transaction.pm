package Models::Transaction;
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
#  amount
#------------------------------------------
sub amount
{
    my ( $self, $value ) = @_;
    if ( @_ == 2 )
    {
        $self->{ amount } = $value;
    }
    return $self->{ amount };
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
#  transactionid
#------------------------------------------
sub transactionid
{
    my ( $self, $value ) = @_;
    if ( @_ == 2 )
    {
        $self->{ transactionid } = $value;
    }
    return $self->{ transactionid };
}

#------------------------------------------
#  reason
#------------------------------------------
sub reason
{
    my ( $self, $value ) = @_;
    if ( @_ == 2 )
    {
        $self->{ reason } = $value;
    }
    return $self->{ reason };
}

#------------------------------------------
#  date
#------------------------------------------
sub date
{
    my ( $self, $value ) = @_;
    if ( @_ == 2 )
    {
        $self->{ date } = $value;
    }
    return $self->{ date };
}

#------------------------------------------
#  type
#------------------------------------------
sub type
{
    my ( $self, $value ) = @_;
    if ( @_ == 2 )
    {
        $self->{ type } = $value;
    }
    return $self->{ type };
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
