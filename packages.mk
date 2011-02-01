# These are all flags for the target

# Any X11 system
ifeq ($(TARGET_OS_TYPE),x11)
# X11/Xlib
XLIB_CFLAGS = $(call target-pkg-config-cflags,x11)
XLIB_LDFLAGS = $(call target-pkg-config-libs,x11)

# X11/xcb
XCB_CFLAGS = $(call target-pkg-config-cflags,xcb)
XCB_LDFLAGS = $(call target-pkg-config-libs,xcb)
endif

# Linux only
ifeq ($(TARGET_OS),Linux)
# POSIX timers : clock_gettime, clock_getres, ...
POSIX_TIMERS_CFLAGS =
POSIX_TIMERS_LDFLAGS = -lrt

# Curses/ncurses
CURSES_CFLAGS =
CURSES_LDFLAGS = -lncurses
endif

# Windows only
ifeq ($(TARGET_OS_TYPE),win32)
# Windows GDI
GDI_CFLAGS =
GDI_LDFLAGS = -lgdi32

# Winsock2
WS2_CFLAGS =
WS2_LDFLAGS = -lws2_32

# pdcurses
CURSES_CFLAGS = -Ipath/to/pdcurses/include
CURSES_LDFLAGS = -lpdcurses
endif

# Lua 5.1
LUA51_CFLAGS ?= $(call target-pkg-config-cflags,lua5.1)
LUA51_LDFLAGS ?= $(call target-pkg-config-libs,lua5.1)

# OpenGL
GL_CFLAGS = $(call target-pkg-config-cflags,gl)
GL_LDFLAGS = $(call target-pkg-config-libs,gl)
GLU_CFLAGS = $(call target-pkg-config-cflags,glu)
GLU_LDFLAGS = $(call target-pkg-config-libs,glu)
