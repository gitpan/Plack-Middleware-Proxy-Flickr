
use strict;
use warnings;



use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'Proxy images from Flickr',
  'AUTHOR' => 'Panu Ervamaa <pnu@cpan.org>',
  'BUILD_REQUIRES' => {
    'English' => '0',
    'Test::More' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31'
  },
  'DISTNAME' => 'Plack-Middleware-Proxy-Flickr',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'NAME' => 'Plack::Middleware::Proxy::Flickr',
  'PREREQ_PM' => {
    'CHI' => '0',
    'Carp' => '0',
    'Data::Dumper' => '0',
    'Flickr::Simple2' => '0',
    'Moose' => '0',
    'Plack::Middleware' => '0',
    'Plack::Util' => '0',
    'Try::Tiny' => '0',
    'URI::Escape' => '0'
  },
  'VERSION' => '0.001',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



