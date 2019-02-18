require "third_party/QDiscord/src/premake/extensions/premake-qt/qt"

local qtdir = io.readfile(".qtdir")

workspace "QDiscordClient"
  configurations {
    "Debug",
    "Release",
  }
  platforms {
    io.popen("uname -m", "r"):read("*l")
  }

  QTDIR_X86 = qtdir
  QTDIR_X64 = qtdir
  dofile "third_party/QDiscord/src/premake/libs.lua"

  project "Client"
    premake.extensions.qt.enable()
    kind "ConsoleApp"
    links {"QDiscordCore"}
    location "build/"
    qtgenerateddir "src/generated/"
    qtpath(qtdir)
    qtprefix "Qt5"
    targetdir "bin/"

    files {
      "src/**.cpp",
      "src/**.h",
    }
    includedirs {
      "src/",
      "third_party/QDiscord/src/core/",
    }
    qtmodules {
      "core",
      "gui",
      "network",
      "websockets",
      "widgets",
    }

    filter {"configurations:Debug"}
      qtsuffix "d"

      filter {"configurations:Release"}
        optimize "Full"
        defines {
          "QT_NO_DEBUG",
        }

    filter {}
