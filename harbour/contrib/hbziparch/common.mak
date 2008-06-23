#
# $Id$
#

LIBNAME = $(LIBPREF)hbziparch

LIB_PATH = $(LIB_DIR)$(LIBNAME)$(LIBEXT)

LIB_OBJS = \
    $(OBJ_DIR)hbziparc$(OBJEXT) \
    $(OBJ_DIR)hbcomprs$(OBJEXT) \
    \
    $(OBJ_DIR)hbzipnew$(OBJEXT) \
    $(OBJ_DIR)hbzipcom$(OBJEXT) \
    $(OBJ_DIR)ziparchive$(OBJEXT) \
    $(OBJ_DIR)ZipPlatform_win$(OBJEXT) \
    $(OBJ_DIR)zipstorage$(OBJEXT) \
    $(OBJ_DIR)zipstring$(OBJEXT) \
    $(OBJ_DIR)zipplatformcomm$(OBJEXT) \
    $(OBJ_DIR)ZipPathComponent_win$(OBJEXT) \
    $(OBJ_DIR)zipmemfile$(OBJEXT) \
    $(OBJ_DIR)zipfileheader$(OBJEXT) \
    $(OBJ_DIR)zipfile$(OBJEXT) \
    $(OBJ_DIR)zipexception$(OBJEXT) \
    $(OBJ_DIR)zipcompatibility$(OBJEXT) \
    $(OBJ_DIR)zipcentraldir$(OBJEXT) \
    $(OBJ_DIR)zipautobuffer$(OBJEXT) \
    $(OBJ_DIR)stdafx$(OBJEXT) \

all: \
    $(LIB_PATH) \
