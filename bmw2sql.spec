Name:           bmw2sql
Summary:        Streams BMW CarData MQTT events into a PostgreSQL table.
Group:          Applications/Databases
Distribution:   openSUSE
License:        GPLv3
URL:            https://www.brennecke-it.net
BuildArch:      noarch
BuildRequires:  go-md2man easy-rpm
Requires:       amp-bash-commons stdin2sql krenewd
Recommends:     bmw-token-manager

%description
Streams BMW CarData MQTT events into a PostgreSQL table.
Minimal, single-script pipeline.

%prep
%setup -q -n %{name}

%build
make %{?_smp_mflags} VERSION="Version %{version}"

%install
make install CONFDIR=%{buildroot}%{_sysconfdir} BINDIR=%{buildroot}%{_bindir} MANDIR="%{buildroot}%{_mandir}" UNITDIR="%{buildroot}%{_unitdir}"

%files
%{_bindir}/%{name}.sh
%{_mandir}/man1/%{name}.1.gz
%{_unitdir}/%{name}@.service
%config(noreplace) %{_sysconfdir}/%{name}.conf

%changelog
