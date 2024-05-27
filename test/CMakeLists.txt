# Parent project does not export its library target, so this CML implicitly
# depends on being added from it, i.e. the testing is done only from the build
# tree and is not feasible from an install location

project(mfx-base-appTests LANGUAGES C)

# ---- Tests ----

add_executable(mfx-base-app_test source/mfx-base-app_test.c)
target_link_libraries(mfx-base-app_test PRIVATE mfx-base-app_lib)
target_compile_features(mfx-base-app_test PRIVATE c_std_99)

add_test(NAME mfx-base-app_test COMMAND mfx-base-app_test)

# ---- End-of-file commands ----

add_folders(Test)
