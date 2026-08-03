install:
    ./install.sh
    ./scripts/install-skills.sh

status:
    git-crypt status

patches:
    ./scripts/apply-submodule-patches.sh

regenerate-patch:
    ./scripts/regenerate-submodule-patch.sh

regenerate-patch-one name:
    ./scripts/regenerate-submodule-patch.sh {{name}}
