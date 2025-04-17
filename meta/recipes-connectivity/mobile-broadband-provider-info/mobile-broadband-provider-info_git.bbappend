SRCREV = "55ba955d53305df96123534488fd160ea882b4dd"
PV = "20240407"
PE = "1"

inherit meson

# Latest version of mobile-broadband-provider-info doesn't use anymore autotools
# but now uses meson.
# Unfortunately, the meson version required is 1.0.0 while:
# - we only support 0.61.3
# - this is sufficient for the build to work
# This is a workaround to modify the meson version required in meson.build
# to allow the build to work with our current version of meson.
do_configure:prepend() {
    # modify minimal meson version from 1.0.0 to 0.61.3
    sed -i "s/meson_version: '>= 1.0.0',/meson_version: '>= 0.61.3',/" ${S}/meson.build
}