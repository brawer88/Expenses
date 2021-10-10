use utf8;
package Expense::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Expense::Schema::Result::User

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 TABLE: C<User>

=cut

__PACKAGE__->table("User");

=head1 ACCESSORS

=head2 userid

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 password

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 firstname

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 lastname

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "userid",
  { data_type => "bigint", is_auto_increment => 1, is_nullable => 0 },
  "username",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "password",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "firstname",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "lastname",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</userid>

=back

=cut

__PACKAGE__->set_primary_key("userid");

=head1 UNIQUE CONSTRAINTS

=head2 C<Username_UNIQUE>

=over 4

=item * L</username>

=back

=cut

__PACKAGE__->add_unique_constraint("Username_UNIQUE", ["username"]);

=head1 RELATIONS

=head2 banks

Type: has_many

Related object: L<Expense::Schema::Result::Bank>

=cut

__PACKAGE__->has_many(
  "banks",
  "Expense::Schema::Result::Bank",
  { "foreign.userid" => "self.userid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 envelopes

Type: has_many

Related object: L<Expense::Schema::Result::Envelope>

=cut

__PACKAGE__->has_many(
  "envelopes",
  "Expense::Schema::Result::Envelope",
  { "foreign.userid" => "self.userid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 transactions

Type: has_many

Related object: L<Expense::Schema::Result::Transaction>

=cut

__PACKAGE__->has_many(
  "transactions",
  "Expense::Schema::Result::Transaction",
  { "foreign.userid" => "self.userid" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-10-09 21:08:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Hq7asAUvqaqPjsc9YnZS3w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
