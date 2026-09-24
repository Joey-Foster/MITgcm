C23456789012345678901234567890123456789012345678901234567890123456789012
#include "CPP_OPTIONS.h"

      SUBROUTINE AVERAGE(MY_FUNC, xi, a, value_storage)
      IMPLICIT NONE
#include "EEPARAMS.h"

      _RL h
      _RL MY_FUNC, value_storage, xi, a
      INTEGER N, i
      _RL                     ETA(0:25)

      N = 25 /* < hardcoded for now ^ */
      h = 1.0D0 / N

      DO i=0,N
       ETA(i) = i * h
      ENDDO

C     trapezium rule has exponential accuracy for periodic functions over a full period
      value_storage = MY_FUNC(ETA(0), xi, a) + MY_FUNC(ETA(N), xi, a)
      DO i=1,N-1
       value_storage = value_storage + 2.0*MY_FUNC(ETA(i), xi, a)
      ENDDO

      value_storage = value_storage * h/2.0

      END
