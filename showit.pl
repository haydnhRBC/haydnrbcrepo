#!/usr/bin/perl

# Parse Form Contents

&parse_form;
&get_date;
&show_form;





sub get_date {

   @days = ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
   @months = ('January','February','March','April','May','June','July',
	      'August','September','October','November','December');
   ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
   if ($hour < 10) { $hour = "0$hour"; }
   if ($min < 10) { $min = "0$min"; }
   if ($sec < 10) { $sec = "0$sec"; }
   $date = "$days[$wday], $months[$mon] $mday, 19$year at $hour\:$min\:$sec";

}





sub parse_form {

   if ($ENV{'REQUEST_METHOD'} eq 'GET') {
      # Split the name-value pairs
      @pairs = split(/&/, $ENV{'QUERY_STRING'});
   }

   elsif ($ENV{'REQUEST_METHOD'} eq 'POST') {
      # Get the input
      read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
      # Split the name-value pairs
      @pairs = split(/&/, $buffer);
   }

   else {
      &error('request_method');
   }

   foreach $pair (@pairs) {
      ($name, $value) = split(/=/, $pair);
      $name =~ tr/+/ /;
      $name =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
      $value =~ tr/+/ /;
      $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;

      # If they try to include server side includes, erase them, so they
      # arent a security risk if the html gets returned.  Another 
      # security hole plugged up.

      $value =~ s/<!--(.|\n)*-->//g;

      # Create two associative arrays here.  One is a configuration array
      # which includes all fields that this form recognizes.  The other
      # is for fields which the form does not recognize and will report 
      # back to the user in the html return page and the e-mail message.
      # Also determine required fields.

      if ($name eq 'windowtitle' || $name eq 'redirect' || $name eq 'formnamecolor' || $name eq 'formname' && ($value)) {
        $CONFIG{$name} = $value;
      }

      else {

        if ($FORM{$name} && ($value)) {
	      $FORM{$name} = "$FORM{$name}, $value";
        }

        elsif ($value) {
          $FORM{$name} = $value;
        }

      }

   }

}




sub show_form {

   print "Content-type\:text/html\n\n";
   print "<head><title>$CONFIG{'windowtitle'}</title></head>\n";
   print "<body bgcolor='#DDDDFF'>";
   print "<center><table border=1 width=500>";
   print "<tr><td align=center colspan=2 bgcolor='#CCCCCC'>";
   print "<font size=5 face=arial color=$CONFIG{'formnamecolor'}>$CONFIG{'formname'}</font></td></tr>\n";
   print "<tr><td align=center colspan=2 bgcolor='#CCCCCC'><font face=arial size=1>Date Received: $date<br>\n";
   print "Posted by: $ENV{'REMOTE_HOST'}</font></td></tr>\n";
   print "<tr><td align=center colspan=2 bgcolor='#000000'><font size=2 face=arial color='#FFFFFF'>Content of form follows</font></td></tr>";
   print "<TR><TD align=center bgcolor='#8888AA'><FONT face=arial SIZE=2 COLOR='#FFFFFF'>NAME</FONT></TD>";
   print "<TD align=center bgcolor='#8888AA'><FONT face=arial SIZE=2 COLOR='#FFFFFF'>VALUE(S)</FONT></TD></TR>";

   foreach $key (keys %FORM) {
     # Print the name and value pairs in FORM array to html.
     print "<tr valign=top><td bgcolor='#FFFFFF' width=40%><font face=arial size=2>$key</font></td><td bgcolor='#FFFFFF' width=60%><font face=arial size=2>$FORM{$key}</font></td></tr>\n\n";
   }

   print "</table></center>";
   print "</body>";

}
