# Scala GUI

Copyright (c) 2021-2023, Haku Labs MTÜ

Copyright (c) 2014-2022, The Monero Project

## Table of Contents
  * [Development resources](#development-resources)
  * [Vulnerability response](#vulnerability-response)
  * [Introduction](#introduction)
  * [About this project](#about-this-project)
  * [Supporting the project](#supporting-the-project)
  * [License](#license)
  * [Compiling the Scala GUI from source](#compiling-the-scala-gui-from-source)
    + [Building Reproducible Windows static binaries with Docker (any OS)](#building-reproducible-windows-static-binaries-with-docker-any-os)
    + [Building Reproducible Linux static binaries with Docker (any OS)](#building-reproducible-linux-static-binaries-with-docker-any-os)
    + [Building on Linux](#building-on-linux)
    + [Building on OS X](#building-on-os-x)
    + [Building on Windows](#building-on-windows)

## Development resources

- Web: [scalaproject.io](https://scalaproject.io)
- Mail: [hello@scalaproject.io](mailto:hello@scalaproject.io)
- Github: [https://github.com/scala-network](https://github.com/scala-network)
- Discord: [https://chat.scalaproject.io](https://chat.scalaproject.io)

## Vulnerability response

Please contact us privately at [hello@scalaproject.io](mailto:hello@scalaproject.io) to report security issues.

## Introduction

Scala is a private, secure, untraceable, decentralised digital currency. You are your bank, you control your funds, and nobody can trace your transfers unless you allow them to do so.

**Privacy:** scala uses a cryptographically sound system to allow you to send and receive funds without your transactions being easily revealed on the blockchain (the ledger of transactions that everyone has). This ensures that your purchases, receipts, and all transfers remain private by default.

**Security:** Using the power of a distributed peer-to-peer consensus network, every transaction on the network is cryptographically secured. Individual wallets have a 25-word mnemonic seed that is only displayed once and can be written down to backup the wallet. Wallet files should be encrypted with a strong passphrase to ensure they are useless if ever stolen.

**Untraceability:** By taking advantage of ring signatures, a special property of a certain type of cryptography, scala is able to ensure that transactions are not only untraceable but have an optional measure of ambiguity that ensures that transactions cannot easily be tied back to an individual user or computer.

**Decentralization:** The utility of scala depends on its decentralised peer-to-peer consensus network - anyone should be able to run the scala software, validate the integrity of the blockchain, and participate in all aspects of the scala network using consumer-grade commodity hardware. Decentralization of the scala network is maintained by software development that minimizes the costs of running the scala software and inhibits the proliferation of specialized, non-commodity hardware.

## About this project

This is the GUI for the [core Scala implementation](https://github.com/scala-network/scala). It is open source and completely free to use without restrictions, except for those specified in the license agreement below. There are no restrictions on anyone creating an alternative implementation of Scala that uses the protocol and network in a compatible manner.

As with many development projects, the repository on Github is considered to be the "staging" area for the latest changes. Before changes are merged into that branch on the main repository, they are tested by individual developers in their own branches, submitted as a pull request, and then subsequently tested by contributors who focus on testing and code reviews. That having been said, the repository should be carefully considered before using it in a production environment, unless there is a patch in the repository for a particular show-stopping issue you are experiencing. It is generally a better idea to use a tagged release for stability.

## Supporting the project

For information on how scala funds its development, please read [this](https://wiki.scalaproject.io/general/funding) on our wiki.

Core development funding and/or some supporting services are also graciously provided by sponsors:

[<img width="150" src="https://resources.jetbrains.com/storage/products/company/brand/logos/jb_beam.png"/>](https://www.jetbrains.com/)

There are also several mining pools that kindly donate a portion of their fees, [a list of them can be found on our Bitcointalk post](https://bitcointalk.org/index.php?topic=583449.0).

## License

See [LICENSE](LICENSE).

## Contributing

If you want to help out, see [CONTRIBUTING](docs/CONTRIBUTING.md) for a set of guidelines.

## Compiling the Scala GUI from source

*Note*: Qt 5.9.7 is the minimum version required to build the GUI.

*Note*: Official GUI releases use scala-wallet-gui from this process alongside the supporting binaries (scalad, etc) from the official builds over at [https://github.com/scala-network/scala](https://github.com/scala-network/scala)

### Building Reproducible Windows static binaries with Docker (any OS)

1. Install Docker [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/)
2. Clone the repository
   ```
   git clone --branch master --recursive https://github.com/scala-network/scala-gui.git
   ```
3. Prepare build environment
   ```
   cd scala-gui
   docker build --tag scala:build-env-windows --build-arg THREADS=4 --file Dockerfile.windows .
   ```
4. Build
   ```
   docker run --rm -it -v <SCALA_GUI_DIR_FULL_PATH>:/scala-gui -w /scala-gui scala:build-env-windows sh -c 'make depends root=/depends target=x86_64-w64-mingw32 tag=win-x64 -j4'
   ```
5. Scala GUI Windows static binaries will be placed in  `scala-gui/build/x86_64-w64-mingw32/release/bin` directory

### Building Reproducible Linux static binaries with Docker (any OS)

1. Install Docker [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/)
2. Clone the repository
   ```
   git clone --branch master --recursive https://github.com/scala-network/scala-gui.git
   ```
3. Prepare build environment
   ```
   cd scala-gui
   docker build --tag scala:build-env-linux --build-arg THREADS=4 --file Dockerfile.linux .
   ```
4. Build
   ```
   docker run --rm -it -v <SCALA_GUI_DIR_FULL_PATH>:/scala-gui -w /scala-gui scala:build-env-linux sh -c 'make release-static -j4'
   ```
5. Scala GUI Linux static binaries will be placed in  `scala-gui/build/release/bin` directory
6. (*Optional*) Compare `scala-wallet-gui` SHA-256 hash to the one obtained from a trusted source
   ```
   docker run --rm -it -v <SCALA_GUI_DIR_FULL_PATH>:/scala-gui -w /scala-gui scala:build-env-linux sh -c 'shasum -a 256 /scala-gui/build/release/bin/scala-wallet-gui'
   ```

### Building on Linux

(Tested on Ubuntu 17.10 x64, Ubuntu 18.04 x64 and Gentoo x64)

1. Install Scala dependencies

  - For Debian distributions (Debian, Ubuntu, Mint, Tails...)
    ```
    sudo apt install build-essential cmake miniupnpc libunbound-dev graphviz doxygen libunwind8-dev pkg-config libssl-dev libzmq3-dev libsodium-dev libhidapi-dev libnorm-dev libusb-1.0-0-dev libpgm-dev libprotobuf-dev protobuf-compiler libgcrypt20-dev libboost-chrono-dev libboost-date-time-dev libboost-filesystem-dev libboost-locale-dev libboost-program-options-dev libboost-regex-dev libboost-serialization-dev libboost-system-dev libboost-thread-dev
    ```

  - For Gentoo
	```
    sudo emerge app-arch/xz-utils app-doc/doxygen dev-cpp/gtest dev-libs/boost dev-libs/expat dev-libs/openssl dev-util/cmake media-gfx/graphviz net-dns/unbound net-libs/miniupnpc net-libs/zeromq sys-libs/libunwind dev-libs/libsodium dev-libs/hidapi dev-libs/libgcrypt
    ```

  - For Fedora
	```
    sudo dnf install make automake cmake gcc-c++ boost-devel miniupnpc-devel graphviz doxygen unbound-devel libunwind-devel pkgconfig openssl-devel libcurl-devel hidapi-devel libusb-devel zeromq-devel libgcrypt-devel
    ```

2. Install Qt:

  *Note*: The Qt 5.9.7 or newer requirement makes **some** distributions (mostly based on Debian, like Ubuntu 16.x or Linux Mint 18.x) obsolete due to their repositories containing an older Qt version.

 The recommended way is to install 5.9.7 from the [official Qt installer](https://www.qt.io/download-qt-installer) or [compiling it yourself](https://wiki.qt.io/Install_Qt_5_on_Ubuntu). This ensures you have the correct version. Higher versions *can* work but as it differs from our production build target, slight differences may occur.

The following instructions will fetch Qt from your distribution's repositories instead. Take note of what version it installs. Your mileage may vary.

  - For Debian distributions (Debian, Ubuntu, Mint, Tails...)
    ```
    sudo apt install qtbase5-dev qtdeclarative5-dev qml-module-qtqml-models2 qml-module-qtquick-controls qml-module-qtquick-controls2 qml-module-qtquick-dialogs qml-module-qtquick-xmllistmodel qml-module-qt-labs-settings qml-module-qt-labs-platform qml-module-qt-labs-folderlistmodel qttools5-dev-tools qml-module-qtquick-templates2 libqt5svg5-dev
    ```

  - For Gentoo

    The *qml* USE flag must be enabled.

    ```
    sudo emerge dev-qt/qtcore:5 dev-qt/qtdeclarative:5 dev-qt/qtquickcontrols:5 dev-qt/qtquickcontrols2:5 dev-qt/qtgraphicaleffects:5
    ```

3. Clone repository

    ```
    git clone --recursive https://github.com/scala-network/scala-gui.git
    cd scala-gui
    ```

4. Build

    If on x86-64:

    ```
    make release -j4
    ```

    If on ppc64le:

    ```
    make release-linux-ppc64le -j4
    ```

    `4` - number of CPU threads to use  
    Add `CMAKE_PREFIX_PATH` environment variable to set a custom Qt install directory, e.g. `CMAKE_PREFIX_PATH=$HOME/Qt/5.9.7/gcc_64 make release -j4`

The executable can be found in the build/release/bin folder.

### Building on OS X

1. Install Xcode from AppStore

2. Install [homebrew](http://brew.sh/)

3. Install [scala](https://github.com/scala-network/scala) dependencies:
    ```
      brew install cmake pkg-config openssl boost unbound hidapi zmq libpgm libsodium miniupnpc expat libunwind-headers protobuf libgcrypt
    ```
   
4. Install Qt:

  `brew install qt5`  (or download QT 5.9.7+ from [qt.io](https://www.qt.io/download-open-source/))

5. Grab an up-to-date copy of the scala-gui repository

   ```
   git clone --recursive https://github.com/scala-network/scala-gui.git
   cd scala-gui
   ```

6. Start the build

    ```
    make release -j4
    ```
    `4` - number of CPU threads to use  
    Add `CMAKE_PREFIX_PATH` environment variable to set a custom Qt install directory, e.g. `CMAKE_PREFIX_PATH=$HOME/Qt/5.9.7/clang_64 make release -j4`

The executable can be found in the `build/release/bin` folder.

For building an application bundle see `DEPLOY.md`.

### Building on Windows

The Scala GUI on Windows is 64 bits only; 32-bit Windows GUI builds are not officially supported anymore.

1. Install [MSYS2](https://www.msys2.org/), follow the instructions on that page on how to update system and packages to the latest versions

2. Open an 64-bit MSYS2 shell: Use the *MSYS2 MinGW 64-bit* shortcut, or use the `msys2_shell.cmd` batch file with a `-mingw64` parameter

3. Install MSYS2 packages for Scala dependencies; the needed 64-bit packages have `x86_64` in their names

    ```
    pacman -S mingw-w64-x86_64-toolchain make mingw-w64-x86_64-cmake mingw-w64-x86_64-boost mingw-w64-x86_64-openssl mingw-w64-x86_64-zeromq mingw-w64-x86_64-libsodium mingw-w64-x86_64-hidapi mingw-w64-x86_64-protobuf-c mingw-w64-x86_64-libusb mingw-w64-x86_64-libgcrypt mingw-w64-x86_64-unbound
    ```

    You find more details about those dependencies in the [Scala documentation](https://github.com/scala-network/scala). Note that that there is no more need to compile Boost from source; like everything else, you can install it now with a MSYS2 package.

4. Install Qt5

    ```
    pacman -S mingw-w64-x86_64-qt5
    ```

    There is no more need to download some special installer from the Qt website, the standard MSYS2 package for Qt will do in almost all circumstances.

5. Install git

    ```
    pacman -S git
    ```

6. Clone repository

    ```
    git clone --recursive https://github.com/scala-network/scala-gui.git
    cd scala-gui
    ```

7. Build

    ```
    make release-win64 -j4
    cd build/release
    make deploy
    ```
    `4` - number of CPU threads to use

The executable can be found in the `.\bin` directory.
