
workers=1



##################################################



repo_base=`pwd`



function updaterepo() {

	### pxn-extras ###
	echo
	echo
	echo " ### ${1} ###"
	echo "Generating repo metadata.."
	echo
	echo "[ ${1} / noarch ]"
	mkdir -pv "${repo_base}/${1}/noarch/packages/" || exit 1
	( cd "${repo_base}/${1}/noarch/" && createrepo --workers=${workers} . ) \
		|| { echo "Failed to update ${1} noarch repo!"; exit 1; }
	echo
	echo "[ ${1} / i386 ]"
	mkdir -pv "${repo_base}/${1}/i386/packages/" || exit 1
	( cd "${repo_base}/${1}/i386/" && createrepo --workers=${workers} . ) \
		|| { echo "Failed to update ${1} i386 repo!"; exit 1; }
	echo
	echo "[ ${1} / x86_64 ]"
	mkdir -pv "${repo_base}/${1}/x86_64/packages/" || exit 1
	( cd "${repo_base}/${1}/x86_64/" && createrepo --workers=${workers} . ) \
		|| { echo "Failed to update ${1} x86_64 repo!"; exit 1; }
	echo
	echo "Finished updating pxn-extras!"
	echo
	echo

	# update latest.rpm link
	if [ ${1} == "extras" ]; then
		latestrpm=`ls "${repo_base}/extras/noarch/packages/pxn-extras-"?.*.noarch.rpm 2>/dev/null | sort --version-sort -r | head -1`
		if [[ -z ${latestrpm} ]]; then
			echo "*** latest.rpm target not found!!! ***"
		else
			ln -sf "$latestrpm" "${repo_base}/latest.rpm" \
				|| echo "*** Failed to create symlink latest.rpm ***"
		fi
		echo
	fi

	# chown files
	chowned=`chown -Rcf pxn. "${repo_base}" | wc -l`
	if [ $chowned -gt 0 ]; then
		echo "Updated owner of ${chowned} files"
	fi

	echo
	echo "Finished updating ${1}!"
	echo
	echo
}



if [ -z ${1} ] || [ ${1} == "--help" ]; then
	echo
	echo "Updates the yum repositories hosted on a web server."
	echo
	echo "  --all          Update all repositories"
	echo "  --stable       Update only the stable repo"
	echo "  --testing      Update only the testing repo"
	echo "  --private      Update only the private repo"
	echo
	echo "Usage:  sh update.sh --all"
	echo
	exit 1
fi



# parse arguments
for i in "$@"; do
	case "$i" in
	--all)
		updaterepo "extras"
		updaterepo "extras-testing"
		updaterepo "extras-private"
	;;
	--stable)
		updaterepo "extras"
	;;
	--testing)
		updaterepo "extras-testing"
	;;
	--private)
		updaterepo "extras-private"
	;;
	*)
		echo "Unknown argument: ${1}"
		exit 1
	;;
	esac
done

