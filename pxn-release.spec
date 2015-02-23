Name            : pxn-extras
Summary         : Installs the PoiXson yum repository
Version         : 1.0.%{BUILD_NUMBER}
Release         : 1
BuildArch       : noarch
Provides        : pxnyum
Prefix          : %{_sysconfdir}/yum.repos.d
%define  _rpmfilename  %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm

Group           : System Environment/Base
License         : GPL
Packager        : PoiXson <support@poixson.com>
URL             : http://yum.poixson.com/



### Packages ###
%package stable
Summary         : Installs the PoiXson yum stable repository
Provides        : pxnyum

%package testing
Summary         : Installs the PoiXson yum testing repository
Provides        : pxnyum

%package private
Summary         : Only for use on the PoiXson internal network
Provides        : pxnyum



%description
Installs the PoiXson yum repository.

%description stable
Installs the PoiXson stable yum repository. This repo receives fewer updates, however is considered more stable than testing.

%description testing
Installs the PoiXson testing yum repository. This repo receives frequent updates, however bugs are much more common.

%description private
Installs the PoiXson private yum repository. This repo is restricted to the PoiXson internal network, and only provides a performance benefit to these systems.



# avoid centos 5/6 extras processes on contents (especially brp-java-repack-jars)
%define __os_install_post %{nil}

# disable debug info
# % define debug_package %{nil}



### Prep ###
%prep



### Build ###
%build
# build repo files
%{__cat} <<EOF >pxn-stable.repo

[pxn-extras-stable]
name=PoiXson Yum Extras (stable)
baseurl=http://yum.poixson.com/extras-stable/
enabled=1
skip_if_unavailable=1
gpgcheck=0
priority=11

EOF
%{__cat} <<EOF >pxn-testing.repo

[pxn-extras-testing]
name=PoiXson Yum Extras (testing)
baseurl=http://yum.poixson.com/extras-testing/
enabled=1
skip_if_unavailable=1
metadata_expire=1h
gpgcheck=0
priority=1

EOF
%{__cat} <<EOF >pxn-private.repo

[pxn-extras-private]
name=PoiXson Yum Extras (private)
baseurl=http://yum.poixson.com/extras-private/
enabled=1
metadata_expire=1h
gpgcheck=0
priority=1

EOF



### Install ###
%install
echo
echo "Install.."
# delete existing rpm's
%{__rm} -fv "%{_rpmdir}/%{name}-"*.noarch.rpm
# create directories
%{__install} -d -m 0755 \
	"${RPM_BUILD_ROOT}%{prefix}" \
		|| exit 1
# copy .repo file
%{__install} -m 0644 \
	"pxn-stable.repo" \
	"${RPM_BUILD_ROOT}%{prefix}/pxn-stable.repo" \
		|| exit 1
%{__install} -m 0644 \
	"pxn-testing.repo" \
	"${RPM_BUILD_ROOT}%{prefix}/pxn-testing.repo" \
		|| exit 1
%{__install} -m 0644 \
	"pxn-private.repo" \
	"${RPM_BUILD_ROOT}%{prefix}/pxn-private.repo" \
		|| exit 1



%check



%clean
if [ ! -z "%{_topdir}" ]; then
	%{__rm} -rf --preserve-root "%{_topdir}" \
		|| echo "Failed to delete build root!"
fi



### Files ###
%files stable
%defattr(-,root,root,-)
%{prefix}/pxn-stable.repo

%files testing
%defattr(-,root,root,-)
%{prefix}/pxn-testing.repo

%files private
%defattr(-,root,root,-)
%{prefix}/pxn-private.repo

