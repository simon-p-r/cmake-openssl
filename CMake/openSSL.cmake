message(STATUS "Preparing OpenSSL ${OPENSSL_VERSION}")

set(SOURCE_DIR ${CMAKE_BINARY_DIR}/modules/OpenSSL)

#-----------------------------
# Define OpenSSL Commands
#-----------------------------

if(UNIX)
  set(OpenSSL_Config_Command ./Configure)
  set(OpenSSL_Build_Command make)
  set(OpenSSL_Install_Command make install)
elseif(WIN32)
  set(OpenSSL_Config_Command perl Configure)
  if(${CMAKE_TARGET_ARCH} STREQUAL "x64") #64 bit compiler
    set(OpenSSL_Build_Command ms\\do_win64a) 
  else()
    set(OpenSSL_Build_Command ms\\do_nasm.bat) 
  endif() 
  set(OpenSSL_Install_Command) #To be defined when evaluating static/shared libraries
endif()

#-----------------------------
# Define OpenSSL Compile Type and Toolset
#-----------------------------

if(UNIX)
  set(OpenSSL_ARCHITECTURE "linux-${ARCHITECTURE}")
  if(CROSSBUILD)
    set(OpenSSL_ARCHITECTURE os/compiler:${CROSSCOMPILER})
  endif()  
  if(${CMAKE_BUILD_TYPE} MATCHES "Debug")
      set(OpenSSL_ARCHITECTURE -g ${OpenSSL_ARCHITECTURE})
  endif()
elseif(WIN32)
  set(OpenSSL_ARCHITECTURE VC-WIN32)  
  if(${CMAKE_TARGET_ARCH} STREQUAL "x64") #64 bit compiler
    set(OpenSSL_ARCHITECTURE VC-WIN64A)
  endif()
  if(${CMAKE_BUILD_TYPE} MATCHES "Debug")
      set(OpenSSL_ARCHITECTURE debug-${OpenSSL_ARCHITECTURE})
  endif()
endif()

#-----------------------------
# Define OpenSSL Output Dir
#-----------------------------

set(OPENSSL_OUTPUT_DIR ${INSTALL_DIR}/OpenSSL)

#-----------------------------
# Define OpenSSL Static/Dynamic Linking
#-----------------------------

set(OPENSSL_LINK_TYPE no-shared)
set(OpenSSL_Windows_Build_Command "")
#Under Windows, if static, build nt.mak, otherwise ntdll.mak
if(WIN32)
  set(OpenSSL_Windows_Build_Command nmake -f ms\\nt.mak)
  set(OpenSSL_Install_Command nmake -f ms\\nt.mak install)
endif()

if(BUILD_SHARED_LIBS)
  set(OPENSSL_LINK_TYPE shared)
  if(WIN32)
    set(OpenSSL_Windows_Build_Command nmake -f ms\\ntdll.mak)
    set(OpenSSL_Install_Command nmake -f ms\\ntdll.mak install)
  endif()
endif()

#-----------------------------
# Define OpenSSL extra options
#-----------------------------

if(UNIX)
  set(OPENSSL_EXTRA_OPTIONS threads)
else()
  if(${CMAKE_TARGET_ARCH} STREQUAL "x64")
     set(OPENSSL_EXTRA_OPTIONS no-asm) #Does not working with 64bit builds
  else()
     set(OPENSSL_EXTRA_OPTIONS "") #must install nasm
  endif()
endif()

#-----------------------------
# Define Download
#-----------------------------



ExternalProject_Add(
    OpenSSL_Download
    PREFIX            ${SOURCE_DIR}
    TMP_DIR           ${SOURCE_DIR}/temp
    STAMP_DIR         ${SOURCE_DIR}/stamp
    #--Download step--------------
    DOWNLOAD_DIR      ${SOURCE_DIR}/download
    URL               "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
    URL_HASH          SHA256=${OPENSSL_SHA256}
    #--Configure step-------------
    SOURCE_DIR        ${SOURCE_DIR}/src
    # CONFIGURE_COMMAND ${OpenSSL_Config_Command} ${OpenSSL_ARCHITECTURE} ${OPENSSL_LINK_TYPE} --prefix=${INSTALL_DIR}
    CONFIGURE_COMMAND ${OpenSSL_Config_Command} ${OpenSSL_ARCHITECTURE} ${OPENSSL_LINK_TYPE} ${OPENSSL_EXTRA_OPTIONS} --prefix=${INSTALL_DIR}
    #--Build step-------------
    BUILD_COMMAND     ${OpenSSL_Build_Command}
    BUILD_IN_SOURCE   1
    #--Install step---------------
    INSTALL_COMMAND   ""
    INSTALL_DIR       ""
)

#-----------------------------
# Define Project
#-----------------------------

ExternalProject_Add(
    OpenSSL
    PREFIX            ${SOURCE_DIR}
    TMP_DIR           ${SOURCE_DIR}/temp
    STAMP_DIR         ${SOURCE_DIR}/stamp
    #--Update/Patch step----------
    UPDATE_COMMAND    ""
    DOWNLOAD_COMMAND ""
    #--Configure step-------------
    SOURCE_DIR        ${SOURCE_DIR}/src
    CONFIGURE_COMMAND ""
    #--Build step-------------
    BUILD_COMMAND     ${OpenSSL_Windows_Build_Command}
    BUILD_IN_SOURCE   1
    #--Install step---------------
    INSTALL_COMMAND   ${OpenSSL_Install_Command}
    INSTALL_DIR       ${INSTALL_DIR}
)

add_dependencies(OpenSSL OpenSSL_Download)

set(OpenSSL_ROOT_DIR    ${OPENSSL_OUTPUT_DIR})
set(OpenSSL_INCLUDE_DIR ${OPENSSL_OUTPUT_DIR}/include/)
set(OpenSSL_LIBRARY_DIR ${OPENSSL_OUTPUT_DIR}/lib/)
