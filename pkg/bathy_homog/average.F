C23456789012345678901234567890123456789012345678901234567890123456789012

      SUBROUTINE AVERAGE(MY_FUNC, xi, value_storage)
      IMPLICIT NONE

      REAL h
      DOUBLE PRECISION MY_FUNC, value_storage, xi
      INTEGER N, i
      DOUBLE PRECISION ETA(0:1000)

      N = 1000 /* < hardcoded for now ^ */
      h = 1.0D0/DBLE(N)

      DO i=0,N
       ETA(i) = i * h
      ENDDO

      value_storage = MY_FUNC(ETA(0), xi) + MY_FUNC(ETA(N), xi)
      DO i=1,N-1
       IF ( MOD(i, 2) .EQ. 0 ) THEN
        value_storage = value_storage + 2 * MY_FUNC(ETA(i), xi)
       ELSE
        value_storage = value_storage + 4 * MY_FUNC(ETA(i), xi)
       ENDIF
      ENDDO

      value_storage = value_storage * h/3.0

      END