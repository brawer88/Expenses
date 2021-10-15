package Models::Database;
use strict;
use warnings;

use Models::Utilities;
use Models::User;
use Models::Envelope;
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

#  GetEnvelope
#  Abstract: Gets envelope by name and user id
#  params: ( $UID, $name )
#  returns: $envelope - the model rep of this envelope
sub GetEnvelope
{
    my ( $self, $UID, $name ) = @_;
    my $envelope = Models::Envelope->new();

    my $rs = resultset('Envelope')->single(
        {
            userid => $UID,
            name   => $name
        }
    );

    if ( !$rs )
    {
        return $envelope;
    }

    $envelope->name( $rs->name );
    $envelope->balance( $rs->balance );
    $envelope->goalamount( $rs->goalamount );
    $envelope->autofillamount( $rs->autofillamount );
    $envelope->duedate( $rs->duedate );
    $envelope->bankid( $rs->get_column("bankid") );

    return $envelope;
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
            order_by => { -asc => 'duedate, name' }
        }
    );

    while ( my $row = $rs->next )
    {
        my $balance = $row->get_column("balance");
        my $name    = $row->get_column("name");
        my $goal    = $row->get_column("goalamount");
        my $bankid  = $row->get_column("bankid");
        my $due     = $row->get_column("duedate");

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
                        <table id="envelope" class="table table-bordered"><thead><tr><th>Due</th><th>Balance</th><th>Goal</th><th>Bank</th></tr></thead>
                        <tbody><tr><td data-label="due">$due</td><td data-label="balance">$balance</td><td data-label="goal">$goal</td><td data-label="bank">$bank</td></tr></tbody></table>
                        <a href="/envelope/$name" class="btn btn-primary"><i class="fa fa-cog" aria-hidden="true"></i></a>
                        <a href="/transaction/$name" class="btn btn-primary"><i class="fa fa-plus-circle" aria-hidden="true"></i></a>
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
        },
        {
            order_by => { -asc => 'duedate' }
        }
    );

    $html .= qq~<select class="form-control" name="transfer_to" id="transfer_to">
    ~;

    while ( my $row = $rs->next )
    {
        my $balance = $row->get_column("balance");
        my $name    = $row->get_column("name");
        my $goal    = $row->get_column("goalamount");
        my $id      = $row->get_column("envelopeid");

        $html .= qq~
                    <option value="$id">$name | Balance: $balance | Goal: $goal</option>
                ~;
    }

    $html .= qq~</select>~;

    return $html;
}

#  GetAutofillCheckboxes
#  Abstract: Gets envelopes for an html checkbox group
#  params: ( $UID )
#  returns: $html - the html rep of all envelopes belonging to the user
sub GetAutofillCheckboxes
{
    my ( $self, $UID ) = @_;
    my $html;

    my $rs = resultset('Envelope')->search(
        {
            userid => $UID
        },
        {
            order_by => { -asc => 'duedate' }
        }
    );

    while ( my $row = $rs->next )
    {
        my $balance  = $row->get_column("balance");
        my $name     = $row->get_column("name");
        my $goal     = $row->get_column("goalamount");
        my $autofill = $row->get_column("autofillamount");
        my $id       = $row->get_column("envelopeid");
        my $due      = $row->get_column("duedate");

        if ( $autofill > 0 )
        {
            $html .= qq~<div class="form-check">
                <input class="form-check-input" type="checkbox" value="$id" id="$name+$id" name="autofill">
                <label class="form-check-label" for="$name+$id">
                    <table><tr class="auto"><td>$name Due: $due</td><td>Balance: $balance</td><td>Goal: $goal</td><td>Autofill: $autofill</td></tr></table>
                </label>
            </div>
             ~;
        }

    }

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
        },
        {
            order_by => { -asc => 'bankid' }
        }
    );

    $html .= qq~
                <div class="jumbotron jumbotron-fluid">
                    <div class="container">
                        <h1 class="display-4">Banks</h1>
                            <table id="envelope" class="table"><thead><tr><th>Name</th><th>Balance</th><th>Unallocated</th></tr></thead><tbody>
            ~;
    while ( my $row = $rs->next )
    {
        my $balance = $row->get_column("balance");
        my $unall   = $row->get_column("unallocated");
        my $name    = $row->get_column("name");

        $html .= qq~
                    <tr><td data-label="Name">$name</td><td data-label="Balance">$balance</td><td data-label="Unallocated">$unall</td></tr>
                 ~;
    }

    $html .= qq~</tbody></table></div></div>~;

    return $html;
}

#  GetBanksSelect
#  Abstract: Gets Banks as select
#  params: ( $UID )
#  returns: $html - the html rep of all banks belonging to the user
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
        $html .= qq~
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

#  GetBanksSelected
#  Abstract: Gets Banks
#  params: ( $UID, $bank_id )
#  returns: $html - the html rep of all banks belonging to the user, with an option selected
sub GetBanksSelected
{
    my ( $self, $UID, $bank_id ) = @_;
    my $html;

    my $rs = resultset('Bank')->search(
        {
            userid => $UID
        }
    );

    if ($rs)
    {
        $html .= qq~
                <select class="form-control" name="banks" id="banks">
        ~;

        while ( my $row = $rs->next )
        {
            my $unall = $row->get_column("unallocated");
            my $name  = $row->get_column("name");
            my $id    = $row->get_column("bankid");

            my $selected;

            $selected = "selected" if $id == $bank_id;

            $html .= qq~
                        <option $selected value="$id">$name| Unallocated: $unall</option>
                    ~;
        }

        $html .= qq~</select>~;
    }

    return $html;
}

#  AddExpense
#  Abstract: Adds expense to envelope and connected bank
#  params: ( $UID, $name, $amount, $for, $type, $transfer_to )
#  returns: $result - the status of updates
sub AddExpense
{
    my ( $self, $UID, $name, $amount, $for, $type, $transfer_to ) = @_;

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

    my $other_env_rs = resultset('Envelope')->single(
        {
            envelopeid => $transfer_to
        }
    );

    my $other_env    = $other_env_rs->get_column("name");
    my $bank_balance = $bank_rs->get_column("balance");
    my $unallocated  = $bank_rs->get_column("unallocated");

    if ( $type eq "Transfer" && $bank_balance != $unallocated )
    {
        $for = qq~Transfer from $name to $other_env.~;
        if ( $transfer_to == $bankid )
        {
            my $new_unallocated = $unallocated + $amount;
            $bank_rs->update(
                {
                    unallocated => $new_unallocated
                }
            );
        }
        else
        {
            my $new_bank_balance = $bank_balance - $amount;
            $bank_rs->update(
                {
                    balance => $new_bank_balance
                }
            );
        }

    }
    elsif ( $type eq "Expense" )
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
#  params: ( $UID, $transfer_to, $amount, $for, $type, $name )
#  returns: $result - the status of updates
sub AddIncome
{
    my ( $self, $UID, $transfer_to, $amount, $for, $type, $name ) = @_;

    my $envelope_rs = resultset('Envelope')->single(
        {
            userid     => $UID,
            envelopeid => $transfer_to
        }
    );

    my $other_envelope_rs = resultset('Envelope')->single(
        {
            userid => $UID,
            name   => $name
        }
    );

    my $transfer_from = $other_envelope_rs->get_column("bankid");

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

    my $bank_balance = $bank_rs->get_column("balance");
    my $unallocated  = $bank_rs->get_column("unallocated");

    if ( $type eq "Transfer" )
    {
        if ( $transfer_from == $transfer_to )
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
#  params: ( $UID, $name, $balance, $goal, $bank_id, $autofill, $due )
#  returns: $result - the result
sub AddEnvelope
{
    my ( $self, $UID, $name, $balance, $goal, $bank_id, $autofill, $due ) = @_;

    my $result = resultset('Envelope')->create(
        {
            userid         => $UID,
            name           => $name,
            balance        => 0,
            goalamount     => $goal,
            autofillamount => $autofill,
            bankid         => $bank_id
        }
    );

    if ( $due ne "none" )
    {
        $result->update(
            {
                duedate => $due
            }
        );
    }

    my $env_id = $result->get_column("envelopeid");

    FillEnvelope( $self, $UID, $env_id, $bank_id, $balance );

    return $result;
}

#  sub FillEnvelope
#  Abstract: Adds to envelope from unallocated
#  params: ( $UID, $env_id, $bank_id, $amount )
#  returns: $result - the result
sub FillEnvelope
{
    my ( $self, $UID, $env_id, $bank_id, $amount ) = @_;

    my $bank_rs = resultset('Bank')->single(
        {
            bankid => $bank_id
        }
    );

    my $bank_name   = $bank_rs->get_column("name");
    my $unallocated = $bank_rs->get_column("unallocated");

    my $new_unallocated = $unallocated - $amount;
    $bank_rs->update(
        {
            unallocated => $new_unallocated
        }
    );

    my $envelope_rs = resultset('Envelope')->single(
        {
            envelopeid => $env_id
        }
    );

    my $name        = $envelope_rs->get_column("name");
    my $balance     = $envelope_rs->get_column("balance");
    my $new_balance = $balance + $amount;

    $envelope_rs->update(
        {
            balance => $new_balance
        }
    );

    my $for  = qq~Filling $name from unallocated in $bank_name.~;
    my $time = localtime->mysql_datetime;

    my $transaction_rs = resultset('Transaction')->create(
        {
            envelopeid => $env_id,
            bankid     => $bank_id,
            userid     => $UID,
            amount     => $amount,
            reason     => $for,
            date       => $time,
            type       => "Income"
        }
    );
}

#  sub GetTransactions
#  Abstract: Gets transactions in desc order
#  params: ( $UID, $env_id, $bank_id, $amount )
#  returns: $result - the result
sub GetTransactions
{
    my ( $self, $UID ) = @_;
    my $html;

    my $rs = resultset('Transaction')->search(
        {
            userid => $UID,
        },
        {
            order_by => { -desc => 'transactionid' }
        }
    );

    $html .= qq~<div class="container">
                    <table id="trans" style="fant-size:9px" class="table table-bordered"><thead><tr><th>Envelope</th><th>Date</th><th>Amount</th><th>Reason</th></tr></thead><tbody>
            ~;
    while ( my $row = $rs->next )
    {
        my $type    = $row->get_column("type");
        my $date    = $row->get_column("date");
        my $amount  = $row->get_column("amount");
        my $reason  = $row->get_column("reason");
        my $env_id  = $row->get_column("envelopeid");
        my $bank_id = $row->get_column("bankid");

        if ($env_id)
        {
            my $env_rs = resultset("Envelope")->single(
                {
                    envelopeid => $env_id
                }
            );

            my $env_name = $env_rs->get_column("name");
            $html .= qq~
                    <tr><td>$env_name</td><td>$date</td><td>$amount\n$type</td><td>$reason</td></tr>
                 ~;
        }
        else
        {
            my $bank_rs = resultset("Bank")->single(
                {
                    bankid => $bank_id
                }
            );

            my $bank_name = $bank_rs->get_column("name");

            $html .= qq~
                    <tr><td>$bank_name</td><td>$date</td><td>$amount\n$type</td><td>$reason</td></tr>
                 ~;

        }

    }

    $html .= qq~</tbody></table></div>~;

    return $html;

}

sub AddPaycheck
{
    my ( $self, $UID, $bank_id, $amount, $autofill ) = @_;

    my $bank_rs = resultset('Bank')->single(
        {
            bankid => $bank_id
        }
    );

    my $bank_name   = $bank_rs->get_column("name");
    my $unallocated = $bank_rs->get_column("unallocated");
    my $balance     = $bank_rs->get_column("balance");

    my $new_unallocated = $unallocated + $amount;
    $bank_rs->update(
        {
            unallocated => $new_unallocated,
            balance     => $balance + $amount
        }
    );

    my $for  = qq~Paycheck deposited into $bank_name.~;
    my $time = localtime->mysql_datetime;

    my $transaction_rs = resultset('Transaction')->create(
        {
            bankid => $bank_id,
            userid => $UID,
            amount => $amount,
            reason => $for,
            date   => $time,
            type   => "Income"
        }
    );

    foreach my $env_id (@$autofill)
    {
        my $envelope_rs = resultset('Envelope')->single(
            {
                envelopeid => $env_id
            }
        );

        my $amount = $envelope_rs->get_column("autofillamount");

        FillEnvelope( $self, $UID, $env_id, $bank_id, $amount );
    }

    return $transaction_rs;
}

#  CreateAccount
#  Abstract: Creates account and logs in user
#  params: ( $username, $password, $fname, $lname )
#  returns: $user
sub CreateAccount
{
    my ( $self, $username, $password, $fname, $lname ) = @_;

    my $password_hash = passphrase($password)->generate;

    my $result = 0;

    my $check_rs = resultset("User")->single(
        {
            username => $username
        }
    );

    if ($check_rs)
    {
        return $result;
    }

    my $rs = resultset("User")->create(
        {
            username  => $username,
            password  => $password_hash->rfc2307(),
            firstname => $fname,
            lastname  => $lname
        }
    );

    my $user = Login( $self, $username, $password );

    return $user;
}

#  UserOwns
#  Abstract: Returns boolean for if the user owns an envelope with this name
#  params: ( $UID, $name )
#  returns: $owns
sub UserOwns
{
    my ( $self, $UID, $name ) = @_;
    my $owns = FALSE;

    my $rs = resultset('Envelope')->single(
        {
            userid => $UID,
            name   => $name
        }
    );

    $owns = TRUE if $rs;

    return $owns;
}

#  UpdateEnvelope
#  Abstract: Updates a user envelope
#  params: ( $UID, $name, $balance, $goal, $bank_id, $autofill, $due )
#  returns: $user
sub UpdateEnvelope
{
    my ( $self, $UID, $name, $balance, $goal, $bank_id, $autofill, $due ) = @_;

    my $result = 0;

    my $rs = resultset('Envelope')->single(
        {
            userid => $UID,
            name   => $name
        }
    );

    my $current_bank             = $rs->get_column("bankid");
    my $current_envelope_balance = $rs->get_column("balance");

    my $difference = $current_envelope_balance - $balance;

    my $new_balance = $balance;
    my $new_bank_unallocated;

    my $bank_rs = resultset("Bank")->single(
        {
            bankid => $current_bank
        }
    );

    my $current_bank_unallocated = $bank_rs->get_column("unallocated");

    if ( $current_bank != $bank_id )
    {
        #free all money tied to this envelope
        $new_bank_unallocated = $current_bank_unallocated + $current_envelope_balance;
        $bank_rs->update(
            {
                unallocated => $new_bank_unallocated
            }
        );

        $new_balance = 0;
    }
    if ( $current_envelope_balance != $balance )
    {
        # free difference into unallocated or out of unallocated
        $new_bank_unallocated = $current_bank_unallocated + $difference;
        $bank_rs->update(
            {
                unallocated => $new_bank_unallocated
            }
        );
    }

    $rs->update(
        {
            name           => $name,
            balance        => $new_balance,
            goalamount     => $goal,
            bankid         => $bank_id,
            autofillamount => $autofill,
        }
    );

    if ( $due ne "none" )
    {
        $rs->update(
            {
                duedate => $due
            }
        );
    }

    $result = 1;

    return $result;
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
