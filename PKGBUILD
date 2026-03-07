# Maintainer: Brandon
pkgname=plasma-bigscreen-git
pkgver=r1234.gabcdef
pkgrel=1
pkgdesc="KDE Plasma UI for TV-box experience (Auto-Config & CachyOS Optimized)"
arch=('x86_64' 'aarch64')
url="https://invent.kde.org/plasma/plasma-bigscreen"
license=('GPL-2.0-or-later')

# Merged & Corrected Dependencies
depends=(
    'sddm'
    'plasma-workspace' 
    'kwin' 
    'qt6-wayland' 
    'plasma5support' 
    'powerdevil' 
    'kdeplasma-addons'
    'kdeconnect'
    'plasma-nm'
    'plasma-pa'
    'plasma-nano'
    'plasma-settings'
    'qt6-virtualkeyboard'
    'bluez-qt'
    'qt6-webengine'
    'polkit-kde-agent'
)

makedepends=(
    'cmake'
    'extra-cmake-modules'
    'git' 'vulkan-headers'
    'plasma-wayland-protocols'
    'kdoctools'
)
optdepends=('libcec: USB-CEC support' 'mycroft-core: voice control')
provides=('plasma-bigscreen')
conflicts=('plasma-bigscreen')
install=plasma-bigscreen.install
source=('git+https://invent.kde.org/plasma/plasma-bigscreen.git')
md5sums=('SKIP')

pkgver() {
    cd "plasma-bigscreen"
    printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

build() {
    cmake -B build -S "plasma-bigscreen" \
        -DCMAKE_INSTALL_PREFIX="/usr" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_TESTING=OFF
    cmake --build build
}

package() {
    DESTDIR="$pkgdir" cmake --install build

    # Automatically fix the .desktop file to use dbus-run-session
    if [ -f "$pkgdir/usr/share/wayland-sessions/plasma-bigscreen-wayland.desktop" ]; then
        sed -i 's|Exec=.*|Exec=dbus-run-session /usr/bin/plasma-bigscreen-wayland|' \
            "$pkgdir/usr/share/wayland-sessions/plasma-bigscreen-wayland.desktop"
    fi
}
