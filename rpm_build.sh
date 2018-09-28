#!/bin/bash
PKG_VERSION="0.1"
ARCH="x86_64"
HOME_DIR="$AGENT_WORKFOLDER/../.."
APPS=(my_app1 my_app2)

echo "PKG_VERSION: $PKG_VERSION"

echo "BUILD ID: $BUILD_BUILDID"
echo "BUILD ID NUMBER: $BUILD_BUILDNUMBER"
echo "HOME_DIR: $HOME_DIR"
echo "ARTIFACTS: $BUILD_ARTIFACTSTAGINGDIRECTORY"

cp "$BUILD_ARTIFACTSTAGINGDIRECTORY"/*.zip "$HOME_DIR"/rpmbuild/SOURCES/
cp "$SYSTEM_DEFAULTWORKINGDIRECTORY"/CI/*.service "$HOME_DIR"/rpmbuild/SOURCES/
cp "$SYSTEM_DEFAULTWORKINGDIRECTORY"/CI/*.spec "$HOME_DIR"/rpmbuild/SPECS/

for APP in ${APPS[*]}; do
  PKG_NAME="$APP-$PKG_VERSION-$BUILD_BUILDID.$ARCH.rpm"
  rpmbuild -bb --clean --define "_version $PKG_VERSION" --define "_release $BUILD_BUILDID" --define "_home_dir $HOME_DIR" "$HOME_DIR"/rpmbuild/SPECS/$APP.spec;
  cp "$HOME_DIR"/rpmbuild/RPMS/$ARCH/$PKG_NAME /var/www/apprepo/
  curl -H "Content-Type: application/json" -d '{"package": "'$PKG_NAME'"}' "http://rpmrepo.com/hooks/"
done
