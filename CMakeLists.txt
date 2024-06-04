cmake_minimum_required(VERSION 3.14)

include(cmake/prelude.cmake)

project(
    mfx-base-app
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

# ---- Declare library ----

# add_library(
#     mfx-base-app_lib OBJECT
#     source/lib.c
# )
# 
# target_include_directories(
#     mfx-base-app_lib ${warning_guard}
#     PUBLIC
#     "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/source>"
# )
# 
# target_compile_features(mfx-base-app_lib PUBLIC c_std_99)

# ---- Declare executable ----

include(cmake/CPM.cmake)

set(IMPL_GLFW OFF)
set(IMPL_SDL ON)
set(IMPL_OPENGL2 OFF)
set(IMPL_OPENGL3 ON)
set(IMGUI_FREETYPE OFF)
set(IMPL_EXTRAS ON)
set(LUAJIT_BIN ${CMAKE_BINARY_DIR}/sdl2-imgui)

CPMAddPackage(NAME LuaJIT-GL
    GITHUB_REPOSITORY sonoro1234/LuaJIT-GL
    GIT_TAG main
)

CPMAddPackage(NAME LuaJIT-SDL2
    GITHUB_REPOSITORY Simon-L/LuaJIT-SDL2
    GIT_TAG master
)

CPMAddPackage(NAME LuaJIT-ImGui
    GITHUB_REPOSITORY Simon-L/LuaJIT-ImGui
    GIT_TAG docking_inter
)

add_executable(mfx-base-app_exe source/main.c)
add_executable(mfx-base-app::exe ALIAS mfx-base-app_exe)

set_property(TARGET mfx-base-app_exe PROPERTY OUTPUT_NAME mfx-base-app)

target_compile_features(mfx-base-app_exe PRIVATE c_std_99)

# target_link_libraries(mfx-base-app_exe PRIVATE mfx-base-app_lib)

set(LUAROCKS prefix/bin/luarocks)
set(OPENSSL_OPTS )
if (${PREFIX_SYSTEM} STREQUAL "Windows")
    add_custom_target(hererocks ALL
        COMMAND python ${CMAKE_SOURCE_DIR}/hererocks.py prefix --target vs -j @v2.1 -rlatest --verbose
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )
    set(LUAROCKS prefix/bin/luarocks.bat)
    set(OPENSSL_OPTS OPENSSL_DIR="C:/Program Files/OpenSSL")
else()
    add_custom_target(hererocks ALL
        COMMAND python ${CMAKE_SOURCE_DIR}/hererocks.py prefix -j @v2.1 -rlatest --verbose
        COMMAND prefix/bin/luarocks install luaposix
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )
endif()

add_custom_target(luarocks_modules ALL
    COMMAND ${LUAROCKS} install inspect
    COMMAND ${LUAROCKS} install luasocket
    COMMAND ${LUAROCKS} install rxi-json-lua
    COMMAND ${LUAROCKS} install penlight
    COMMAND ${LUAROCKS} install lua-path
    COMMAND ${LUAROCKS} install lpeg
    COMMAND ${LUAROCKS} install lua-llthreads2
    COMMAND ${LUAROCKS} install ldoc
    COMMAND ${LUAROCKS} install etlua
    COMMAND ${LUAROCKS} install luasec ${OPENSSL_OPTS}
    COMMAND ${LUAROCKS} install fun
    COMMAND ${LUAROCKS} install markdown
    COMMAND ${LUAROCKS} install argparse
    COMMAND ${LUAROCKS} install environ
    COMMAND ${LUAROCKS} install middleclass
    COMMAND ${LUAROCKS} install lua-log
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

if(${PREFIX_SYSTEM} STREQUAL "Linux")
    set(APP_FILE "app.sh")
elseif(${PREFIX_SYSTEM} STREQUAL "Windows")
    set(APP_FILE "app.bat")
elseif(${PREFIX_SYSTEM} STREQUAL "Darwin")
    set(APP_FILE "app.command")
endif()

add_custom_target(add_app ALL
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/app ${CMAKE_BINARY_DIR}/prefix/app
    COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_BINARY_DIR}/prefix/hererocks.manifest
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

add_dependencies(luarocks_modules hererocks)
add_dependencies(add_app cimgui_sdl)
add_dependencies(add_app hererocks)
add_dependencies(mfx-base-app_exe hererocks)
# add_dependencies(mfx-base-app_lib hererocks)

# ---- Install rules ----

if(NOT CMAKE_SKIP_INSTALL_RULES)
  include(cmake/install-rules.cmake)
endif()

set(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP TRUE)
include (InstallRequiredSystemLibraries)
INSTALL(FILES $<TARGET_FILE:cimgui_sdl> $<TARGET_FILE:SDL2> DESTINATION bin)
INSTALL(FILES ${LuaJIT-GL_SOURCE_DIR}/gl.lua ${LuaJIT-SDL2_SOURCE_DIR}/sdl2_ffi.lua ${LuaJIT-SDL2_SOURCE_DIR}/sdlAudioPlayer.lua DESTINATION share/lua/5.1)
INSTALL(DIRECTORY ${CMAKE_BINARY_DIR}/prefix/ DESTINATION .)
INSTALL(DIRECTORY ${LuaJIT-ImGui_SOURCE_DIR}/lua/imgui DESTINATION share/lua/5.1/)
INSTALL(FILES ${CMAKE_SOURCE_DIR}/${APP_FILE}
        PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ
        DESTINATION ${CMAKE_BINARY_DIR}/prefix/)
install(
    TARGETS mfx-base-app_exe
    DESTINATION .
)
if(UNIX)
    install(FILES ${CMAKE_BINARY_DIR}/prefix/bin/lua
        PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ
        DESTINATION bin)
endif(UNIX)

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
