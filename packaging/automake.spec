Name:           automake
BuildRequires:  autoconf >= 2.69
BuildRequires:  bison
BuildRequires:  gcc-c++
BuildRequires:  xz
Requires:       autoconf >= 2.69
Version:        1.12.1
Release:        0
Summary:        A Program for Automatically Generating GNU-Style Makefile.in Files
License:        GPL-2.0+
Group:          Development/Tools/Building
Url:            http://www.gnu.org/software/automake
Source:         automake-%{version}.tar.xz
Source1:        automake-rpmlintrc
BuildArch:      noarch

%description
Automake is a tool for automatically generating "Makefile.in" files
from "Makefile.am" files.  "Makefile.am" is a series of "make" macro
definitions (with rules occasionally thrown in).  The generated
"Makefile.in" files are compatible with the GNU Makefile standards.

%prep
%setup -q -n automake-%{version}

%build
sh bootstrap.sh
%configure --docdir=%{_docdir}/%{name}
make %{?_smp_mflags}


%install
make install DESTDIR=%{buildroot}
mkdir -p %{buildroot}/etc %{buildroot}/usr/share/aclocal
echo /usr/local/share/aclocal >%{buildroot}/etc/aclocal_dirlist
ln -s ../../../etc/aclocal_dirlist %{buildroot}/usr/share/aclocal/dirlist
mkdir -p %{buildroot}%{_mandir}/man1
install -m644 COPYING %{buildroot}%{_docdir}/%{name}
# info's dir file is not auto ignored on some systems
rm -rf %{buildroot}%{_infodir}/dir

%post
%install_info --info-dir=%{_infodir} %{_infodir}/automake.info.gz

%postun
%install_info_delete --info-dir=%{_infodir} %{_infodir}/automake.info.gz


%files
%license COPYING
%defattr(-,root,root)
%doc %{_docdir}/%{name}
%{_bindir}/*
%doc %{_infodir}/*.gz
%doc %{_mandir}/man1/*
%{_datadir}/aclocal*
%{_datadir}/automake-*
%config /etc/aclocal_dirlist

%changelog
