DESCRIPTION = "ChirpStack open-source LoRaWAN(R) Network Server"
HOMEPAGE = "https://www.chirpstack.io/"
PRIORITY = "optional"

include chirpstack_4.12.1.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " \
    file://chirpstack.toml \
    file://regions/region_as923_2.toml \
    file://regions/region_as923_3.toml \
    file://regions/region_as923_4.toml \
    file://regions/region_as923.toml \
    file://regions/region_au915_0.toml \
    file://regions/region_au915_1.toml \
    file://regions/region_au915_2.toml \
    file://regions/region_au915_3.toml \
    file://regions/region_au915_4.toml \
    file://regions/region_au915_5.toml \
    file://regions/region_au915_6.toml \
    file://regions/region_au915_7.toml \
    file://regions/region_eu868.toml \
    file://regions/region_in865.toml \
    file://regions/region_kr920.toml \
    file://regions/region_ru864.toml \
    file://regions/region_us915_0.toml \
    file://regions/region_us915_1.toml \
    file://regions/region_us915_2.toml \
    file://regions/region_us915_3.toml \
    file://regions/region_us915_4.toml \
    file://regions/region_us915_5.toml \
    file://regions/region_us915_6.toml \
    file://regions/region_us915_7.toml \
"

CONF_DIR = "${sysconfoptdir}/chirpstack"
S = "${WORKDIR}/git"

DEPENDS = " \
    protobuf-native \
    nodejs-native \
    clang-native \
    cmake-native \
    protobuf \
    grpc \
    sqlite3 \
"

PROTOC_PATH = "./node_modules/grpc-tools/bin/protoc"
PROTOC_ARGS = "-I=../proto --js_out=import_style=commonjs:. --grpc-web_out=import_style=commonjs+dts,mode=grpcwebtext:."

## meta-rust-bin
inherit cargo_bin

CARGO_BUILD_FLAGS += "--no-default-features --features='sqlite'"

do_compile_grpc() {
    npm install -g yarn
    npm install -g protoc-gen-grpc-web

    cd ${S}/api/grpc-web
    yarn install  --ignore-engines

    mkdir -p common
    ${PROTOC_PATH} ${PROTOC_ARGS} ../proto/common/common.proto

    mkdir -p gw
    ${PROTOC_PATH} ${PROTOC_ARGS} ../proto/gw/gw.proto

    mkdir -p api
    ${PROTOC_PATH} ${PROTOC_ARGS} ../proto/api/internal.proto
    ${PROTOC_PATH} ${PROTOC_ARGS} ../proto/api/user.proto
    ${PROTOC_PATH} ${PROTOC_ARGS} ../proto/api/tenant.proto
    ${PROTOC_PATH} ${PROTOC_ARGS} ../proto/api/application.proto
    ${PROTOC_PATH} ${PROTOC_ARGS} ../proto/api/device_profile.proto
    ${PROTOC_PATH} ${PROTOC_ARGS} ../proto/api/device_profile_template.proto
    ${PROTOC_PATH} ${PROTOC_ARGS} ../proto/api/device.proto
    ${PROTOC_PATH} ${PROTOC_ARGS} ../proto/api/gateway.proto
    ${PROTOC_PATH} ${PROTOC_ARGS} ../proto/api/multicast_group.proto
    ${PROTOC_PATH} ${PROTOC_ARGS} ../proto/api/relay.proto
    ${PROTOC_PATH} ${PROTOC_ARGS} ../proto/api/fuota.proto

    mkdir -p integration
    ${PROTOC_PATH} ${PROTOC_ARGS} ../proto/integration/integration.proto

    ${PROTOC_PATH} ${PROTOC_ARGS} ../proto/google/api/*.proto
}
addtask compile_grpc after do_configure before do_compile_ui
do_compile_grpc[network] = "1"

do_compile_ui() {
    npm install -g yarn

    cd ${S}/ui
    yarn install --ignore-engines
    yarn add --ignore-engines file:../api/grpc-web
    yarn build
}
addtask compile_ui after do_compile_grpc before do_compile
do_compile_ui[network] = "1"

# Enable network for the compile task allowing cargo to download dependencies
do_compile[network] = "1"

do_install() {
    # install configuration file
    install -m 0755 -d ${D}${CONF_DIR}
    install -m 0644 ${WORKDIR}/chirpstack.toml ${D}${CONF_DIR}/chirpstack.toml

    # install regions
    install_regions

    # install binary
    install -m 0755 -d ${D}${optdir}/chirpstack
    install -m 0755 ${CARGO_BINDIR}/chirpstack ${D}${optdir}/chirpstack/chirpstack
}

install_regions() {
    install_region region_as923_2.toml
    install_region region_as923_3.toml
    install_region region_as923_4.toml
    install_region region_as923.toml
    install_region region_au915_0.toml
    install_region region_au915_1.toml
    install_region region_au915_2.toml
    install_region region_au915_3.toml
    install_region region_au915_4.toml
    install_region region_au915_5.toml
    install_region region_au915_6.toml
    install_region region_au915_7.toml
    install_region region_eu868.toml
    install_region region_in865.toml
    install_region region_kr920.toml
    install_region region_ru864.toml
    install_region region_us915_0.toml
    install_region region_us915_1.toml
    install_region region_us915_2.toml
    install_region region_us915_3.toml
    install_region region_us915_4.toml
    install_region region_us915_5.toml
    install_region region_us915_6.toml
    install_region region_us915_7.toml
}

install_region() {
    if [ -z "$1" ]; then
        bbfatal "Usage install_region <source> [dest]"
    fi

    if [ -z "$2"]; then
        DEST=$1
    else
        DEST=$2
    fi

    install -m 0644 ${WORKDIR}/regions/$1 ${D}${CONF_DIR}/${DEST}
}

FILES:${PN} += " \
    ${CONF_DIR}/ \
    ${optdir}/chirpstack/chirpstack \
"
