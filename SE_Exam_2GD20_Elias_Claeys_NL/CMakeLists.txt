cmake_minimum_required(VERSION 3.20)
project(Tetris)

# C++ 17 required (filesystem)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(FetchContent)

# Fetch LUA
# ++++++++++
FetchContent_Declare(
    lua
    URL https://github.com/marovira/lua/archive/refs/tags/5.4.4.tar.gz
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)
FetchContent_MakeAvailable(lua)

# Fetch SOL2
# ++++++++++
FetchContent_Declare(
    sol2
    URL https://github.com/ThePhD/sol2/archive/refs/tags/v3.3.0.tar.gz
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)
FetchContent_MakeAvailable(sol2)

# Gather Sources
# ++++++++++++++
list(APPEND ENGINE_SOURCES 
            "CPPFiles/AbstractGame.cpp"
            "CPPFiles/AbstractGame.h"
            "CPPFiles/GameDefines.h"
            "CPPFiles/GameEngine.cpp"
            "CPPFiles/GameEngine.h"
            "CPPFiles/GameWinMain.cpp"
            "CPPFiles/GameWinMain.h"
            "CPPFiles/Game.cpp"
            "CPPFiles/Game.h"
)

list(APPEND LUA_SOURCES 
            "script.lua"
)

list(APPEND ASSET_SOURCES
            "resources/PublicPixel.ttf"
            "resources/TetrisTheme.mp3"
)

# Add Executable Target
add_executable(${PROJECT_NAME} WIN32 ${ENGINE_SOURCES} ${LUA_SOURCES})

#Link lua and sol2
target_link_libraries(${PROJECT_NAME} PRIVATE sol2 lua::lua)

# Add required Windows libraries
target_link_libraries(${PROJECT_NAME} PRIVATE user32 gdi32 winmm)

# Enable Unicode
target_compile_definitions(${PROJECT_NAME} PRIVATE UNICODE _UNICODE)

# Copy Lua Scripts and Asset Files
# ++++++++++++++++++++++++++++++++++++++
add_custom_target(CopyAssets ALL
    COMMENT "Copying Lua scripts and other assets to output directory"
)

# Copy Lua scripts
FOREACH(LUA_SOURCE IN LISTS LUA_SOURCES)
    add_custom_command(TARGET CopyAssets POST_BUILD 
    COMMAND ${CMAKE_COMMAND} -E copy_if_different 
    ${CMAKE_CURRENT_SOURCE_DIR}/${LUA_SOURCE}
    $<TARGET_FILE_DIR:${PROJECT_NAME}>/${LUA_SOURCE})
ENDFOREACH()

# Copy textures / assets
FOREACH(ASSET_FILE IN LISTS ASSET_SOURCES)
    add_custom_command(TARGET CopyAssets POST_BUILD 
    COMMAND ${CMAKE_COMMAND} -E copy_if_different 
    ${CMAKE_CURRENT_SOURCE_DIR}/${ASSET_FILE}
    $<TARGET_FILE_DIR:${PROJECT_NAME}>/${ASSET_FILE})
ENDFOREACH()

# Make the executable depend on the copy target 
add_dependencies(${PROJECT_NAME} CopyAssets)