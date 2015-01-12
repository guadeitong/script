#!/usr/bin/perl -w

use CGI qw(fatalsToBrowser);

my $prog = "cgi-bin/lzll_adr_ptg_tb.pl";
my $gQ = new CGI;
my $title = "Adr_Ptg's resource synchronization";
my $html;

print $gQ->header( -type=>'text/html', -charset=>'Unicode' );

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
                my $info = qx( /home/lzimg/cgi-bin/rsync_lzll_adr_ptg_ziyuan.sh );
                open(DATA,">>rsync_lzll_adr_ptg_ziyuan.logs") || die "Couldn't open file rsync_lzll_adr_ptg_ziyuan.logs, $!";
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
        <h1 class="STYLE3">数字天空运维部文件同步系统  LZLL Adr_Ptg</h1>
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
<td><input name="s1" type="checkbox" id="s1" value="checked" />54.194.52.130</td>
<td><center>龙之力量资源服同步更新</center></td>
<td><center> IP:54.194.52.130 - /home/lzupdate/webapps/lzll_rs_adr/adr_ptg/</center></td>
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


