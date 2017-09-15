% if ( $domain =~ /bytemark[.]co[.]uk$/ ) {
export LC_ALL="en_GB.utf8"      # bytemark only supports this locale
% }
if [[ -x /opt/local/perlbrew/etc/bashrc ]]; then
    source /opt/local/perlbrew/etc/bashrc
fi
eval $( perl -Mlocal::lib )

