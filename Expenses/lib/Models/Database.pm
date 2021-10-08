package Models::Database;
use strict;
use warnings;

use Models::Utilities;
use Models::User;
use Dancer2 appname => 'Expenses';
use Dancer2::Plugin::Passphrase;
use Dancer2::Plugin::DBIC;
use Expense::Schema;
use Time::Piece::MySQL;

#------------------------------------------
#  Constructor
#------------------------------------------
sub new
{
    my ($class) = @_;
    my $self = {};

    bless $self, $class;
    return $self;
}

#  Login
#  Abstract: Logs a user in, or returns a null User object
#  params: ( $username, $password )
#  returns: $user - a User object
sub Login
{
    my ( $self, $username, $password ) = @_;

    my $user = Models::User->new();

    my $row = resultset('User')->search(
        {
            username => $username
        }
    )->single;

    return $user if !$row;

    my $firstname     = $row->get_column('firstname');
    my $lastname      = $row->get_column('lastname');
    my $UID           = $row->get_column('userid');
    my $user_password = $row->get_column('password');

    if ( passphrase($password)->matches($user_password) )
    {
        $user->logged_in(TRUE);
        $user->UID($UID);
        $user->username($username);
        $user->firstname($firstname);
        $user->lastname($lastname);
    }
    else
    {
        $user->logged_in(FALSE);
    }
    return $user;
}

#  GetEnvelopes
#  Abstract: Gets envelopes
#  params: ( $UID )
#  returns: $html - the html rep of all envelopes belonging to the user
sub GetEnvelopes
{
    my ( $self, $UID ) = @_;
    my $html;

    my $rs = resultset('Envelope')->search(
        {
            userid => $UID,
        },
        {
            order_by => { -asc => 'bankid' }
        }
    );

    while ( my $row = $rs->next )
    {
        my $balance = $row->get_column("balance");
        my $name    = $row->get_column("name");
        my $goal    = $row->get_column("goalamount");
        my $bankid  = $row->get_column("bankid");

        my $rs2 = resultset('Bank')->search(
            {
                bankid => $bankid
            }
        )->single;

        my $bank = $rs2->get_column("name");

        my $diff = 0;

        $diff = $goal - $balance if $goal > 0;

        $html .= qq~
                <div class="card">
                    <div class="card-header">
                        $name
                    </div>
                    <div class="card-body text-right">
                        <table id="envelope" class="table table-bordered"><thead><tr><th>Balance</th><th>Goal</th><th>Difference</th><th>Bank</th></tr></thead>
                        <tbody><tr><td>$balance</td><td>$goal</td><td>$diff</td><td>$bank</td></tr></tbody></table>
                        <a href="/envelope/$name" class="btn btn-primary">Manage</a>
                        <a href="/transaction/$name" class="btn btn-primary">Add Transaction</a>
                    </div>
                </div>        
        ~;
    }

    return $html;
}

#  GetEnvelopesSelect
#  Abstract: Gets envelopes for an html select
#  params: ( $UID )
#  returns: $html - the html rep of all envelopes belonging to the user
sub GetEnvelopesSelect
{
    my ( $self, $UID ) = @_;
    my $html;

    my $rs = resultset('Envelope')->search(
        {
            userid => $UID
        }
    );

    $html .= qq~<label for="transfer_to">Select the envelope to transfer to:</label>
                <select class="form-control" name="transfer_to" id="transfer_to">
    ~;

    while ( my $row = $rs->next )
    {
        my $balance = $row->get_column("balance");
        my $name    = $row->get_column("name");
        my $goal    = $row->get_column("goalamount");
        my $id      = $row->get_column("envelopeid");

        $html .= qq~
                    <option value="$id">$name| Balance: $balance | Goal: $goal</option>
                ~;
    }

    $html .= qq~</select>~;

    return $html;
}

#  GetBanks
#  Abstract: Gets Banks
#  params: ( $UID )
#  returns: $html - the html rep of all envelopes belonging to the user
sub GetBanks
{
    my ( $self, $UID ) = @_;
    my $html;

    my $rs = resultset('Bank')->search(
        {
            userid => $UID
        }
    );

    $html .= qq~
                <div class="jumbotron jumbotron-fluid">
                    <div class="container">
                        <h1 class="display-4">Banks</h1>
                            <table id="envelope" class="table table-bordered"><thead><tr><th>Name</th><th>Balance</th><th>Unallocated</th></tr></thead><tbody>
            ~;
    while ( my $row = $rs->next )
    {
        my $balance = $row->get_column("balance");
        my $unall   = $row->get_column("unallocated");
        my $name    = $row->get_column("name");

        $html .= qq~
                    <tr><td>$name</td><td>$balance</td><td>$unall</td></tr>
                 ~;
    }

    $html .= qq~</tbody></table></div></div>~;

    return $html;
}

#  GetBanks
#  Abstract: Gets Banks
#  params: ( $UID )
#  returns: $html - the html rep of all envelopes belonging to the user
sub GetBanksSelect
{
    my ( $self, $UID ) = @_;
    my $html;

    my $rs = resultset('Bank')->search(
        {
            userid => $UID
        }
    );

    if ($rs)
    {
        $html .= qq~<label for="banks">Select the Bank this belongs to:</label>
                <select class="form-control" name="banks" id="banks">
        ~;

        while ( my $row = $rs->next )
        {
            my $unall = $row->get_column("unallocated");
            my $name  = $row->get_column("name");
            my $id    = $row->get_column("bankid");

            $html .= qq~
                        <option value="$id">$name| Unallocated: $unall</option>
                    ~;
        }

        $html .= qq~</select>~;
    }

    return $html;
}

#  AddExpense
#  Abstract: Adds expense to envelope and connected bank
#  params: ( $UID, $name, $amount, $for, $type )
#  returns: $result - the status of updates
sub AddExpense
{
    my ( $self, $UID, $name, $amount, $for, $type ) = @_;

    my $envelope_rs = resultset('Envelope')->single(
        {
            userid => $UID,
            name   => $name
        }
    );

    my $balance     = $envelope_rs->get_column("balance");
    my $new_balance = $balance - $amount;

    $envelope_rs->update(
        {
            balance => $new_balance
        }
    );

    my $bankid = $envelope_rs->get_column("bankid");
    my $envid  = $envelope_rs->get_column("envelopeid");

    my $bank_rs = resultset('Bank')->single(
        {
            bankid => $bankid
        }
    );

    my $bank_balance     = $bank_rs->get_column("balance");
    my $unallocated      = $bank_rs->get_column("unallocated");
    

    if ($type eq "Transfer" && $bank_balance != $unallocated)
    {
        my $new_unallocated = $unallocated + $amount;
        $bank_rs->update(
            {
                unallocated => $new_unallocated
            }
        );
    }
    elsif ($type eq "Expense")
    {
        my $new_bank_balance = $bank_balance - $amount;
        $bank_rs->update(
            {
                balance => $new_bank_balance
            }
        );
    }

    my $time = localtime->mysql_datetime;

    my $transaction_rs = resultset('Transaction')->create(
        {
            envelopeid => $envid,
            bankid     => $bankid,
            userid     => $UID,
            amount     => $amount,
            reason     => $for,
            date       => $time,
            type       => $type
        }
    );

}

#  AddIncome
#  Abstract: Adds income to envelope and connected bank
#  params: ( $UID, $transfer_to, $amount, $for, $type )
#  returns: $result - the status of updates
sub AddIncome
{
    my ( $self, $UID, $transfer_to, $amount, $for, $type ) = @_;

    my $envelope_rs = resultset('Envelope')->single(
        {
            userid     => $UID,
            envelopeid => $transfer_to
        }
    );

    my $balance     = $envelope_rs->get_column("balance");
    my $new_balance = $balance + $amount;

    $envelope_rs->update(
        {
            balance => $new_balance
        }
    );

    my $bankid = $envelope_rs->get_column("bankid");
    my $envid  = $envelope_rs->get_column("envelopeid");

    my $bank_rs = resultset('Bank')->single(
        {
            bankid => $bankid
        }
    );

    my $bank_balance     = $bank_rs->get_column("balance");
    my $unallocated      = $bank_rs->get_column("unallocated");
    

    if ($type eq "Transfer")
    {
        my $new_unallocated = $unallocated - $amount;
        $bank_rs->update(
            {
                unallocated => $new_unallocated
            }
        );
    }
    else
    {
        my $new_bank_balance = $bank_balance + $amount;
        $bank_rs->update(
            {
                balance => $new_bank_balance
            }
        );
    }

   
    my $time = localtime->mysql_datetime;

    my $transaction_rs = resultset('Transaction')->create(
        {
            envelopeid => $envid,
            bankid     => $bankid,
            userid     => $UID,
            amount     => $amount,
            reason     => $for,
            date       => $time,
            type       => $type
        }
    );
}

#  GetEnvelopeName
#  Abstract: Adds income to envelope and connected bank
#  params: ( $id)
#  returns: $name - the name of the envelope
sub GetEnvelopeName
{
    my ( $self, $id ) = @_;

    my $envelope_rs = resultset('Envelope')->search(
        {
            envelopeid => $id
        }
    )->single;

    my $name = $envelope_rs->get_column("name");

    return $name;
}

#  sub GetEnvelopeBalance
#  Abstract: Adds income to envelope and connected bank
#  params: ( $UID, $name )
#  returns: $balance - the balance of the envelope
sub GetEnvelopeBalance
{
    my ( $self, $UID, $name ) = @_;

    my $envelope_rs = resultset('Envelope')->search(
        {
            userid => $UID,
            name   => $name
        }
    )->single;

    my $balance = $envelope_rs->get_column("balance");

    return $balance;
}

#  sub AddBank
#  Abstract: Adds bank to user account
#  params: ( $UID, $name, $balance )
#  returns: $result - the result
sub AddBank
{
    my ( $self, $UID, $name, $balance ) = @_;

    my $result = resultset('Bank')->create(
        {
            userid      => $UID,
            name        => $name,
            balance     => $balance,
            unallocated => $balance
        }
    );

    return $result;
}

#  sub AddEnvelope
#  Abstract: Adds envelope to user account
#  params: ( $UID, $name, $balance, $goal, $bank_id, $autofill )
#  returns: $result - the result
sub AddEnvelope
{
    my ( $self, $UID, $name, $balance, $goal, $bank_id, $autofill ) = @_;

    my $result = resultset('Envelope')->create(
        {
            userid         => $UID,
            name           => $name,
            balance        => $balance,
            goalamount     => $goal,
            autofillamount => $autofill,
            bankid         => $bank_id
        }
    );

    return $result;
}

#------------------------------------------
#   Destructor
#------------------------------------------
sub DESTROY
{
    # DEFINE Destructors
    my ($self) = @_;
    print "Database Destroyed :P";
}

1;
