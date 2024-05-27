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
