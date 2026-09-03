#include "BATHY_HOMOG_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C     !ROUTINE: BATHY_HOMOG_MNC_INIT

C     !INTERFACE:
      SUBROUTINE BATHY_HOMOG_MNC_INIT( myThid )

C     !DESCRIPTION:
C     Initialize MNC lookup tables for bathy_homog.

C     !USES:
      IMPLICIT NONE
C     == Global variables ===
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "BATHY_HOMOG.h"

C     !INPUT PARAMETERS:
      INTEGER myThid
CEOP

#ifdef ALLOW_MNC

      IF (useMNC) THEN

      ENDIF

#endif /* ALLOW_MNC */

      RETURN
      END
