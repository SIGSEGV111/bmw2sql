Name:           bmw2sql
Summary:        Streams BMW CarData MQTT events into a PostgreSQL table. Minimal, single-script pipeline
Group:          Applications/Databases
Distribution:   openSUSE
License:        GPLv3
URL:            https://www.brennecke-it.net
BuildArch:      noarch
BuildRequires:  go-md2man easy-rpm
Requires:       amp-bash-commons

%description
Streams BMW CarData MQTT events into a PostgreSQL table. Minimal, single-script pipeline.

%prep
%setup -q -n bmw2sql

%build
make %{?_smp_mflags} VERSION="Version %{version}"

%install
make install BINDIR=%{buildroot}%{_bindir} MANDIR="%{buildroot}%{_mandir}"

%files
%{_bindir}/bmw2sql.sh
%{_mandir}/man1/bmw2sql.1.gz

%changelog
