This repo contains CI/CD for a MacOS .app of the Crossfire GTK2 client. Releases are built against the master branch and are listed with the commit date and id.

## Local-only building
Feel free to analyze the workflow build script for the entire process, however below is what you would do to produce a stand-alone binary of the client.

  * Clone this repo
    * `git clone https://github.com/kettek/crossfire-client-macos-build && cd crossfire-client-macos-build`
  * Install homebrew
    * `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
  * Install dependencies
    * `brew install gtk+ vala sdl2_mixer pkgconf libpng gettext cmake libicns`
  * Clone crossfire client and sounds
    * `git clone https://git.code.sf.net/p/crossfire/crossfire-client && cd crossfire-client && git clone https://git.code.sf.net/p/crossfire/crossfire-sounds sounds`
  * Patch
    * `git apply ../patch.diff`
  * Copy macos build script
    * `mkdir gtk-v2/macos && cp ../macos-package.sh ./gtk-v2/macos/macos-package.sh`
  * Compile
    * `mkdir build && cd build && cmake .. && make && make install`

This will produce a binary in the build directory as well as a stand-alone .app.
