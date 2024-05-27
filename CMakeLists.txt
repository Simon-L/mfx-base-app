cmake_minimum_required(VERSION 3.14)

include(cmake/prelude.cmake)

project(
    mfx-base-app
    VERSION 0.1.0
    DESCRIPTION "Short description"
    HOMEPAGE_URL "https://example.com/"
    LANGUAGES C
)

include(cmake/project-is-top-level.cmake)
include(cmake/variables.cmake)

# ---- Make prefix rules ----

if( NOT DEFINED PREFIX_SYSTEM)
    set(PREFIX_SYSTEM ${CMAKE_SYSTEM_NAME})
    message(NOTICE "Using ${CMAKE_SYSTEM_NAME} as target system" )
else()
    message(NOTICE "Using ${PREFIX_SYSTEM} as target system" )
endif()

# URLs
if (${PREFIX_SYSTEM} STREQUAL "Windows")
    set(FILE_IMGUI lua-imgui-win64.zip)
elseif (${PREFIX_SYSTEM} STREQUAL "Linux")
    set(FILE_IMGUI lua-imgui-ubuntu.zip)
elseif (${PREFIX_SYSTEM} STREQUAL "Darwin")
    set(FILE_IMGUI lua-imgui-macos.zip)
endif()
set(URL_IMGUI https://nightly.link/Simon-L/imgui-luajit-setup/workflows/build/main/${FILE_IMGUI})

file(
    DOWNLOAD ${URL_IMGUI} ${CMAKE_BINARY_DIR}/${FILE_IMGUI}
    SHOW_PROGRESS
)

# ---- Declare library ----

add_library(
    mfx-base-app_lib OBJECT
    source/lib.c
)

target_include_directories(
    mfx-base-app_lib ${warning_guard}
    PUBLIC
    "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/source>"
)

target_compile_features(mfx-base-app_lib PUBLIC c_std_99)

# ---- Declare executable ----

add_executable(mfx-base-app_exe source/main.c)
add_executable(mfx-base-app::exe ALIAS mfx-base-app_exe)

set_property(TARGET mfx-base-app_exe PROPERTY OUTPUT_NAME mfx-base-app)

target_compile_features(mfx-base-app_exe PRIVATE c_std_99)

target_link_libraries(mfx-base-app_exe PRIVATE mfx-base-app_lib)

if (${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
    add_custom_target(hererocks ALL
        COMMAND python ${CMAKE_SOURCE_DIR}/hererocks.py prefix --target vs -j @v2.1 -rlatest --verbose
        COMMAND prefix/bin/luarocks.bat install inspect
        COMMAND prefix/bin/luarocks.bat install luasocket
        COMMAND prefix/bin/luarocks.bat install rxi-json-lua
        COMMAND prefix/bin/luarocks.bat install penlight
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )
else()
    add_custom_target(hererocks ALL
        COMMAND python ${CMAKE_SOURCE_DIR}/hererocks.py prefix -j @v2.1 -rlatest --verbose
        COMMAND prefix/bin/luarocks install inspect
        COMMAND prefix/bin/luarocks install luasocket
        COMMAND prefix/bin/luarocks install luaposix
        COMMAND prefix/bin/luarocks install rxi-json-lua
        COMMAND prefix/bin/luarocks install penlight
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )
endif()

add_custom_target(add_imgui_1
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/ig   
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
add_custom_target(add_imgui ALL
    DEPENDS add_imgui_1
    COMMAND ${CMAKE_COMMAND} -E tar xzf ${CMAKE_BINARY_DIR}/${FILE_IMGUI}
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_BINARY_DIR}/ig/lua ${CMAKE_BINARY_DIR}/prefix/share/lua/5.1
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/ig/lua
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_BINARY_DIR}/ig ${CMAKE_BINARY_DIR}/prefix/bin
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/ig
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/ig
)

add_dependencies(add_imgui hererocks)
add_dependencies(mfx-base-app_exe hererocks)
add_dependencies(mfx-base-app_lib hererocks)

# ---- Install rules ----

if(NOT CMAKE_SKIP_INSTALL_RULES)
  include(cmake/install-rules.cmake)
endif()

# ---- Developer mode ----

if(NOT mfx-base-app_DEVELOPER_MODE)
  return()
elseif(NOT PROJECT_IS_TOP_LEVEL)
  message(
      AUTHOR_WARNING
      "Developer mode is intended for developers of mfx-base-app"
  )
endif()

include(cmake/dev-mode.cmake)
