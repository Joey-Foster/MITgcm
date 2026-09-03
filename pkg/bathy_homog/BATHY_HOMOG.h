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

      COMMON /BATHY_HOMOG_PARAMS_L/ includeAdvec_Homog


C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
