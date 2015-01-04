#!/usr/bin/perl
use strict;
use warnings;

use LWP::Curl;
use XML::LibXML;

my $counter;

my $lwpcurl = LWP::Curl->new(user_agent=> "GRC Bells & Whistles (https://github.com/ckeboss/GRC-Bells-and-Whistles)");
my $inital_content = $lwpcurl->get("https://www.grc.com/securitynow.htm");

my $parser = XML::LibXML->new();

$parser->recover_silently(1);
my $doc = $parser->load_html(string => $inital_content);

my $xpc = XML::LibXML::XPathContext->new($doc);

#Inital Page
print "Page: https://www.grc.com/securitynow.htm\n\n";
print_instances("https://www.grc.com/securitynow.htm");

#Get all additional pages
foreach my $cont ($xpc->findnodes('//p')) {
    my $node_test = $cont->getChildrenByTagName('a');
    $node_test->foreach( \&loop_though );
}

print "Final count: $counter\n";


sub print_instances {
	my $url = $_[0];
	
	my $content = $lwpcurl->get($url);

    my $parser = XML::LibXML->new();
    $parser->recover_silently(1);
    my $doc = $parser->load_html(string => $content);
    
    my $xpc = XML::LibXML::XPathContext->new($doc);
    
    foreach my $cont ($xpc->findnodes('//img[@src="/image/textfile.gif"]')) {
    	my $msg = $cont->getParentNode->getAttribute("href");
    	# Gets the href of all text transcripts for a page
    	if($msg) {
    		my $transcript = $lwpcurl->get("https://www.grc.com".$msg);
    		if($transcript =~ /(.{100}bells and whistles.{50})/i) {
    			$counter++;
    			print $1."\n";
    			print "https://www.grc.com".$msg;
    			print "\n\n";
    		}
    	}
    }
}

sub loop_though {
    if($_->getAttribute('href') =~ /\/sn\/past\//) {
        print "Page: https://www.grc.com".$_->getAttribute('href')."\n\n";
        print_instances("https://www.grc.com".$_->getAttribute('href'));
    }
}