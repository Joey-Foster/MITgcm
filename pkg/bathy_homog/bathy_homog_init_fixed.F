#include "BATHY_HOMOG_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C !ROUTINE: BATHY_HOMOG_INIT_FIXED

C !INTERFACE:
      SUBROUTINE BATHY_HOMOG_INIT_FIXED( myThid )

C     !DESCRIPTION:
C     Initialize BATHY_HOMOG variables that are kept fixed during the run.

C     !USES:
      IMPLICIT NONE
C     == Global variables ===
#include "EEPARAMS.h"
#include "SIZE.h"
#include "PARAMS.h"
#include "BATHY_HOMOG.h"

C     !INPUT/OUTPUT PARAMETERS:
C     myThid ::  my Thread Id number
      INTEGER myThid
CEOP

C     !LOCAL VARIABLES:

#ifdef ALLOW_MNC
      IF (useMNC) THEN
        CALL BATHY_HOMOG_MNC_INIT( myThid )
      ENDIF
#endif /* ALLOW_MNC */

#ifdef ALLOW_DIAGNOSTICS
      IF ( useDiagnostics ) THEN
        CALL BATHY_HOMOG_DIAGNOSTICS_INIT( myThid )
      ENDIF
#endif

      RETURN
      END
