cmake_minimum_required(VERSION 3.16)
project(DeepTrace VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Runtime output directory for compiled binaries
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Enable thread support
find_package(Threads REQUIRED)

# Common include path
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

# -----------------------------------------------------------------------------
# Core Library: Packet parsing, PCAP reader/writer, SNI extractor, Data types
# -----------------------------------------------------------------------------
add_library(deeptrace_core STATIC
    src/pcap_reader.cpp
    src/packet_parser.cpp
    src/sni_extractor.cpp
    src/types.cpp
)

# -----------------------------------------------------------------------------
# Modular Engine Library: Rule manager, Flow tracker, Load balancer, Fast path
# -----------------------------------------------------------------------------
add_library(deeptrace_engine STATIC
    src/connection_tracker.cpp
    src/fast_path.cpp
    src/load_balancer.cpp
    src/rule_manager.cpp
    src/dpi_engine.cpp
)
target_link_libraries(deeptrace_engine PUBLIC deeptrace_core Threads::Threads)

# -----------------------------------------------------------------------------
# Executable Targets
# -----------------------------------------------------------------------------

# 1. Main Modular Multi-threaded DPI Engine (Full Enterprise Architecture)
add_executable(deeptrace src/main_dpi.cpp)
target_link_libraries(deeptrace PRIVATE deeptrace_engine)

# 2. Standalone Multi-threaded DPI Engine (High-Performance Monolithic MT)
add_executable(deeptrace-mt src/dpi_mt.cpp)
target_link_libraries(deeptrace-mt PRIVATE deeptrace_core Threads::Threads)

# 3. Simple Single-threaded DPI Engine (Deterministic Reference Implementation)
add_executable(deeptrace-simple src/main_simple.cpp)
target_link_libraries(deeptrace-simple PRIVATE deeptrace_core)

# 4. Raw Packet Analyzer & Wireshark-like Protocol Inspector
add_executable(packet-analyzer src/main.cpp)
target_link_libraries(packet-analyzer PRIVATE deeptrace_core)
