package: AliRoot
version: "%(short_hash)s"
requires:
  - ROOT
env:
  ALICE_ROOT: "$ALIROOT_ROOT"
source: http://git.cern.ch/pub/AliRoot
write_repo: https://git.cern.ch/reps/AliRoot 
tag: master
---
#!/bin/bash -e
cmake $SOURCEDIR -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
      -DROOTSYS=$ROOT_ROOT \
      -DALIEN=$ALIEN_RUNTIME_ROOT \
      -DOCDB_INSTALL=PLACEHOLDER

if [[ $GIT_TAG == master ]]; then
  make -k ${JOBS+-j $JOBS} || true
  make -k install || true
else
  make ${JOBS+-j $JOBS}
  make install
fi
cp -r $SOURCEDIR/test $INSTALLROOT/test

# Modulefile
MODULEDIR="$INSTALLROOT/etc/Modules/modulefiles/$PKGNAME"
MODULEFILE="$MODULEDIR/$PKGVERSION-$PKGREVISION"
mkdir -p "$MODULEDIR"
cat > "$MODULEFILE" <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "ALICE Modulefile for $PKGNAME $PKGVERSION-$PKGREVISION"
}
set version $PKGVERSION-$PKGREVISION
module-whatis "ALICE Modulefile for $PKGNAME $PKGVERSION-$PKGREVISION"
# Dependencies
module load BASE/1.0 ROOT/$ROOT_VERSION-$ROOT_REVISION
# Our environment
setenv ALIROOT_VERSION \$version
setenv ALICE \$::env(BASEDIR)/$PKGNAME
setenv ALIROOT_RELEASE \$::env(ALIROOT_VERSION)
setenv ALICE_ROOT \$::env(BASEDIR)/$PKGNAME/\$::env(ALIROOT_RELEASE)
prepend-path PATH \$::env(ALICE_ROOT)/bin:\$::env(ALICE_ROOT)/bin/tgt_\$::env(ALICE_TARGET_EXT)
prepend-path LD_LIBRARY_PATH \$::env(ALICE_ROOT)/lib:\$::env(ALICE_ROOT)/lib/tgt_\$::env(ALICE_TARGET_EXT)
EoF
