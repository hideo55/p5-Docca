use strict;
use utf8;
use Test::More tests => 1;
use Docca;
use Data::Section::Simple;

my $docca = Docca->new(
	from => { Xatena => { converter => { hatena_compatible => 1 }, }, },
	to   => { HTML   => {}, },
	tx   => {
		path  => [ Data::Section::Simple->new->get_data_section ],
		cache => 0
	},
);

my $in = <<'__XATENA__';
*TEST
**Foo
- hoge
--fuga
>|perl|
use strict;
use warnings;

sub foo {
	my $bar = shift;
	return;
}
||<
__XATENA__

my $res = $docca->convert( source => $in, template => 'default.tx' )
	->from('Xatena')->to('HTML');

ok $res;

__DATA__
@@ default.tx
<html>
<head>
<style type="text/css">
.str { color: #080; }
.kwd { color: #008; }
.com { color: #800; }
.typ { color: #606; }
.lit { color: #066; }
.pun { color: #660; }
.pln { color: #000; }
.tag { color: #008; }
.atn { color: #606; }
.atv { color: #080; }
.dec { color: #606; }
pre.prettyprint { padding: 2px; border: 1px solid #888; }
h4{
	margin: 1px;
}
ul{
	margin-top: 1px;
	margin-bottom: 5px;
}
pre.code{
	background-color: #dedede;
}
</style>
<script type="text/javascript" src="http://google-code-prettify.googlecode.com/svn/trunk/src/prettify.js"></script> 
<script type="text/javascript">
(function(onload) { // load
  if (window.addEventListener) {
      window.addEventListener('load', onload, false);
  } else if (window.attachEvent) {
      window.attachEvent('onload',  onload, false);
  } else {
      window.onload = onload;
  }
})(function() {
  if (typeof prettyPrint === 'function') {
    var pre = document.getElementsByTagName('pre');
    for (var n = pre.length; n --> 0;) {
      pre[n].className = (pre[n].className || '').split(/[ \t\r\n]+/).concat('prettyprint').join(' ')
    }
    prettyPrint();
  }
});
</script>
</head>
<body>
<: $body :>
</body>
</html>
