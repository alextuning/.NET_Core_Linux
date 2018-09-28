%define home_dir	%{_home_dir}/rpmbuild
%define source		%{home_dir}/SOURCES
%define name		my_app1
%define winname		my_app1.Front
%define release		%{_release}
%define version		%{_version}
%define buildroot	%{home_dir}/BUILDROOT/%{name}-%{version}-%{release}-root

Summary:	my_app1.Front application
Name:		%{name}
Version:	%{version}
Release:	%{release}
License:	FTC
BuildArch:	x86_64
Provides:   my_app1

Requires:	dotnet

%description
my_app1.Front application.

%install
mkdir -p %{buildroot}/opt/app
mkdir -p %{buildroot}/etc/systemd/system
unzip %{source}/%{winname}.zip -d %{buildroot}/opt/app/%{name}
rm %{buildroot}/opt/app/%{name}/wwwroot/employer/assets/config/appsettings*.json
cp %{source}/%{name}.service %{buildroot}/etc/systemd/system/

%pre
case "$1" in
  1) # Initial installation
    useradd -c "My app" -U -M -d /opt/app/%{name} -s /bin/bash %{name}
  ;;
  2) # Upgrade
    # do nothing
  ;;
esac

%post
%systemd_post %{name}.service

%preun
%systemd_preun %{name}.service

%postun
case "$1" in
  0) # This is a yum remove.
    userdel %{name}
  ;;
  1) # This is a yum upgrade.
    # do nothing
  ;;
esac

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

%files
%defattr(-, %{name}, %{name})
/opt/app/%{name}
%attr(0640, root, root)
/etc/systemd/system/%{name}.service
