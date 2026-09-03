C23456789012345678901234567890123456789012345678901234567890123456789012
#include "CPP_OPTIONS.h"

      FUNCTION g0_OFFDIAG(ETA, XI, a)
      IMPLICIT NONE
#include "EEPARAMS.h"

      _RL PI
      _RL ETA, XI
      _RL g0_OFFDIAG

C     this doesn't depend on 'a' but AVERAGE() expects
C     three args and idk how to do kwargs in fortran
C     so this is just defined but unused
      _RL a 

      PI = 3.14159265358979323846
      g0_OFFDIAG = 2.0 * PI * (XI - 1.0) * COS(2.0*PI*ETA)

      RETURN 
      END

      FUNCTION g0_11(ETA, XI, a)
      IMPLICIT NONE
#include "EEPARAMS.h" 

      _RL ETA, XI
      _RL g0_OFFDIAG, g0_11
      _RL a

      g0_11 = (g0_OFFDIAG(ETA, XI, a)**2 + 1.0) / a

      RETURN
      END

      FUNCTION g0_22(a)
      IMPLICIT NONE
#include "EEPARAMS.h" 

      _RL a
      _RL g0_22

      g0_22 = a

      RETURN
      END

            
      SUBROUTINE STORE_g0(ETA, XI, a, MATRIX)
      IMPLICIT NONE
#include "EEPARAMS.h"

      _RL MATRIX(2,2)
      _RL ETA, XI
      _RL a

      _RL g0_11, g0_22, g0_OFFDIAG

      MATRIX(1,1) = g0_11(ETA, XI, a)
      MATRIX(1,2) = g0_OFFDIAG(ETA, XI, a)
      MATRIX(2,1) = g0_OFFDIAG(ETA, XI, a)
      MATRIX(2,2) = g0_22(a)

      END