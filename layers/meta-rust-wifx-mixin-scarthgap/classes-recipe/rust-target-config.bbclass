# Copyright (c) 2025, Wifx SA <info@iot.wifx.net>
# All rights reserved.

require ${COREBASE}/meta/classes-recipe/rust-target-config.bbclass

# We could update ABI configuration for all targets but we are only
# interested by armv7-eabi

## armv7-unknown-linux-gnueabihf
DATA_LAYOUT[armv7-eabi] = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
LLVM_TARGET[armv7-eabi] = "${RUST_TARGET_SYS}"
TARGET_ENDIAN[armv7-eabi] = "little"
TARGET_POINTER_WIDTH[armv7-eabi] = "32"
TARGET_C_INT_WIDTH[armv7-eabi] = "32"
MAX_ATOMIC_WIDTH[armv7-eabi] = "64"
FEATURES[armv7-eabi] = "+v7,+vfp2,+thumb2"

# Rust target information file requires llvm-floatabi field to be set
# with rust 1.89 which was not filled in OE core rust version.
python do_rust_gen_targets:append() {
    import json
    import os

    wd = d.getVar('RUST_TARGETS_DIR')
    target_fpu = d.getVar('TARGET_FPU')

    bb.note("Adding llvm-floatabi based on TARGET_FPU: {}".format(target_fpu))

    # Walk over previously generated JSON
    for json_file in os.listdir(wd):
        if json_file.endswith('.json'):
            full_path = os.path.join(wd, json_file)

            # Lire le JSON
            with open(full_path, 'r') as f:
                tspec = json.load(f)

            # Add llvm-floatabi field
            if target_fpu in ["soft", "softfp"]:
                tspec['llvm-floatabi'] = "soft"
            elif target_fpu == "hard":
                tspec['llvm-floatabi'] = "hard"

            # Write back on file
            with open(full_path, 'w') as f:
                json.dump(tspec, f, indent=4)

            bb.note("Added llvm-floatabi to {}".format(json_file))
}