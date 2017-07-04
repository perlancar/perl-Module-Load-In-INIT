package Module::Load::In::INIT;

# DATE
# VERSION

use strict;
#use warnings; # warns: Too late to run INIT block

my @mods;

sub import {
    my $pkg = shift;

    push @mods, @_;
}

INIT {
    for my $mod (@mods) {
        my @import_args;
        if ($mod =~ s!=(.*)!!) {
            @import_args = split /;/, $1;
        }
        (my $mod_pm = "$mod.pm") =~ s!::!/!g;
        require $mod_pm;
        $mod->import(@import_args);
    }
}

1;

#ABSTRACT: Load modules in INIT phase

=head1 SYNOPSIS

In the command-line:

 % perl -MModule::Load::In::INIT=Mod::One,Mod::Two='Some;Import;Args' somescript.pl

C<Mod::One> and C<Mod::Two> will be loaded in the INIT phase instead of BEGIN
phase.


=head1 DESCRIPTION

This module can load (or perhaps defer loading) modules in the INIT phase
instead of the BEGIN phase. One use-case where it is useful: monkey-patching a
module (using a L<Module::Patch>-based module) in a fatpacked script (see
L<Module::FatPack> or L<App::FatPacker>), e.g.:

 % perl -MSome::Module::Patch::Foo fatpacked-script.pl

C<Some::Module::Patch::Foo> will try to load C<Some::Module> then patch it. This
might fail when module is loaded by the fatpack handler (which is a require
hook) as by the time C<Some::Module::Patch::Foo> is loaded, the fatpack handler
has not been setup yet, and C<Some::Module> is not available elsewhere (on the
filesystem). This, however, works:

 % perl -MModule::Load::In::INIT=Some::Module::Patch::Foo fatpacked-script.pl

Loading of C<Some::Module::Patch::Foo> (and by extension, C<Some::Module>) is
deferred to the INIT phase. By that time, the fatpack require hook has been
setup and C<Some::Module> can be (or might already be) loaded by it.

=cut
