using BinaryBuilder, Pkg

name = "libmousetrap"
version = v"0.4.1"

# Collection of sources required to complete build
sources = [
    GitSource("https://github.com/HyperSphereStudio/mousetrap.git", "d1892f62b8bc433e428211a740706a18992cffda"),
    GitSource("https://github.com/HyperSphereStudio/mousetrap_julia_binding.git", "f63b6153e5d4a5d2f2621b1d2e914edea0a385d1")
]

script = raw"""
cd $WORKSPACE/srcdir
echo -e "[binaries]\ncmake='/usr/bin/cmake'" >> cmake_toolchain_patch.ini
cd mousetrap
install_license LICENSE
meson setup build --cross-file=$MESON_TARGET_TOOLCHAIN --cross-file=../cmake_toolchain_patch.ini
meson install -C build
cd ../mousetrap_julia_binding
meson setup build --cross-file=$MESON_TARGET_TOOLCHAIN --cross-file=../cmake_toolchain_patch.ini -DJulia_INCLUDE_DIRS=$prefix/include/julia
meson install -C build
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
#platforms = filter(p -> nbits(p) == 64 && !Sys.isapple(p), supported_platforms())
#platforms = [Platform("x86_64", "linux")]

platforms = [ Platform("x86_64", "windows"; ) ]
platforms = expand_cxxstring_abis(platforms)

println("Selected Platforms [no-apple]:", platforms)

# The products that we will ensure are always built
products = [
    LibraryProduct("libmousetrap", :mousetrap),
    LibraryProduct("libmousetrap_julia_binding", :mousetrap_julia_binding)
]

x11_platforms = filter(p -> Sys.islinux(p) || Sys.isfreebsd(p), platforms)

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency("GLEW_jll")
    Dependency("GLU_jll"; platforms = x11_platforms)
    Dependency("GTK4_jll")
    Dependency("libadwaita_jll")
    Dependency("OpenGLMathematics_jll")
    Dependency("libcxxwrap_julia_jll")
    BuildDependency("libjulia_jll")
    BuildDependency("Xorg_xorgproto_jll"; platforms = x11_platforms)
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; julia_compat="1.7", preferred_gcc_version = v"9")
