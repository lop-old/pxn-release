# sh build-ci.sh  --dl-path=/home/pxn/www/dl/pxn-extras  --yum-path=/home/pxn/www/yum/extras-testing/noarch


# load build_utils.sh script
if [ -e build_utils.sh ]; then
	source ./build_utils.sh
elif [ -e /usr/local/bin/pxn/build_utils.sh ]; then
	source /usr/local/bin/pxn/build_utils.sh
else
	wget https://raw.githubusercontent.com/PoiXson/shellscripts/master/pxn/build_utils.sh \
		|| exit 1
	source ./build_utils.sh
fi


NAMEs="pxn-extras-stable"
NAMEt="pxn-extras-testing"
NAMEp="pxn-extras-private"
[ -z "${WORKSPACE}" ] && WORKSPACE=`pwd`
rm -vf "${WORKSPACE}/${NAMEs}"-*.noarch.rpm
rm -vf "${WORKSPACE}/${NAMEt}"-*.noarch.rpm
rm -vf "${WORKSPACE}/${NAMEp}"-*.noarch.rpm


title "Build.."
( cd "${WORKSPACE}/" && sh build-rpm.sh --build-number ${BUILD_NUMBER} ) || exit 1


title "Deploy.."
cp -fv "${WORKSPACE}/${NAMEs}"-*.noarch.rpm "${DL_PATH}/" || exit 1
cp -fv "${WORKSPACE}/${NAMEt}"-*.noarch.rpm "${DL_PATH}/" || exit 1
cp -fv "${WORKSPACE}/${NAMEp}"-*.noarch.rpm "${DL_PATH}/" || exit 1
# stable
latest_version "${DL_PATH}/${NAMEs}-*.noarch.rpm"         || exit 1
echo "Latest version: "${LATEST_FILE}
ln -fs "${LATEST_FILE}" "${YUM_PATH}/${NAMEs}.noarch.rpm" || exit 1
# testing
latest_version "${DL_PATH}/${NAMEt}-*.noarch.rpm"         || exit 1
echo "Latest version: "${LATEST_FILE}
ln -fs "${LATEST_FILE}" "${YUM_PATH}/${NAMEt}.noarch.rpm" || exit 1
# private
latest_version "${DL_PATH}/${NAMEp}-*.noarch.rpm"         || exit 1
echo "Latest version: "${LATEST_FILE}
ln -fs "${LATEST_FILE}" "${YUM_PATH}/${NAMEp}.noarch.rpm" || exit 1

