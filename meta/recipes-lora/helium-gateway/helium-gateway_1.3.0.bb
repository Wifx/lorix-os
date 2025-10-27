HOMEPAGE = "https://www.helium.com/"
DESCRIPTION = "Helium Gateway"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=1c3a461cb3bfa8dedcbf13b9e8a6335a"

## meta-rust
inherit cargo cargo-update-recipe-crates
RUST_PANIC_STRATEGY = "abort"

PR = "r1"

# !!! Some important notes here !!!
# meta-rust crates fetching doesn't support git crate (only crates.io currently)
# therefore, all git dependencies must be converted to local crates and fetched
# using standard Yocto's git fetching. Also, Cargo.toml and Cargo.lock need
# to reflect that in order for meta-rust crates sources generator to detect
# these local crates dependencies.
# 1. Update Cargo.toml and Cargo.lock to use the local paths (git patch)
# 2. Include these local crate into SRC_URI (installed into WORKDIR/deps)
# 3. Update crates list using <recipe> -c do_update_crates

SRC_URI += " \
    git://github.com/helium/gateway-rs.git;name=gateway-rs;protocol=https;branch=main \
    git://github.com/helium/proto.git;name=helium-proto;protocol=https;branch=master;destsuffix=deps/helium-proto \
    git://github.com/yoshuawuyts/exponential-backoff.git;name=exponential-backoff;protocol=https;branch=master;destsuffix=deps/exponential-backoff \
    file://0001-Change-private-distant-crates-as-local-dependencies.patch \
    file://settings.toml \
"
require helium-gateway-crates.inc

SRCREV_gateway-rs = "b736b006af618d67433e0d4c19d626260fad6dcb"
SRCREV_helium-proto = "c828e0399f88ebbd6d13c8de39c25d70b9440f5b"
SRCREV_exponential-backoff = "5e889c9ba87a836456667c3bdeaf19888f89b7e0"

SRCREV_FORMAT = "gateway-rs_helium-proto_exponential-backoff"

DEPENDS += "protobuf-native"

CONF_DIR = "${sysconfoptdir}/helium-gateway"
OPT_DIR = "${optdir}/helium-gateway"
S = "${WORKDIR}/git"

do_patch:append() {
    bb.build.exec_func('do_patch_cargo', d)
}

do_patch_cargo() {
    # This is not the sources's job to strip binaries as Yocto does it very well
    # and allow to keep unstripped binaries in ${PN}-dev pkg.
    sed -i 's/strip = "symbols"//' ${S}/Cargo.toml

    # Let the panic type be managed by Yocto
    sed -i 's/panic = "abort"//' ${S}/Cargo.toml
}

do_install() {
    # Config
    install -m 0755 -d ${D}${CONF_DIR}
    install_config settings.toml

    # Bin directory
    install -m 0755 -d ${D}${OPT_DIR}
    install -m 0755 ${B}/target/${CARGO_TARGET_SUBDIR}/helium_gateway ${D}${OPT_DIR}/helium-gateway
}

install_config() {
    if [ -z "$1" ]; then
        bbfatal "Usage install_config <source> [dest]"
    fi

    if [ -z "$2"]; then
        DEST=$1
    else
        DEST=$2
    fi

    install -m 0644 ${WORKDIR}/$1 ${D}${CONF_DIR}/${DEST}
}

FILES:${PN} += " \
    ${CONF_DIR}/ \
    ${OPT_DIR}/ \
"
