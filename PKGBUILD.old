# Maintainer: User8395 <therealuser8395@proton.me>
pkgname=plasma-bigscreen-git
pkgver=5.26.90.r622.ga4c80bb
pkgrel=1
pkgdesc="A big launcher giving you easy access to any installed apps and skills"
arch=('x86_64') # <-- CORRECTION: Changed from 'any' because this is a compiled package
url="https://plasma-bigscreen.org/"
license=('GPL2')
groups=()
depends=('kdeconnect-git'
        'plasma-nm-git'
        'plasma-pa-git'
        'plasma-nano-git'
        'bluez-qt-git' # <-- CORRECTION: Removed trailing comma
        'powerdevil-git')
makedepends=('cmake' 'extra-cmake-modules-git' 'git')
optdepends=('libcec: add USB-CEC support in order to be controlled by TV remotes'
            'plasma-remotecontrollers-git: add support for remote controllers')
conflicts=('plasma-bigscreen')
provides=('plasma-bigscreen')
source=('git+https://invent.kde.org/plasma/plasma-bigscreen.git')
md5sums=('SKIP')

pkgver() {
        cd "$pkgname"
        git describe --long --abbrev=7 | sed 's/^v//;s/\([^-]*-g\)/r\1/;s/-/./g'
}

build() {
        cd "$pkgname"
        cmake -B build \
              -DCMAKE_INSTALL_PREFIX="/usr" \
              -DCMAKE_BUILD_TYPE=Release \
              -Wno-dev

        cmake --build build
}

package() {
        # <-- CORRECTION: The entire function has been corrected.
        # Use DESTDIR to correctly stage the files for packaging.
        # The path to the build directory is just "build", not "$pkgname/build".
        DESTDIR="$pkgdir" cmake --install build
}
