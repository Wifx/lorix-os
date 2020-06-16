inherit goarch ptest

GO_PARALLEL_BUILD ?= "${@oe.utils.parallel_make_argument(d, '-p %d')}"

GOROOT_class-native = "${STAGING_LIBDIR_NATIVE}/go"
GOROOT_class-nativesdk = "${STAGING_DIR_TARGET}${libdir}/go"
GOROOT = "${STAGING_LIBDIR}/go"
export GOROOT
export GOROOT_FINAL = "${libdir}/go"

DEPENDS_GOLANG_class-target = "virtual/${TARGET_PREFIX}go virtual/${TARGET_PREFIX}go-runtime"
DEPENDS_GOLANG_class-native = "go-native"
DEPENDS_GOLANG_class-nativesdk = "virtual/${TARGET_PREFIX}go-crosssdk virtual/${TARGET_PREFIX}go-runtime"

DEPENDS_append = " ${DEPENDS_GOLANG}"

GO_LINKSHARED ?= "${@'-linkshared' if d.getVar('GO_DYNLINK') else ''}"
GO_RPATH_LINK = "${@'-Wl,-rpath-link=${STAGING_DIR_TARGET}${libdir}/go/pkg/${TARGET_GOTUPLE}_dynlink' if d.getVar('GO_DYNLINK') else ''}"
GO_RPATH = "${@'-r ${libdir}/go/pkg/${TARGET_GOTUPLE}_dynlink' if d.getVar('GO_DYNLINK') else ''}"
GO_RPATH_class-native = "${@'-r ${STAGING_LIBDIR_NATIVE}/go/pkg/${TARGET_GOTUPLE}_dynlink' if d.getVar('GO_DYNLINK') else ''}"
GO_RPATH_LINK_class-native = "${@'-Wl,-rpath-link=${STAGING_LIBDIR_NATIVE}/go/pkg/${TARGET_GOTUPLE}_dynlink' if d.getVar('GO_DYNLINK') else ''}"
GO_EXTLDFLAGS ?= "${HOST_CC_ARCH}${TOOLCHAIN_OPTIONS} ${GO_RPATH_LINK} ${LDFLAGS}"
GO_LINKMODE ?= ""
GO_LINKMODE_class-nativesdk = "--linkmode=external"
GO_EXTRA_LDFLAGS ?= ""
GO_LDFLAGS ?= '-ldflags="${GO_RPATH} ${GO_LINKMODE} ${GO_EXTRA_LDFLAGS} -extldflags '${GO_EXTLDFLAGS}'"'
export GOBUILDFLAGS ?= "-v ${GO_LDFLAGS}"
export GOPATH_OMIT_IN_ACTIONID ?= "1"
export GOPTESTBUILDFLAGS ?= "${GOBUILDFLAGS} -c"
export GOPTESTFLAGS ?= ""
GOBUILDFLAGS_prepend_task-compile = "${GO_PARALLEL_BUILD} "

export GO = "${HOST_PREFIX}go"
GOTOOLDIR = "${STAGING_LIBDIR_NATIVE}/${TARGET_SYS}/go/pkg/tool/${BUILD_GOTUPLE}"
GOTOOLDIR_class-native = "${STAGING_LIBDIR_NATIVE}/go/pkg/tool/${BUILD_GOTUPLE}"
export GOTOOLDIR

export CGO_ENABLED ?= "1"
export CGO_CFLAGS ?= "${CFLAGS}"
export CGO_CPPFLAGS ?= "${CPPFLAGS}"
export CGO_CXXFLAGS ?= "${CXXFLAGS}"
export CGO_LDFLAGS ?= "${LDFLAGS}"

GO_INSTALL ?= "${GO_IMPORT}/..."
GO_INSTALL_FILTEROUT ?= "${GO_IMPORT}/vendor/"

B = "${WORKDIR}/build"
export GOCACHE = "${B}/.cache"
export GOTMPDIR ?= "${WORKDIR}/go-tmp"
GO_SRC ?= "${S}"
GOTMPDIR[vardepvalue] = ""

python gomod_do_unpack() {
    import shutil
    
    src_uri = (d.getVar('SRC_URI') or "").split()
    if len(src_uri) == 0:
        return
    
    try:
        fetcher = bb.fetch2.Fetch(src_uri, d)
        fetcher.unpack(d.getVar('WORKDIR'))
    
    except bb.fetch2.BBFetchException as e:
        raise bb.build.FuncFailed(e)
}

gomod_list_packages() {
	cd ${GO_SRC}
	${GO} list -f '{{.ImportPath}}' ${GOBUILDFLAGS} ${GO_INSTALL} | \
		egrep -v '${GO_INSTALL_FILTEROUT}'
}

gomod_do_compile() {
	cd ${GO_SRC}
	export TMPDIR="${GOTMPDIR}"
	if [ -n "${GO_INSTALL}" ]; then
		echo ${GOROOT}
		echo ${GOPATH}

		if [ -n "${GO_LINKSHARED}" ]; then
			echo "Building shared libraries"
			${GO} install -buildmode=shared ${GOBUILDFLAGS} std
		fi
		
		echo "Building" ${PN} "..."
		#${GO} build ${GO_LINKSHARED} ${GOBUILDFLAGS} -o ${B}/${PN}
		${GO} build ${GOBUILDFLAGS} -o ${B}/${PN}
	fi
}
do_compile[dirs] =+ "${GOTMPDIR}"
do_compile[cleandirs] = "${B}"

gomod_compile_ptest_base() {
	export TMPDIR="${GOTMPDIR}"
	rm -f ${B}/.gomod_compiled_tests.list
	gomod_list_package_tests | while read pkg; do
		cd ${B}/src/$pkg
		${GO} test ${GOPTESTBUILDFLAGS} $pkg
		find . -mindepth 1 -maxdepth 1 -type f -name '*.test' -exec echo $pkg/{} \; | \
			sed -e's,/\./,/,'>> ${B}/.gomod_compiled_tests.list
	done
	do_compile_ptest
}
do_compile_ptest_base[dirs] =+ "${GOTMPDIR}"

gomod_do_install() {
	echo ${GO_BUILD_BINDIR}
	install -d ${D}${libdir}/go/src/${GO_IMPORT}
	tar -C ${S}/src/${GO_IMPORT} -cf - --exclude-vcs --exclude '*.test' --exclude 'testdata' . | \
		tar -C ${D}${libdir}/go/src/${GO_IMPORT} --no-same-owner -xf -
	tar -C ${B} -cf - pkg | tar -C ${D}${libdir}/go --no-same-owner -xf -

	if [ -n "`ls ${B}/${GO_BUILD_BINDIR}/`" ]; then
		install -d ${D}${bindir}
		install -m 0755 ${B}/${GO_BUILD_BINDIR}/* ${D}${bindir}/
	fi
}

gomod_make_ptest_wrapper() {
	cat >${D}${PTEST_PATH}/run-ptest <<EOF
#!/bin/sh
RC=0
run_test() (
    cd "\$1"
    ((((./\$2 ${GOPTESTFLAGS}; echo \$? >&3) | sed -r -e"s,^(PASS|SKIP|FAIL)\$,\\1: \$1/\$2," >&4) 3>&1) | (read rc; exit \$rc)) 4>&1
    exit \$?)
EOF

}

gomod_stage_testdata() {
	oldwd="$PWD"
	cd ${S}/src
	find ${GO_IMPORT} -depth -type d -name testdata | while read d; do
		if echo "$d" | grep -q '/vendor/'; then
			continue
		fi
		parent=`dirname $d`
		install -d ${D}${PTEST_PATH}/$parent
		cp --preserve=mode,timestamps -R $d ${D}${PTEST_PATH}/$parent/
	done
	cd "$oldwd"
}

do_install_ptest_base() {
	test -f "${B}/.gomod_compiled_tests.list" || exit 0
	install -d ${D}${PTEST_PATH}
	gomod_stage_testdata
	gomod_make_ptest_wrapper
	havetests=""
	while read test; do
		testdir=`dirname $test`
		testprog=`basename $test`
		install -d ${D}${PTEST_PATH}/$testdir
		install -m 0755 ${B}/src/$test ${D}${PTEST_PATH}/$test
	echo "run_test $testdir $testprog || RC=1" >> ${D}${PTEST_PATH}/run-ptest
		havetests="yes"
	done < ${B}/.gomod_compiled_tests.list
	if [ -n "$havetests" ]; then
		echo "exit \$RC" >> ${D}${PTEST_PATH}/run-ptest
		chmod +x ${D}${PTEST_PATH}/run-ptest
	else
		rm -rf ${D}${PTEST_PATH}
	fi
	do_install_ptest
	chown -R root:root ${D}${PTEST_PATH}
}

EXPORT_FUNCTIONS do_unpack do_compile do_install

FILES_${PN}-dev = "${libdir}/go/src"
FILES_${PN}-staticdev = "${libdir}/go/pkg"

INSANE_SKIP_${PN} += "ldflags"
INSANE_SKIP_${PN}-ptest += "ldflags"
