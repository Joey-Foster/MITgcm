#include "BATHY_HOMOG_OPTIONS.h"

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
CBOP
C !ROUTINE: BATHY_HOMOG_READPARMS

C !INTERFACE:
      SUBROUTINE BATHY_HOMOG_READPARMS( myThid )

C     !DESCRIPTION:
C     Initialize BATHY_HOMOG variables and constants.

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

C     !LOCAL VARIABLES:
C     msgBuf     :: Informational/error message buffer
C     iUnit      :: Work variable for IO unit number
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER iUnit

      NAMELIST /BATHY_HOMOG_PARM01/ 
     &    includeAdvec_Homog, nonSquareDomain

      IF ( .NOT.useBATHY_HOMOG ) THEN
C-    pkg BATHY_HOMOG is not used
        _BEGIN_MASTER(myThid)
C-    Track pkg activation status:
C     print a (weak) warning if data.bathy_homog is found
         CALL PACKAGES_UNUSED_MSG( 'useBATHY_HOMOG', ' ', ' ' )
        _END_MASTER(myThid)
        RETURN
      ENDIF

      _BEGIN_MASTER(myThid)

C--   Default values for BATHY_HOMOG
      includeAdvec_Homog = .FALSE.
      nonSquareDomain    = .FALSE.

      WRITE(msgBuf,'(A)') 
     &      'BATHY_HOMOG_READPARMS: opening data.bathy_homog'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )
      CALL OPEN_COPY_DATA_FILE(
     I                   'data.bathy_homog', 'BATHY_HOMOG_READPARMS',
     O                   iUnit,
     I                   myThid )

C     Read parameters from open data file
      READ(UNIT=iUnit,NML=BATHY_HOMOG_PARM01)
      WRITE(msgBuf,'(A)')
     &    'BATHY_HOMOG_READPARMS: finished reading data.bathy_homog'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT, myThid )
C     Close the open data file
#ifdef SINGLE_DISK_IO
      CLOSE(iUnit)
#else
      CLOSE(iUnit,STATUS='DELETE')
#endif /* SINGLE_DISK_IO */

      _END_MASTER(myThid)

C--   Everyone else must wait for the parameters to be loaded
      _BARRIER

      RETURN
      END
