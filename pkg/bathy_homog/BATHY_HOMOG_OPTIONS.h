#ifndef BATHY_HOMOG_OPTIONS_H
#define BATHY_HOMOG_OPTIONS_H
#include "PACKAGES_CONFIG.h"
#include "CPP_OPTIONS.h"

CBOP
C !ROUTINE: BATHY_HOMOG_OPTIONS.h
C !INTERFACE:
C #include "BATHY_HOMOG_OPTIONS.h"

C !DESCRIPTION:
C *==================================================================*
C | CPP options file for pkg "bathy_homog":
C | Control which optional features to compile in this package code.
C *==================================================================*
CEOP

#ifdef ALLOW_BATHY_HOMOG
C Place CPP define/undef flag here

C to reduce memory storage, disable unused array with those CPP flags


#endif /* ALLOW_BATHY_HOMOG */
#endif /* BATHY_HOMOG_OPTIONS_H */
