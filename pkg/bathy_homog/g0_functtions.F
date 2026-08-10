C23456789012345678901234567890123456789012345678901234567890123456789012

C hardcoded to assume a=b=1 for now

      REAL FUNCTION OFFDIAG(ETA, XI)
      IMPLICIT NONE
      REAL PI
      REAL ETA, XI

      PI = 3.14159265358979323846
      OFFDIAG = 2.0 * PI * (XI - 1.0) * COS(2.0*PI*ETA)

      RETURN 
      END

      REAL FUNCTION g0_11(ETA, XI)
      IMPLICIT NONE

      REAL ETA, XI
      REAL OFFDIAG

      g0_11 = OFFDIAG(ETA, XI)**2 + 1.0

      RETURN
      END

      REAL FUNCTION g0_22(ETA, XI)
      IMPLICIT NONE
C     g_0^22 is a constant but made depedent on eta,xi 
C     for consistency with averaging subroutines 

      REAL ETA, XI

      g0_22 = 1.0

      RETURN
      END