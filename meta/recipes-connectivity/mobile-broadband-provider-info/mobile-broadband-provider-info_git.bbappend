SRCREV = "2a1b409491a531aedcf3eb3ba907929d96bd181a"
PV = "20250613"
PE = "1"

inherit meson

do_fix_sources() {
    # Latest version of mobile-broadband-provider-info doesn't use anymore autotools
    # but now uses meson.
    # Unfortunately, the meson version required is 1.0.0 while:
    # - we only support 0.61.3
    # - this is sufficient for the build to work
    # This is a workaround to modify the meson version required in meson.build
    # to allow the build to work with our current version of meson.
    # modify minimal meson version from 1.0.0 to 0.61.3
    sed -i "s/meson_version: '>= 1.0.0',/meson_version: '>= 0.61.3',/" ${S}/meson.build

    # Add new operators information
    # First remove the closing tag
    sed -i 's|</serviceproviders>||' ${S}/serviceproviders.xml

    # Append 1NCE operator information
    cat >> ${S}/serviceproviders.xml << 'EOF'
<country code="ww">
	<name>Worldwide</name>
	<provider>
		<name>1NCE</name>
		<gsm>
			<network-id mcc="901" mnc="40"/>
			<network-id mcc="901" mnc="67"/>
			<apn value="iot.1nce.net">
				<plan type="prepaid"/>
				<usage type="internet"/>
				<username></username>
				<password></password>
			</apn>
		</gsm>
	</provider>
</country>

</serviceproviders>
EOF
}
addtask fix_sources after do_patch before do_configure
do_unpack[vardeps] += "do_fix_sources"
