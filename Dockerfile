FROM perl:5.26
RUN cpanm --notest \
    Carton \
    Dist::Zilla \
    Pod::Weaver::Section::Contributors \
    Dist::Zilla::Plugin::Authority \
    Dist::Zilla::Plugin::BumpVersionAfterRelease \
    Dist::Zilla::Plugin::CPANFile \
    Dist::Zilla::Plugin::CheckChangesHasContent \
    Dist::Zilla::Plugin::CopyFilesFromBuild \
    Dist::Zilla::Plugin::GatherDir \
    Dist::Zilla::Plugin::Git::Check \
    Dist::Zilla::Plugin::Git::Commit \
    Dist::Zilla::Plugin::Git::Contributors \
    Dist::Zilla::Plugin::Git::GatherDir \
    Dist::Zilla::Plugin::Git::Push \
    Dist::Zilla::Plugin::Git::Tag \
    Dist::Zilla::Plugin::GithubMeta \
    Dist::Zilla::Plugin::MetaJSON \
    Dist::Zilla::Plugin::MetaNoIndex \
    Dist::Zilla::Plugin::MetaProvides::Package \
    Dist::Zilla::Plugin::MetaResources \
    Dist::Zilla::Plugin::NextRelease \
    Dist::Zilla::Plugin::PodWeaver \
    Dist::Zilla::Plugin::Prereqs \
    Dist::Zilla::Plugin::Readme::Brief \
    Dist::Zilla::Plugin::ReadmeAnyFromPod \
    Dist::Zilla::Plugin::RewriteVersion \
    Dist::Zilla::Plugin::Run::AfterBuild \
    Dist::Zilla::Plugin::Test::Compile \
    Dist::Zilla::Plugin::Test::ReportPrereqs \
    Dist::Zilla::PluginBundle::Basic \
    Dist::Zilla::PluginBundle::Filter \
    Software::License::Perl_5 \
    CPAN::DistnameInfo \
    CPAN::Meta \
    CPAN::Testers::Report \
    Data::FlexSerializer \
    DateTime::Format::SQLite \
    Email::Stuffer \
    ExtUtils::MakeMaker \
    File::Share \
    File::ShareDir::Install \
    File::Spec \
    Import::Base \
    IO::Handle \
    IPC::Open3 \
    JSON::MaybeXS \
    Log::Any \
    Log::Any::Adapter::MojoLog \
    Metabase::User::Profile \
    Mojo::mysql \
    Sereal \
    Test::More \
    YAML::XS

RUN echo "deb http://deb.debian.org/debian stretch-backports main" >> /etc/apt/sources.list.d/stretch-backports.list \
    && apt-get update && apt-get install -y \
        libdbd-mysql-perl \
        libdbd-sqlite3-perl

COPY ./wait-for-it.sh ./wait-for-it.sh
RUN chmod +x ./wait-for-it.sh

# Add all distributions in the "dist" directory before any other
# distributions. This way we can have pre-release modules in our dev
# environment. Do this last to take advantage of as much caching as
# possible above, even though any changes here mean rebuilding every
# downstream image...
COPY ./dist ./dist
RUN bash -vlc 'for DIST in ./dist/*; do \
        echo "Building pre-release: $DIST"; \
        cpanm -v --notest $DIST; \
    done && rm -rf ./dist'
