#!/usr/bin/env plackup
use v5.28.0;
use strict;
use warnings;
use feature qw{ signatures };

use Data::Dumper;
use JSON;
use Log::Dispatchouli;
use Mail::BIMI 3.20230913;
use Mail::BIMI::Indicator;
use Mail::BIMI::Prelude;
use Mail::BIMI::Record;
use Mail::DMARC;
use Plack::Builder;
use Plack::Request;
use Plack::Response;
use POSIX;

my $logger = Log::Dispatchouli->new({
  ident     => 'bimi-validator',
  facility  => 'daemon',
  to_stdout => 0,
  debug     => 0,
});

if ($<==0){
  my $uid = scalar getpwnam('nobody');
  my $gid = scalar getgrnam('nogroup');
  POSIX::setuid($uid);
  POSIX::setgid($gid);
}

my $app_check_domain = sub{
  my ($env) = @_;
  state $j = JSON->new->canonical->utf8;
  my $request = Plack::Request->new($env);
  my $domain = $request->parameters->{domain};
  my $selector = $request->parameters->{selector} // 'default';
  my $log_detail = {
    domain => $domain,
    selector => $selector,
  };
  my $response = Plack::Response->new;
  eval {
    my $data = check_domain($domain,$selector);
    my $payload = eval{ $j->encode($data) };
    $response->body($payload);
    $response->status(200);
    $log_detail->{error} = $data->{error} if exists $data->{error};
    $log_detail->{result} = $data->{result}->{result} if $data->{result} && $data->{result}->{result};
    $log_detail->{authentication_results} = $data->{result}->{authentication_results} if $data->{result} && $data->{result}->{authentication_results};
  };
  if ( my $error = $@ ) {
    $log_detail->{eval_error} = $error;
    $response->status(500);
  }

  $logger->log( $j->encode( $log_detail ) );
  return $response->finalize;
};

builder {
  mount "/checkdomain" => $app_check_domain,
};


sub check_domain($domain,$selector) {
  my $profile = 'SVG_1.2_PS';
  my $dmarc = Mail::DMARC::PurePerl->new;

  return { error => 'Invalid domain' } if !$domain;
  return { error => 'Invalid domain' } if !($domain=~/\./);
  return { error => 'Invalid domain' } if $domain=~/\.\./;

  eval {
    $dmarc->header_from($domain);
    $dmarc->validate;
    $dmarc->result->result('pass');
  };
  if ( my $error = $@ ) {
    return { error => $error };
  }
  my $bimi = Mail::BIMI->new(
    dmarc_object => $dmarc,
    domain => $domain,
    selector => $selector,
    options => {
      svg_profile => $profile,
      cache_backend => 'Null',
    },
  );

  my $record = $bimi->record;
  $record->is_valid;

  my $struct = {
    request => {
      domain => $domain,
      selector => $selector,
    },
    response => {
      record => undef,
    }
  };

  if ( $record ) {
    $struct->{response}->{record} = {
      retrieved_record => $record->retrieved_record,
      retrieved_domain => $record->retrieved_domain,
      retrieved_selector => $record->retrieved_selector,
      version => $record->version,
      is_valid => $record->is_valid ? JSON::true : JSON::false,
      location => undef,
      authority => undef,
      errors => add_errors($record),
      warnings => $record->warnings,
    };

    my $location = $record->location;
    if ( $location ) {
      $struct->{response}->{record}->{location} = {
        uri => $location->uri,
        is_valid => $location->is_valid ? JSON::true : JSON::false,
        indicator => undef,
        errors => add_errors($location),
      };
      my $indicator = $location->indicator;
      if ( $indicator ) {
        $struct->{response}->{record}->{location}->{indicator} = {
          uri => $indicator->uri,
          is_valid => $indicator->is_valid ? JSON::true : JSON::false,
          errors => add_errors($indicator),
        };
      }
    }

    my $authority = $record->authority;
    if ( $authority ) {
      $struct->{response}->{record}->{authority} = {
        uri => $authority->uri,
        is_valid => $authority->is_valid ? JSON::true : JSON::false,
        vmc => undef,
        errors => add_errors($authority),
      };
      my $vmc = $authority->vmc;
      if ( $vmc ) {
        $struct->{response}->{record}->{authority}->{vmc} = {
          uri => $vmc->uri,
          is_valid => $vmc->is_valid ? JSON::true : JSON::false,
          indicator => undef,
          subject => $vmc->subject//undef,
          not_before => $vmc->not_before//undef,
          not_after => $vmc->not_after//undef,
          issuer => $vmc->issuer//undef,
          is_expired => $vmc->is_expired ? JSON::true : JSON::false,
          is_valid_alt_name => $vmc->is_valid_alt_name ? JSON::true : JSON::false,
          has_valid_usage => $vmc->has_valid_usage ? JSON::true : JSON::false,
          is_cert_valid => $vmc->is_cert_valid ? JSON::true : JSON::false,
          mark_type => $vmc->mark_type // 'none',
          is_allowed_mark_type => $vmc->is_allowed_mark_type ? JSON::true : JSON::false,
          chain => undef,
          errors => add_errors($vmc),
        };
        my $chain = $vmc->chain_object;
        if ( $chain ) {
          $chain->is_valid; # Do validation
          my @certs;
          foreach my $cert ( $chain->cert_object_list->@* ) {
            my $i = $cert->index;
            my $obj = $cert->x509_object;
            my $cert_struct = {
              index => $i,
              is_valid => $cert->is_valid ? JSON::true : JSON::false,
              is_experimental => undef,
              subject => undef,
              not_before => undef,
              not_after => undef,
              issuer => undef,
              is_expired => undef,
              alt_name => undef,
              has_logotype_extn => undef,
              has_valid_usage => undef,
              is_valid_to_root => undef,
              valid_to_root_via => undef,
              errors => add_errors($chain),
            };
            if ( $obj ) {
              $cert_struct->{subject} = $obj->subject//undef;
              $cert_struct->{not_before} = $obj->notBefore//undef;
              $cert_struct->{not_after} = $obj->notAfter//undef;
              $cert_struct->{issuer} = $obj->issuer//undef;
              $cert_struct->{is_expired} = $obj->checkend(0) ? JSON::true : JSON::false;
              my $exts = eval{ $obj->extensions_by_oid() };
              if ( $exts ) {
                my $alt_name = exists $exts->{'2.5.29.17'} ? $exts->{'2.5.29.17'}->to_string : undef;
                $cert_struct->{alt_name} = $alt_name//undef;
                $cert_struct->{has_logotype_extn} = exists($exts->{&LOGOTYPE_OID}) ? JSON::true : JSON::false;
              }
              $cert_struct->{has_valid_usage} = $cert->has_valid_usage ? JSON::true : JSON::false;
            }
            $cert_struct->{is_experimental} = $cert->is_experimental ? JSON::true : JSON::false;
            $cert_struct->{is_valid_to_root} = $cert->is_valid_to_root ? JSON::true : JSON::false;
            if ( $cert->is_valid_to_root ) {
              $cert_struct->{valid_to_root_via} = $cert->validated_by_id;;
            }
            push @certs, $cert_struct;
            $struct->{response}->{record}->{authority}->{vmc}->{chain} = {
              is_valid => $chain->is_valid ? JSON::true : JSON::false,
              certs => \@certs,
            };
          }

          my $indicator = $vmc->indicator;
          if ( $indicator ) {
            $struct->{response}->{record}->{authority}->{vmc}->{indicator} = {
              uri => $indicator->uri,
              is_valid => $indicator->is_valid ? JSON::true : JSON::false,
              errors => add_errors($indicator),
            };
          }
        }

      }
    }

  }

  my $result = $bimi->result;
  my $authentication_results = "Authentication-Results: authservid.example.com; ".$result->get_authentication_results;
  my $headers = $result->headers;
  $struct->{result} = {
    result => $result->result,
    authentication_results => $authentication_results,
    header => {},
  };
  foreach my $header ( sort keys $headers->%* ) {
    $struct->{result}->{header}->{$header} = $headers->{$header};
  }

  $bimi->finish;

  return $struct;

}

sub add_errors($data) {
  my @errors;
  foreach my $error ( $data->errors->@* ) {
    my $error_code = $error->code;
    my $error_text = $error->description;
    my $error_detail = $error->detail // '';
    push @errors, {
      code => $error->code,
      description => $error->description,
      detail => $error->detail,
    };
  }
  return \@errors;
}

