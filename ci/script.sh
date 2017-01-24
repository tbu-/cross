set -ex

main() {
    local td=

    if [ $TRAVIS_OS_NAME = linux ]; then
        ./build-docker-image.sh $TARGET
    fi

    if [ $TRAVIS_BRANCH = master ] || [ ! -z $TRAVIS_TAG ]; then
        return
    fi

    cargo install --path .

    # `cross run` test for thumb targets
    case $TARGET in
        thumb*-none-eabi*)
            td=$(mktemp -d)

            git clone \
                --depth 1 \
                --recursive \
                https://github.com/japaric/cortest $td

            pushd $td
            cross run --target $TARGET --example hello
            popd

            rm -rf $td
        ;;
    esac

    # `cross build` test for targets where `std` is not available
    if [ -z $STD ]; then
        td=$(mktemp -d)

        git clone \
            --depth 1 \
            --recursive \
            https://github.com/rust-lang-nursery/compiler-builtins $td

        pushd $td
        cat > Cross.toml <<EOF
[build]
xargo = true
EOF
        cross build --features c --lib --target $TARGET
        popd

        rm -rf $td

        return
    fi

    # `cross build` test for the other targets
    if [ $OPENSSL ]; then
        td=$(mktemp -d)

        git clone --depth 1 https://github.com/rust-lang/cargo $td

        pushd $td
        cross build --target $TARGET
        popd

        rm -rf $td
    else
        td=$(mktemp -d)

        git clone --depth 1 https://github.com/japaric/xargo $td

        pushd $td
        cross build --target $TARGET
        popd

        rm -rf $td
    fi

    if [ $RUN ]; then
        # `cross test` test
        if [ $DYLIB ]; then
            td=$(mktemp -d)

            git clone \
                --depth 1 \
                --recursive \
                https://github.com/rust-lang-nursery/compiler-builtins \
                $td

            pushd $td
            cross test \
                  --no-default-features \
                  --target $TARGET
            popd

            rm -rf $td
        fi

        # `cross run` test
        td=$(mktemp -d)

        cargo init --bin --name hello $td

        pushd $td
        cross run --target $TARGET
        popd

        rm -rf $td
    fi

    # Test C++ support
    if [ $CPP ]; then
        td=$(mktemp -d)

        git clone --depth 1 https://github.com/japaric/hellopp $td

        pushd $td
        if [ $TARGET = s390x-unknown-linux-gnu ]; then
            cross build --target $TARGET
        else
            cross run --target $TARGET
        fi
        popd

        rm -rf $td
    fi

    # Test openssl compatibility
    if [ $OPENSSL ]; then
        td=$(mktemp -d)

        pushd $td
        cargo clone openssl-sys --vers 0.5.5
        cd openssl-sys
        cross build --target $TARGET
        popd

        rm -rf $td
    fi
}

main
