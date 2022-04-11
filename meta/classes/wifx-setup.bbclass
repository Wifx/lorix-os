# Copyright (c) 2019-2020, Wifx Sàrl <info@wifx.net>
# All rights reserved.

python() {
    # Set each MACHINE_FEATURES_OVERRIDES as MACHINE_FEATURES and OVERRIDES
    for feature in d.getVar('MACHINE_FEATURES_OVERRIDES').split():
        d.setVar('OVERRIDES_append', ':%s' % feature)
        d.setVar('MACHINE_FEATURES_append', ' %s' % feature)
}

python() {
    need_feature = d.getVar('COMPATIBLE_MACHINE_FEATURE')
    if need_feature:
        import re
        compat_machine_features = (d.getVar('MACHINE_FEATURES') or "").split()
        for m in compat_machine_features:
            if re.match(need_feature, m):
                break
        else:
            raise bb.parse.SkipRecipe("missing machine feature %s (not in MACHINE_FEATURES)" % need_feature)

    need_feature_any = d.getVar('COMPATIBLE_MACHINE_FEATURE_ANY')
    if need_feature_any:
        import re
        need_machine_features = (need_feature_any or "").split()
        compat_machine_features = (d.getVar('MACHINE_FEATURES') or "").split()
        found = False
        for n in need_machine_features:
            for m in compat_machine_features:
                if re.match(n, m):
                    found = True
                    break
            if found:
                break
        if not found:
            raise bb.parse.SkipRecipe("missing machine feature, one of [%s] (not in MACHINE_FEATURES)" % (' '.join([str(item) for item in need_feature_any])))

    need_feature_all = d.getVar('COMPATIBLE_MACHINE_FEATURE_ALL')
    if need_feature_all:
        import re
        need_machine_features = (need_feature_all or "").split()
        compat_machine_features = (d.getVar('MACHINE_FEATURES') or "").split()
        for n in need_machine_features:
            found = False
            for m in compat_machine_features:
                if re.match(n, m):
                    found = True
                    break
            if not found:
                raise bb.parse.SkipRecipe("missing machine feature, all of [%s] (not in MACHINE_FEATURES)" % (' '.join([str(item) for item in need_feature_all])))
}