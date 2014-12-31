#!/usr/bin/perl
use strict;
use warnings;

use LWP::Curl;
use XML::LibXML;

use Data::Dumper;

my $lwpcurl = LWP::Curl->new(user_agent=> "GRC Bells & Whistles (https://github.com/ckeboss/GRC-Bells-and-Whistles)");
my $content = $lwpcurl->get("https://www.grc.com/securitynow.htm");

my $counter;

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

foreach my $cont ($xpc->findnodes('//p')) {
    my $node_test = $cont->getChildrenByTagName('a');
    $node_test->foreach( \&loop_though );
}

sub loop_though {
    if($_->getAttribute('href') =~ /\/sn\/past\//) {
        print "Page: https://www.grc.com".$_->getAttribute('href')."\n\n";
        
        my $content = $lwpcurl->get("https://www.grc.com".$_->getAttribute('href'));

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
                #print $transcript;
            }
        }
    }
}

print "Final count: $counter\n";