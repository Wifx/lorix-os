# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

python() {
    # Set LORA_CONCENTRATOR value
    if bb.utils.contains('MACHINE_FEATURES', 'sx1301', True, False, d) or bb.utils.contains('MACHINE_FEATURES', 'sx1302', True, False, d):
        d.setVar('LORA_CONCENTRATOR', True)

        if bb.utils.contains('MACHINE_FEATURES', 'sx1301', True, False, d) and bb.utils.contains('MACHINE_FEATURES', 'sx1302', True, False, d):
            bb.fatal("MACHINE_FEATURES has both sx1301 and sx1302, not supported")

    # Add lora as MACHINE_FEATURES
    if d.getVar('LORA_CONCENTRATOR', True):
        d.setVar('MACHINE_FEATURES_append', ':%s' % 'lora')
}
