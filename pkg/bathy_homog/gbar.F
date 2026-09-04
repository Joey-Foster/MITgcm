C23456789012345678901234567890123456789012345678901234567890123456789012
#include "CPP_OPTIONS.h"

      SUBROUTINE gbar11(XI, a, RESULT)
      IMPLICIT NONE
#include "EEPARAMS.h"

      _RL XI, a, RESULT

      _RL g0_11, g012_OVER_Kg22, g021_MUL_Kg21_OVER_Kg22
      EXTERNAL g0_11, g012_OVER_Kg22, g021_MUL_Kg21_OVER_Kg22

      _RL AVG_1, AVG_2, AVG_3

      _RL C11_val

      CALL AVERAGE(g0_11, XI, a, AVG_1)
      CALL AVERAGE(g012_OVER_Kg22, XI, a, AVG_2)
      CALL AVERAGE(g021_MUL_Kg21_OVER_Kg22, XI, a, AVG_3)

      CALL C11(XI, a, C11_val)

      RESULT = AVG_1 + C11_val*AVG_2 - AVG_3

      END

      SUBROUTINE gbar12(XI, a, RESULT)
      IMPLICIT NONE
#include "EEPARAMS.h"

      _RL XI, a, RESULT
      
      _RL g012_OVER_Kg22
      EXTERNAL g012_OVER_Kg22

      _RL AVG

      _RL C21_val

      CALL AVERAGE(g012_OVER_Kg22, XI, a, AVG)
      CALL C21(XI, a, C21_val)

      RESULT = C21_val*AVG

      END

      SUBROUTINE gbar21(XI, a, RESULT)
      IMPLICIT NONE
#include "EEPARAMS.h"

      _RL XI, a, RESULT

      _RL g0_OFFDIAG, g022_OVER_Kg22, g022_MUL_Kg21_OVER_Kg22
      EXTERNAL g0_OFFDIAG, g022_OVER_Kg22, g022_MUL_Kg21_OVER_Kg22

      _RL AVG_1, AVG_2, AVG_3

      _RL C11_val

      CALL AVERAGE(g0_OFFDIAG, XI, a, AVG_1)
      CALL AVERAGE(g022_OVER_Kg22, XI, a, AVG_2)
      CALL AVERAGE(g022_MUL_Kg21_OVER_Kg22, XI, a, AVG_3)

      CALL C11(XI, a, C11_val)

      RESULT = AVG_1 + C11_val*AVG_2 - AVG_3

      END     

      SUBROUTINE gbar22(XI, a, RESULT)
      IMPLICIT NONE
#include "EEPARAMS.h"

      _RL XI, a, RESULT
      
      _RL g022_OVER_Kg22
      EXTERNAL g022_OVER_Kg22

      _RL AVG

      _RL C21_val

      CALL AVERAGE(g022_OVER_Kg22, XI, a, AVG)
      CALL C21(XI, a, C21_val)

      RESULT = C21_val*AVG

      END

      SUBROUTINE STORE_gbar(XI, a, MATRIX)
      IMPLICIT NONE
#include "EEPARAMS.h"

      _RL MATRIX(2,2)
      _RL XI
      _RL a

      _RL res11, res12, res21, res22
      
      CALL gbar11(XI, a, res11)
      CALL gbar12(XI, a, res12)
      CALL gbar21(XI, a, res21)
      CALL gbar22(XI, a, res22)

      MATRIX(1,1) = res11
      MATRIX(1,2) = res12
      MATRIX(2,1) = res21
      MATRIX(2,2) = res22

      END

      SUBROUTINE CONTRACT_Kgbar(XI, RESULT, a)
      IMPLICIT NONE
#include "EEPARAMS.h"

      _RL XI
      _RL RESULT(2, 2)
      _RL K(2, 2), gbar(2,2)
      _RL a

      LOGICAL IS_POSDEF
      _RL Kg0(2,2)
      INTEGER i 

      COMMON /DIFFUSION_MATRIX/ K

C     #####################################
C     Need to test posdefness for Kg0
C     *before* calling STORE_gbar() so
C     small bit of code duplication here...

      DO i=0,1000
C                 all ETA values used by AVERAGE()
C                            \/    
       CALL CONTRACT_Kg(i*1.0/1000, XI, a, Kg0)

       CALL CHECK_POSDEF(Kg0, IS_POSDEF)
       IF ( .NOT.IS_POSDEF ) THEN
        PRINT*, "Kg0 not pos def!"
        EXIT 
       ENDIF

      ENDDO

      IF ( .NOT.IS_POSDEF ) THEN
       RESULT(1,1) = K(1,1)
       RESULT(1,2) = K(1,2)
       RESULT(2,1) = K(2,1)
       RESULT(2,2) = K(2,2)

C     #####################################     
      ELSE

            CALL STORE_gbar(XI, a, gbar)

            CALL CONTRACT(K, gbar, RESULT)
            
      ENDIF
      
      PRINT*, "bathy homog Kgbar=", 
     &        RESULT(1,1), RESULT(2,1), RESULT(2,2)

      END
