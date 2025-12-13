FROM perl:5.42

# Make directories that we expect to use as mountpoints during Kubernetes deployments
RUN mkdir -p /data /run/secrets

# Default debian image tries to clean APT after an install. We're using
# cache mounts instead, so we do not want to clean it.
RUN rm -f /etc/apt/apt.conf.d/docker-clean

RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
  --mount=type=cache,target=/var/cache/apt,sharing=locked \
    echo "deb http://deb.debian.org/debian trixie-backports main" >> /etc/apt/sources.list.d/trixie-backports.list \
    && apt update && apt install -y \
        libdbd-mysql-perl \
        libdbd-sqlite3-perl

RUN --mount=type=cache,target=/root/.cpanm \
  cpanm --notest \
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
    Sereal \
    Test::More \
    YAML::XS

RUN --mount=type=cache,target=/root/.cpanm \
  cpanm --notest \
    DBD::MariaDB \
    Mojo::mysql


COPY ./wait-for-it.sh /root/wait-for-it.sh
RUN chmod +x /root/wait-for-it.sh

# Add all distributions in the "dist" directory before any other
# distributions. This way we can have pre-release modules in our dev
# environment. Do this last to take advantage of as much caching as
# possible above, even though any changes here mean rebuilding every
# downstream image...
COPY ./dist /root/dist
RUN --mount=type=cache,target=/root/.cpanm \
  bash -vlc 'for DIST in /root/dist/*; do \
        echo "Building pre-release: $DIST"; \
        cpanm -v --notest $DIST; \
    done && rm -rf /root/dist'

RUN mkdir /app
WORKDIR /app
