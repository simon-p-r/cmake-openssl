cmake_minimum_required(VERSION 3.8.0 FATAL_ERROR)

if(USE_VERSION)
   set(OPENSSL_VERSION ${USE_VERSION})
   set(OPENSSL_SHA256 ${USER_SHA_256})
else()
   set(OPENSSL_VERSION "1.0.2l")
   set(OPENSSL_SHA256 "ce07195b659e75f4e1db43552860070061f156a98bb37b672b101ba6e3ddf30c")
endif()



set(PROJECT_NAME "OpenSSL-${OPENSSL_VERSION}")
project(${PROJECT_NAME} C)


if(MSVC)
    string(FIND ${CMAKE_GENERATOR} "Win64" IS_64_BIT)
    if(${IS_64_BIT} GREATER -1)
        set(CMAKE_TARGET_ARCH "x64")
    else()
        set(CMAKE_TARGET_ARCH "x86")
    endif()
endif(MSVC)


if(OPENSSL_INSTALL_PREFIX)
   set(CMAKE_INSTALL_PREFIX ${OPENSSL_INSTALL_PREFIX})
else()
   set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/${PROJECT_NAME})
endif(OPENSSL_INSTALL_PREFIX)



#Set Output Directory based on build type and Architecture
if(CMAKE_BUILD_TYPE MATCHES "Debug")
    set(INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/Debug/${CMAKE_C_COMPILER_ID}/${CMAKE_TARGET_ARCH})
else()
    set(INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/Release/${CMAKE_C_COMPILER_ID}/${CMAKE_TARGET_ARCH})
endif()


list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/CMake")

#Required for building all the modules
include(ExternalProject)


if(EXISTS "${INSTALL_DIR}")
   set(OpenSSL_ROOT_DIR ${INSTALL_DIR})
   set(OpenSSL_INCLUDE_DIR ${OpenSSL_ROOT_DIR}/include/)
   set(OpenSSL_LIBRARY_DIR ${OpenSSL_ROOT_DIR}/lib/)
else()
   set(OpenSSL_ROOT_DIR "")
   set(OpenSSL_INCLUDE_DIR "")
   set(OpenSSL_LIBRARY_DIR "")
   include(openSSL)
endif()



message("OpenSSL root dir ${OpenSSL_ROOT_DIR}")

