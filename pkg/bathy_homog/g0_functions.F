C23456789012345678901234567890123456789012345678901234567890123456789012
#include "CPP_OPTIONS.h"
C hardcoded to assume a=b=1 for now

      FUNCTION g0_OFFDIAG(ETA, XI)
      IMPLICIT NONE
#include "EEPARAMS.h"

      _RL PI
      _RL ETA, XI
      _RL g0_OFFDIAG

      PI = 3.14159265358979323846
      g0_OFFDIAG = 2.0 * PI * (XI - 1.0) * COS(2.0*PI*ETA)

      RETURN 
      END

      FUNCTION g0_11(ETA, XI)
      IMPLICIT NONE
#include "EEPARAMS.h" 

      _RL ETA, XI
      _RL g0_OFFDIAG, g0_11

      g0_11 = g0_OFFDIAG(ETA, XI)**2 + 1.0

      RETURN
      END

      FUNCTION g0_22()
      IMPLICIT NONE
#include "EEPARAMS.h" 

      _RL g0_22

      g0_22 = 1.0

      RETURN
      END

            
      SUBROUTINE STORE_g0(ETA, XI, MATRIX)
      IMPLICIT NONE
#include "EEPARAMS.h"

      _RL MATRIX(2,2)
      _RL ETA, XI

      _RL g0_11, g0_22, g0_OFFDIAG

      MATRIX(1,1) = g0_11(ETA, XI)
      MATRIX(1,2) = g0_OFFDIAG(ETA, XI)
      MATRIX(2,1) = g0_OFFDIAG(ETA, XI)
      MATRIX(2,2) = g0_22()

      END