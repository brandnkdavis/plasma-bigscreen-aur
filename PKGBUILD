# Maintainer: User8395 <therealuser8395@proton.me>
pkgname=plasma-bigscreen-git
pkgver=6.0.0 # Update this to the latest version available on KDE's GitLab repository
pkgrel=1
pkgdesc="A big launcher giving you easy access to any installed apps and skills"
arch=('x86_64')
url="https://plasma-bigscreen.org/"
license=('GPL2')
groups=()
depends=('kdeconnect-git' 'plasma-nm-git' 'plasma-pa-git' 'plasma-nano-git' 'bluez-qt-git' 'powerdevil-git')
makedepends=('cmake' 'extra-cmake-modules-git' 'git')
optdepends=('libcec: add USB-CEC support in order to be controlled by TV remotes'
            'plasma-remotecontrollers-git: add support for remote controllers')
conflicts=('plasma-bigscreen')
provides=('plasma-bigscreen')
source=("${pkgname}::git+https://invent.kde.org/plasma/${pkgname}.git")

build() {
        cd "$srcdir"/"${pkgname}"
        cmake -B build \
              -DCMAKE_INSTALL_PREFIX="/usr" \
              -DCMAKE_BUILD_TYPE=Release \
              -Wno-dev

        cmake --build build
}

package() {
        DESTDIR="$pkgdir" cmake --install build
}
