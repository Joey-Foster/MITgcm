C23456789012345678901234567890123456789012345678901234567890123456789012
#include "CPP_OPTIONS.h"

      SUBROUTINE AVERAGE(MY_FUNC, xi, a, value_storage)
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"   /* contains PI */

      _RL MY_FUNC, xi, a, value_storage
      EXTERNAL MY_FUNC
      
      _RL positive_part,negative_part
      _RL interval(2)

      _RL K(2,2)

      COMMON /DIFFUSION_MATRIX/ K

      IF ( K(2,1) .NE. 0.0D0 ) THEN

       interval(1) = 0.0D0
C      solve K(2,1)*(-pi cos(2pi eta)) + K(2,2) = 0
       interval(2) = ACOS( K(2,2) / (K(2,1)*PI)) / (2.0*PI)

       PRINT*, "interval(2)=",interval(2)

       CALL GENERIC_SIMPSON(MY_FUNC, xi, a,
     &                      interval, positive_part)

       interval(1) = interval(2)
       interval(2) = 1.0D0 - interval(2)

       CALL GENERIC_SIMPSON(MY_FUNC, xi, a,
     &                      interval, negative_part)

       value_storage = 2*positive_part + negative_part

      ELSE

       CALL FULL_PERIOD_TRAPEZOID(MY_FUNC, xi, a, value_storage)

      ENDIF

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