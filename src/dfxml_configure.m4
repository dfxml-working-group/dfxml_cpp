#
# mix-ins for dfxml
# Support for hash_t as well.
#
# Revision History:
# 2012 - Simson Garfinkel - Created for bulk_extractor
# 2021 - Simson Garfinkel - Cleaned up. Added LGPL copyright notice.
#
# Copyright (C) 2021 Simson L. Garfinkel.
#
# LICENSE: LGPL Version 3. See COPYING.md for further information.
#

AC_MSG_NOTICE([Including dfxml_configure.m4 from dfxml])
AC_MSG_NOTICE([Note: checks for libewf.h should be in the caller, so they can be disabled])
AC_CHECK_HEADERS([expat.h sys/resource.h sys/utsname.h unistd.h winsock2.h boost/version.hpp pwd.h uuid/uuid.h])
AC_CHECK_FUNCS([gmtime_r getuid gethostname getpwuid getrusage vasprintf ])

# Expat is required
have_expat=yes
AC_CHECK_HEADER([expat.h])
AC_CHECK_LIB([expat],[XML_ParserCreate],,[have_expat="no ";AC_MSG_WARN([expat not found; S3 and Digital Signatures not enabled])])

# Determine UTC date offset
CPPFLAGS="$CPPFLAGS -DUTC_OFFSET=`TZ=UTC date +%z`"

# Get the GIT commit into the GIT_COMMIT variable
AC_CHECK_PROG([git],[git],[yes],[no])
AM_CONDITIONAL([FOUND_GIT],[test "x$git" = xyes])
AM_COND_IF([FOUND_GIT],
        [GIT_COMMIT=`git describe --dirty --always`
         AC_MSG_NOTICE([git commit $GIT_COMMIT])],
        [AC_MSG_WARN([git not found])])

# Do we have the CPUID instruction?
AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#define cpuid(id) __asm__( "cpuid" : "=a"(eax), "=b"(ebx), "=c"(ecx), "=d"(edx) : "a"(id), "b"(0), "c"(0), "d"(0))]], [[unsigned long eax, ebx, ecx, edx;cpuid(0);]])],[have_cpuid=yes],[have_cpuid=no])
if test "$have_cpuid" = yes; then
  AC_DEFINE(HAVE_ASM_CPUID, 1, [define to 1 if __asm__ CPUID is available])
fi

################################################################
## On Win32, crypto requires zlib.
## On Win32, dfxml_writer requires GetProcessMemoryInfo, which requires psapi
case $host in
  *mingw32*)
  AC_CHECK_LIB([z], [gzdopen], [LIBS="-lz $LIBS"], [AC_MSG_ERROR([Could not find zlib library])])
  AC_MSG_NOTICE([Adding -lpsapi])
  LIBS="-lpsapi $LIBS"
  CFLAGS="-static-libgcc $CFLAGS"
  CXXFLAGS="-static-libstdc++ $CXXFLAGS"
esac

################################################################
##
## Crypto Support
##
## MacOS CommonCrypto
AC_CHECK_HEADERS([CommonCrypto/CommonDigest.h])

## gcrypt
AC_CHECK_HEADERS([gcrypt.h])
AC_CHECK_LIB([gpg-error],[gpg_strerror])
AC_CHECK_LIB([gcrypt],[gcry_md_open])

## OpenSSL Note that this works with both OpenSSL 1.0 and OpenSSL 1.1
## EVP_MD_CTX_create() and EVP_MD_CTX_destroy() were renamed to EVP_MD_CTX_new() and EVP_MD_CTX_free() in OpenSSL 1.1.
AC_CHECK_HEADERS([openssl/aes.h openssl/bio.h openssl/evp.h openssl/hmac.h openssl/md5.h openssl/pem.h openssl/rand.h openssl/rsa.h openssl/sha.h openssl/pem.h openssl/x509.h])

# OpenSSL has been installed under at least two different names...
AC_CHECK_LIB([crypto],[EVP_get_digestbyname])
AC_CHECK_LIB([ssl],[SSL_library_init])

## Make sure we have some kind of crypto
have_crypto=NO
AC_CHECK_FUNC([gcry_md_open],          [AC_DEFINE([HAVE_GCRYPT], [1], [Define if GNU CRYPT detected])
                                       have_crypto=YES])
if test "$have_crypto" = NO; then
    AC_CHECK_FUNC([CC_MD2_Init],           [AC_DEFINE([HAVE_COMMONCRYPTO], [1], [Define if Apple CommonCrypto Detected])
                                          have_crypto=YES])
fi
if test "$have_crypto" = NO; then
    AC_CHECK_FUNC([EVP_get_digestbyname],  [AC_DEFINE([HAVE_OPENSSL], [1], [Define if OpenSSL detected])
                                       have_crypto=YES])
fi

if test "$have_crypto" = NO; then
    echo foo
    AC_MSG_ERROR([CommonCrypto, SSL/OpenSSL, or gcrypt support required])
fi
