package Controllers::TransactionController;
use Dancer2 appname => 'Expenses';
use Models::Utilities;

my $db = Models::Database->new();

prefix '/transaction';

#------------------------------------------
#   Get method for transaction page
#------------------------------------------
get '/view' => sub
{
    my $user = session('user') // Models::User->new();

    my $trans = $db->GetTransactions( $user->UID );

    template 'viewtransactions' => {
        'title'        => 'Expenses: View Transactions',
        'logged_in'    => $user->logged_in // 0,
        'transactions' => $trans,
        'msg'          => get_flash()
    };
};

#------------------------------------------
#   Get method for transaction page
#------------------------------------------
get '/delete' => sub
{
    my $id   = query_parameters->get('t');
    my $user = session('user') // Models::User->new();

    my $trans = $db->GetSingleTransaction( $id );

    my $uid = $user->UID;
    my $tid = $trans->UID;

    print "\n\n $uid == $tid \n\n";
    
    if($uid == $tid)
    {
        my $result = $db->DeleteTransaction($id);

        if ($result)
        {
            set_flash("Transaction deleted.");
        }
        else
        {
            set_flash("Transaction could not be deleted.");
        }
    }
    else
    {
        set_flash("You cannot delete a transaction you don't own.");
    }

    return redirect("/transaction/view");
};


#------------------------------------------
#   Get method for transaction page
#------------------------------------------
get '/:envelope' => sub
{
    my $name = param('envelope');
    my $user = session('user') // Models::User->new();

    my $owns = $db->UserOwns( $user->UID, $name );

    my $envelopes = $db->GetEnvelopesSelect( $user->UID );
    my $balance   = $db->GetEnvelopeBalance( $user->UID, $name );

    template 'transaction' => {
        'title'               => 'Expenses: Add Transaction',
        'logged_in'           => $user->logged_in // 0,
        'name'                => $name,
        'available_envelopes' => $envelopes,
        'balance'             => $balance,
        'owns'                => $owns,
        'msg'                 => get_flash()
    };
};

#------------------------------------------
#   Post method for transaction page
#------------------------------------------
post '/:envelope' => sub
{
    my $name = param('envelope');
    my $user = session('user') // Models::User->new();

    my $type        = body_parameters->get('ExpenseType');
    my $transfer_to = body_parameters->get('transfer_to');
    my $amount      = body_parameters->get('amount');
    my $for         = body_parameters->get('for');
    my $to_name     = $db->GetEnvelopeName($transfer_to);

    my $result =
      $db->AddExpense( $user->UID, $name, $amount, $for, $type, $transfer_to );

    if ( $type eq "Transfer" && $result )
    {
        $for = qq~Transfer from $name to $to_name.~;
        $db->AddIncome( $user->UID, $transfer_to, $amount, $for, $type, $name );
    }

    if ($result)
    {
        set_flash("Transaction is successful");
        return redirect uri_for('/');
    }

    my $envelopes = $db->GetEnvelopesSelect( $user->UID );
    my $balance   = $db->GetEnvelopeBalance( $user->UID, $name );

    template 'transaction' => {
        'title'               => 'Expenses: Add Transaction',
        'logged_in'           => $user->logged_in // 0,
        'name'                => $name,
        'available_envelopes' => $envelopes,
        'balance'             => $balance,
        'msg'                 => "Transaction Failed"
    };
};

prefix '/';
1;