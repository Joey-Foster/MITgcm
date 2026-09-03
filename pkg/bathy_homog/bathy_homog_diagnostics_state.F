#include "BATHY_HOMOG_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C !ROUTINE: BATHY_HOMOG_DIAGNOSTICS_STATE

C !INTERFACE:
      SUBROUTINE BATHY_HOMOG_DIAGNOSTICS_STATE(
     I                     myTime, myIter, myThid )

C     !DESCRIPTION:
C     Fill-in diagnostics array for BATHY_HOMOG state variables

C     !USES:
      IMPLICIT NONE
C     == Global variables ===
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
C  put following include within #ifdef in case this file is copied to local
C  code dir but pkg/bathy_homog is not compiled (missing file BATHY_HOMOG.h).
#ifdef ALLOW_BATHY_HOMOG
#include "BATHY_HOMOG.h"
#endif

C     !INPUT PARAMETERS:
C     myTime   :: Current time of simulation ( s )
C     myIter   :: Current iteration number in simulation
C     myThid   :: my Thread Id number
      _RL     myTime
      INTEGER myIter, myThid
CEOP

#ifdef ALLOW_BATHY_HOMOG
C     !LOCAL VARIABLES:

#ifdef ALLOW_DIAGNOSTICS
      IF ( useDiagnostics ) THEN

      ENDIF
#endif /* ALLOW_DIAGNOSTICS */

#endif /* ALLOW_BATHY_HOMOG */

      RETURN
      END
