C23456789012345678901234567890123456789012345678901234567890123456789012
#include "CPP_OPTIONS.h"

      SUBROUTINE AVERAGE(MY_FUNC, xi, a, value_storage)
      IMPLICIT NONE
#include "EEPARAMS.h"

      _RL MY_FUNC, xi, a, value_storage
      EXTERNAL MY_FUNC

C     This is now a redudant function as the core logical of AVERAGE()
C     has been moved to TRAPEZOID and/or SIMPSON.

C     The existence of this subroutine body as well as the entirety
C     of GENERIC_SIMPSON() is for legacy purposes 

      CALL FULL_PERIOD_TRAPEZOID(MY_FUNC, xi, a, value_storage)

      END

      SUBROUTINE GENERIC_SIMPSON(MY_FUNC, xi, a, 
     &                           interval, value_storage)
      IMPLICIT NONE
#include "EEPARAMS.h"

      _RL MY_FUNC, xi, a, value_storage
      _RL interval(2)
      _RL h

      INTEGER N, i
      _RL                  ETA(0:100)
      N = 100 /* < hardcoded for now ^ */
      h = (interval(2) - interval(1)) / N

      DO i=0,N
       ETA(i) = i * h + interval(1)
      ENDDO

      value_storage = MY_FUNC(ETA(0), xi, a) + MY_FUNC(ETA(N), xi, a)
      DO i=1,N-1
       IF ( MOD(i, 2) .EQ. 0 ) THEN
        value_storage = value_storage + 2 * MY_FUNC(ETA(i), xi, a)
       ELSE
        value_storage = value_storage + 4 * MY_FUNC(ETA(i), xi, a)
       ENDIF
      ENDDO

      value_storage = value_storage * h/3.0

      END

      SUBROUTINE FULL_PERIOD_TRAPEZOID(MY_FUNC, xi, a, value_storage)
      IMPLICIT NONE
#include "EEPARAMS.h"

      _RL MY_FUNC, xi, a, value_storage
      _RL h
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