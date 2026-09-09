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

       WRITE(msgBuf,'(2A)') 'BATHY_HOMOG_CHECK:',
     &                      '#define ALLOW_BATHY_HOMOG'
       CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )

C--  Check parameters:

       IF ( staggerTimeStep .AND. includeAdvec_Homog ) THEN
        WRITE(msgBuf,'(3A)') 'BATHY_HOMOG_CHECK:',
     &                       'includeAdvec_Homog is ',
     &                       'incompatible with staggerTimeStep'
        CALL PRINT_ERROR( msgBuf, myThid )
        CALL ALL_PROC_DIE( 0 )
        STOP 'ABNORMAL END: S/R BATHY_HOMOG_CHECK'
       ENDIF

      _END_MASTER(myThid)

      RETURN
      END
