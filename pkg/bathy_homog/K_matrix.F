C23456789012345678901234567890123456789012345678901234567890123456789012
#include "CPP_OPTIONS.h"

      SUBROUTINE USE_EXPLICIT_K(diffKh, diffKz)
      IMPLICIT NONE
#include "EEPARAMS.h"

      _RL diffKh, diffKz
      _RL K(2,2)

      COMMON /DIFFUSION_MATRIX/ K

      K(1,1) = diffKh
      K(1,2) = 0.0
      K(2,1) = 0.0
      K(2,2) = diffKz

      PRINT*, "bathy homog Kread=", K(1,1), K(2,1), K(2,2)

      END

      SUBROUTINE USE_IMPLICIT_K(dx, dz, dt, u, w)
      IMPLICIT NONE
#include "EEPARAMS.h"

      _RL dx, dz, dt, u, w
      _RL implicit_diffKh, implicit_diffKz
      _RL K(2,2)

      COMMON /DIFFUSION_MATRIX/ K

C     use upwind numerical diffusion for now (very overdamped)
      implicit_diffKh = 0.5 * ABS(u) * dx * (1 - ABS(u)*dt/dx)
      implicit_diffKz = 0.5 * ABS(w) * dz * (1 - ABS(w)*dt/dz)

      PRINT*, "bathydebug_x", u, dx, ABS(u)*dt/dx
      PRINT*, "bathydebug_z", w, dz, ABS(w)*dt/dz      

C     Also, this is just hardcoding c=u*dt/dx and not using 
C     the in-built MON_CALC_ADVCFL_GLOB() which uses the flux
C     instead (c=u_flux*dt/V) as this would require setting 
C     monitorFreq = deltaT in data.&PARM03 namelist which 
C     would print a lot of output for long runs. 

      K(1,1) = implicit_diffKh
      K(1,2) = 0.0
      K(2,1) = 0.0
      K(2,2) = implicit_diffKz

      PRINT*, "bathy homog Korig=", K(1,1), K(2,1), K(2,2)

      END


      SUBROUTINE CHECK_POSDEF(MATRIX,  FLAG)
      IMPLICIT NONE
#include "EEPARAMS.h"

      _RL MATRIX(2,2)
      LOGICAL FLAG

      _RL SYM(2,2)
      _RL a, b, c, d
      INTEGER i, j

C     For a matrix M, it's quadratic form definiteness
C     is controlled by the symmetrized version, S = 1/2 (M+M^T)

C     Then by Sylvester's criterion, S is PosDef iff 
C     a > 0 and ad-bc > 0.

      DO i=1,2
       DO j=1,2
        SYM(i,j) = 0.5 * ( MATRIX(i,j) + MATRIX(j,i) )
       ENDDO
      ENDDO

      a = SYM(1,1)
      b = SYM(1,2)
      C = SYM(2,1)
      d = SYM(2,2)

      IF ( a .GT. 0.0D0 .AND. a*d - b*c .GT. 0.0D0 ) THEN 
       FLAG = .TRUE.
      ELSE
       FLAG = .FALSE. 
      ENDIF
      
      RETURN
      END

      