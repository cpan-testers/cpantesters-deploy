% if ( $domain =~ /bytemark[.]co[.]uk$/ ) {
export LC_ALL="en_GB.utf8"      # bytemark only supports this locale
% }
if [[ -e /opt/local/perlbrew/etc/bashrc ]]; then
    source /opt/local/perlbrew/etc/bashrc
fi
eval $( perl -I$HOME/perl5/lib/perl5 -Mlocal::lib )

