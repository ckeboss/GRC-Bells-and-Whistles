#!/usr/bin/perl
use strict;
use warnings;

use LWP::Curl;
use XML::LibXML;
use Data::Dumper;

my $lwpcurl = LWP::Curl->new();
my $content = $lwpcurl->get("https://www.grc.com/securitynow.htm");

my $parser = XML::LibXML->new();
$parser->recover_silently(1);
my $doc = $parser->load_html(string => $content);

my $xpc = XML::LibXML::XPathContext->new($doc);
foreach my $cont ($xpc->findnodes('//img[@src="/image/textfile.gif"]')) {
	my $msg = $cont->getParentNode->getAttribute("href");
	# Gets the href of all text transcripts
	if($msg) {
		print $msg;
		print "\n\n";
	}
}
# 

# 
# my $dom = XML::LibXML->load_xml(string => $content);
# 
# print Dumper($dom);
# for my $node ($dom->findnodes('/category/event/@name')) {
# 	say $node->toString;
# }