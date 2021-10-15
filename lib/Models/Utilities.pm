package Models::Utilities;

require Exporter;
use strict;
our @ISA    = qw(Exporter);
our @EXPORT = qw(
  TRUE
  FALSE
  URLEncode
  URLDecode
  escapeHTML
  msg
  set_flash
  get_flash
  convertLinksToHTML
  convertSnippetLinksToHTML
  printHash
  getDiff
  getLinkInfo
  getDateSelected
);
use constant {
    TRUE              => 1,
    FALSE             => 0,
    MaxRenameAttempts => 25,
};

my $msg;

#------------------------------------------
#  Sets the flash message
#------------------------------------------
sub set_flash
{
    my ($message) = @_;
    $msg = $message;
}

#------------------------------------------
#  Gets the flash message
#------------------------------------------
sub get_flash
{
    my $message = $msg;

    $msg = undef;

    return $message;
}

#------------------------------------------
#  Url encodes a string
#------------------------------------------
sub URLEncode
{
    # extracted from CGI::Util
    my ($to_encode) = @_;
    return undef unless defined($to_encode);

    # force bytes while preserving backward compatibility -- dankogai
    $to_encode = pack( "C*", unpack( "C*", $to_encode ) );
    $to_encode =~ s/([^a-zA-Z0-9_.-])/uc sprintf("%%%02x",ord($1))/eg;

    return $to_encode;
}

#------------------------------------------
#  Url decodes a string
#------------------------------------------
sub URLDecode
{
    my ($value) = @_;
    $value =~ tr/+/ /;
    $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
    return $value;
}

#------------------------------------------
#  Escapes html
#------------------------------------------
sub escapeHTML
{
    # swap in special html character entities (like &amp; and &quot;)
    my ( $str_ref, $contains_html ) = @_;

    die('escapeHTML() - the string to escape must be sent by reference')
      unless ref($str_ref);
    $$str_ref =~ s/&(?!([a-zA-Z]+|#[0-9]+|#x[0-9a-fA-F]+);)/&amp;/go;

    unless ($contains_html)
    {
        $$str_ref =~ s/"/&quot;/go;
        $$str_ref =~ s/</&lt;/go;
        $$str_ref =~ s/>/&gt;/go;
    }

    return;
}

#------------------------------------------
#  Recursively converts links to html
#------------------------------------------
sub convertLinksToHTML
{
    my ( $hashref, $ref_cat_num ) = @_;

    my %hash = %{ $hashref };

    my $html = "";

    foreach my $key ( sort keys %hash )
    {
        my @links;

        if ( ref $hash{ $key } ne ref {} )    ## reached the end of this tree
        {
            @links = @{ $hash{ $key } };
        }
        elsif ($key eq "links"
            || $key eq "None" )               ## reached the end of this tree
        {
            my %h = %{ $hash{ $key } };
            @links = @{ $h{ links } };
        }
        else    ## construct the HTML to append to the current elements
        {
            my $inner_html = convertLinksToHTML( $hash{ $key }, $ref_cat_num );

            if ($inner_html)
            {
                $html .= qq~<li><input type="checkbox" id="list-item-$$ref_cat_num" >
                            <label for="list-item-$$ref_cat_num" class="first">$key</label>
                            <ul>~;
                $$ref_cat_num++;
                $html .= $inner_html;
                $html .= "</ul></li>";
            }

        }

        if ( scalar @links )
        {
            foreach my $name (@links)
            {
                my $encoded = URLEncode($name);
                $html .= qq~<li><a href="/page/$encoded">$name</a></li>~;
            }
        }

    }
    return $html;
}

#------------------------------------------
#  Recursively converts links to html
#------------------------------------------
sub convertSnippetLinksToHTML
{
    my ( $hashref, $ref_cat_num ) = @_;

    my %hash = %{ $hashref };

    my $html = "";

    foreach my $key ( sort keys %hash )
    {
        my @links;

        if ( ref $hash{ $key } ne ref {} )    ## reached the end of this tree
        {
            @links = @{ $hash{ $key } };
        }
        elsif ($key eq "links"
            || $key eq "None" )               ## reached the end of this tree
        {
            my %h = %{ $hash{ $key } };
            @links = @{ $h{ links } };
        }
        else    ## construct the HTML to append to the current elements
        {
            my $inner_html = convertSnippetLinksToHTML( $hash{ $key }, $ref_cat_num );

            if ($inner_html)
            {
                $html .= qq~<li><input type="checkbox" id="list-item-$$ref_cat_num" >
                            <label for="list-item-$$ref_cat_num" class="first">$key</label>
                            <ul>~;
                $$ref_cat_num++;
                $html .= $inner_html;
                $html .= "</ul></li>";
            }

        }

        if ( scalar @links )
        {
            foreach my $name (@links)
            {
                my $encoded = URLEncode($name);
                $html .= qq~<li><a href="/snip/$encoded">$name</a></li>~;
            }
        }

    }
    return $html;
}

#------------------------------------------
#  Prints a hash ref
#------------------------------------------
sub printHash
{
    my ($hashref) = @_;

    my %hash = %{ $hashref };

    foreach my $key ( sort keys %hash )
    {
        if ( ref $hash{ $key } ne ref {} )
        {
            my @arr = @{ $hash{ $key } };
            print "\n\n$key Array: @arr";
        }
        elsif ( $key eq "links" )
        {
            my %h   = %{ $hash{ $key } };
            my @arr = @{ $h{ links } };
            print "\n\n$key Array: @arr";
        }
        else
        {
            print "\n\nGetting children for $key";
            printHash( $hash{ $key } );
        }

    }
}

#  getDiff
#  Abstract: Returns the diff of two strings as one string, using system diff
#  params: ( $new, $old )
#  returns: $diff - the diff of the two
sub getDiff
{
    my ( $new, $old ) = @_;

    my $diff = `printf '%s\n' "$old" >edit
    printf '%s\n' "$new" >head 
    diff -U -1 -swbB --suppress-blank-empty edit head
    rm -f head
    rm -f edit`;

    return $diff if $diff =~ m/identical/;

    my @adiff = split( /(\r\n|\r|\n)/, $diff );

    shift @adiff;    #get rid of the first diff line
    shift @adiff;    #get rid of the second diff line
    shift @adiff;    #get rid of the third diff line
    shift @adiff;    #get rid of the fourth diff line
    shift @adiff;    #get rid of the fifth diff line

    foreach my $line (@adiff)
    {
        if ( $line =~ /(^\-)/ )
        {
            $line =~ s/(\-{1})(<.{1,20}>)*/$2<del>$1/;
            $line =~ s/(<\/.{1,3}>)*$/<\/del>$1$2/;
        }
        if ( $line =~ /(^\+)/ )
        {
            $line =~ s/(\+{1})(<.{1,20}>)*/$2<ins>$1/;
            $line =~ s/(<\/.{1,3}>)*$/<\/ins>$1$2/;
        }
    }

    $diff = join( /(\r\n|\r|\n)/, @adiff );

    return $diff;
}

#  getLinkInfo
#  Abstract: Gets a blurb and a link anchor id for search query
#  params: ( $query, $markdown )
#  returns: { blurbs => (blurbs), ids => (ids) }
sub getLinkInfo
{
    my ( $query, $markdown ) = @_;

    my @blurbs;
    my @ids;

    $_ = $markdown;

    while (/(.{1,60})($query)(.{1,60})/isg)
    {
        my $blurb = "$1$2$3";
        $blurb =~ s/<[^>]*>//gs;
        push @blurbs, $blurb;
    }

    ## remove html tags from blurb
    

    $_ = $markdown;

    while (/(<h1 id=")(.+)(">)(.*)($query)/isg)
    {
        push @ids, $3;
    }


    my %link_info = (
        blurbs => \@blurbs,
        ids    => \@ids
    );

    return \%link_info;
}

#  getDateSelected
#  Abstract: Gets selects with an option selected
#  params: ( $date )
#  returns: $html - the select with option selected
sub getDateSelected
{
    my ( $date ) = @_;

    my $html = qq~<option value="none">None</option>~;

    foreach my $day (1..31)
    {
        my $selected;

        $selected = "selected" if $day == $date;
        $html .= qq~
        <option $selected value="$day">$day</option>~;
    }


    return $html;
}

1;
