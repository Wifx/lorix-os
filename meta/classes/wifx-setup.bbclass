# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

python() {
    # Set each MACHINE_FEATURES_OVERRIDES as MACHINE_FEATURES and OVERRIDES
    for feature in d.getVar('MACHINE_FEATURES_OVERRIDES').split():
        d.setVar('OVERRIDES_append', ':%s' % feature)
        d.setVar('MACHINE_FEATURES_append', ' %s' % feature)
}
