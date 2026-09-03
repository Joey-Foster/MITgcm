#include "BATHY_HOMOG_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C !ROUTINE: BATHY_HOMOG_CHECK

C !INTERFACE:
      SUBROUTINE BATHY_HOMOG_CHECK( myThid )

C     !DESCRIPTION:
C     Check dependances with other packages

C     !USES:
      IMPLICIT NONE
C     == Global variables ===
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "BATHY_HOMOG.h"

C     !INPUT PARAMETERS:
C     myThid   :: my Thread Id number
      INTEGER myThid
CEOP

C     !LOCAL VARIABLES:
C     msgBuf   :: Informational/error message buffer
      CHARACTER*(MAX_LEN_MBUF) msgBuf

      _BEGIN_MASTER(myThid)

       WRITE(msgBuf,'(A)') 'BATHY_HOMOG_CHECK: #define BATHY_HOMOG'
       CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )

C--  Check parameters:

C-     Put stops here if some flags are wrongly chosen.
C-     For example, require this package to use tempStepping
C       IF ( .NOT.tempStepping .AND. myPa_applyTendT ) THEN
C        WRITE(msgBuf,'(A)') 'An example requirement is:'
C        CALL PRINT_ERROR( msgBuf, myThid )
C        WRITE(msgBuf,'(A)') 'myPa_applyTendT needs tempStepping=.true.'
C        CALL PRINT_ERROR( msgBuf, myThid )
C        CALL ALL_PROC_DIE( 0 )
C        STOP 'ABNORMAL END: S/R BATHY_HOMOG_CHECK'
C       ENDIF

      _END_MASTER(myThid)

      RETURN
      END
