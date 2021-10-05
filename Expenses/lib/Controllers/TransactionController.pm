package Controllers::TransactionController;
use Dancer2 appname => 'Expenses';
use Models::Utilities;

my $db = Models::Database->new();

prefix '/transaction';

get '/:envelope' => sub {
    my $name = param('envelope');
    my $user = session('user') // Models::User->new();


    template 'transaction' => {
        'title'     => 'Expenses: Add Transaction',
        'logged_in' => $user->logged_in // 0,
        'name'      => $name,
        'msg'       => get_flash()
    };
};


prefix '/';
1;