% if ( $domain =~ /bytemark[.]co[.]uk$/ ) {
export LC_ALL="en_GB.utf8"      # bytemark only supports this locale
% }
source /opt/local/perlbrew/etc/bashrc
eval $( perl -Mlocal::lib )
