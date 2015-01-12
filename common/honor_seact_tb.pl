#!/usr/bin/perl -w

use CGI qw(fatalsToBrowser);

my $prog = "cgi-bin/honor_seact_tb.pl";
my $gQ = new CGI;
my $title = "Honor_Seact's resource synchronization";
my $html;

print $gQ->header( -type=>'text/html', -charset=>'UTF-8' );

my $act1 = $gQ->param('s1')|| 'unchecked';
my $act2 = $gQ->param('s2')|| 'unchecked';
my $act3 = $gQ->param('s3')|| 'unchecked';

my $sub = $gQ->param('Submit');

$gQ->print( "<html><head><title>$title</title></head>" );
$gQ->print( '<body>' );
unless( defined $sub)
{
        &first_page;
}
else {
     if( $act1 eq 'checked' )
        {
                my $info = qx( /home/honor/cgi-bin/rsync_honor_seact_ziyuan.sh );
                open(DATA,">>/home/honor/rsync_honor_seact_ziyuan.logs") || die "Couldn't open file rsync_honor_seact_ziyuan.logs, $!";
                print DATA "$info\n";
                $gQ->print( "$info\n" );
        }

}

$gQ->print( "</body></html>\n" );


################
# function
################

sub first_page
{
        my $html;
$html .= q|
<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
    <TR>
      <TD height="50"><div align="center" class="STYLE1 STYLE2">
        <h1 class="STYLE3">数字天空运维部文件同步系统  Honor_Seact</h1>
      </div></TD>
    </TR>
    <TR>  
        <TD width=250 colSpan=2><HR bgColor=#FF3300 noShade SIZE=1></TD>
    </TR> 
</TABLE>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#e8e8e8">
<tr bgColor=#343434 >
        <FONT size=4 face="Verdana, Arial, Helvetica, sans-serif" color=#ffffff>|.$title.q|</FONT>
</TR>

<table border cellpadding=2 align="center" width=1000>
<tr bgcolor="#e2e8e0"><th align=left width=30%><center>选择服务器</center></th> <th align=left width=20%><center>游戏</center></th> <th align=left width=30%><center>上传目录</center></th></tr> |;

$html .= q|
<form id="form1" name="form1" method="get" action="/| . $prog . q|">
  <label>

<tr>
<td><input name="s1" type="checkbox" id="s1" value="checked" />54.169.170.61</td>
<td><center>资源服同步更新</center></td>
<td><center> IP:54.169.170.61 - /home/honor/online/source/rs_honor_seact</center></td>
</tr>

<td><center><input type="submit" name="Submit" value="同步" /></center></td>
<td><font color=red><center>N/A</center></font></td>
<td><font color=red><center>N/A</center></font></td>
  </label>
</form>
<p />
|;

        $gQ->print( "$html" );
return 
}


