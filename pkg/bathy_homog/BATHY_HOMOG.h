CBOP
C     !ROUTINE: BATHY_HOMOG.h
C     !INTERFACE:
C     #include "BATHY_HOMOG.h"

C     !DESCRIPTION:
C     *================================================================*
C     | BATHY_HOMOG.h
C     | o Header file defining "bathy_homog" parameters and variables
C     *================================================================*
CEOP

C     BATHY_HOMOG parameters
      LOGICAL includeAdvec_Homog
      LOGICAL nonSquareDomain

      COMMON /BATHY_HOMOG_PARAMS/ includeAdvec_Homog, nonSquareDomain


C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
