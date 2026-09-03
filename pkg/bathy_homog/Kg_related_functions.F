C23456789012345678901234567890123456789012345678901234567890123456789012
#include "CPP_OPTIONS.h"

      SUBROUTINE CONTRACT(A, B, AB)
      IMPLICIT NONE
#include "EEPARAMS.h"
      
      _RL A(2, 2), B(2,2)
      _RL AB(2, 2)

      _RL TMP_SUM
      INTEGER i, j, k

      DO i=1,2
       DO j=1,2
        TMP_SUM = 0.0
        DO k=1,2
        TMP_SUM = TMP_SUM + A(i,k) * B(k, j)
        ENDDO
        AB(i,j) = TMP_SUM
       ENDDO
      ENDDO

      END

      SUBROUTINE CONTRACT_Kg(ETA, XI, a, RESULT)
      IMPLICIT NONE
#include "EEPARAMS.h"

      _RL ETA, XI, a
      _RL RESULT(2, 2)
      _RL K(2, 2), g0(2,2)

      COMMON /DIFFUSION_MATRIX/ K
      CALL STORE_g0(ETA, XI, a, g0)

      CALL CONTRACT(K, g0, RESULT)

      END

C     Store "1/Kg"- and "Kg/Kg"-type constructions 
      FUNCTION recip_Kg22(ETA, XI, a)
      IMPLICIT NONE
#include "EEPARAMS.h"
      
      _RL ETA, XI, a
      _RL Kg(2,2)
      _RL recip_Kg22

      CALL CONTRACT_Kg(ETA, XI, a, Kg)

      recip_Kg22 = 1 / Kg(2,2)

      RETURN 
      END

      FUNCTION Kg21_OVER_Kg22(ETA, XI, a)
      IMPLICIT NONE
#include "EEPARAMS.h"      

      _RL ETA, XI, a
      _RL Kg(2,2)
      _RL Kg21_OVER_Kg22

      CALL CONTRACT_Kg(ETA, XI, a, Kg)

      Kg21_OVER_Kg22 = Kg(2,1) / Kg(2,2)

      RETURN 
      END


C     Construct helper "constants" c^2_1 and c^1_1
      SUBROUTINE C21(XI, a, RESULT)
      IMPLICIT NONE
#include "EEPARAMS.h"

      _RL XI, a
      _RL RESULT
      _RL recip_Kg22
      EXTERNAL recip_Kg22

      CALL AVERAGE(recip_Kg22, XI, a, RESULT)

      RESULT = 1.0 / RESULT
      
      END

      SUBROUTINE C11(XI, a, RESULT)
      IMPLICIT NONE
#include "EEPARAMS.h"

      _RL XI, a
      _RL RESULT
      _RL C21_val
      _RL Kg21_OVER_Kg22
      EXTERNAL Kg21_OVER_Kg22

      CALL AVERAGE(Kg21_OVER_Kg22, XI, a, RESULT)
      CALL C21(XI, a, C21_val)

      RESULT = C21_val * RESULT
      
      END

C     Construct averaging integrands for gbar
C     (these would be lambda functions in python)
C23456789012345678901234567890123456789012345678901234567890123456789012

      FUNCTION g012_OVER_Kg22(ETA, XI, a)
      IMPLICIT NONE
#include "EEPARAMS.h"
      
      _RL ETA, XI, a
      _RL recip_Kg22, g0_OFFDIAG, g012_OVER_Kg22
      
      g012_OVER_Kg22 = g0_OFFDIAG(ETA, XI) * recip_Kg22(ETA, XI, a)

      RETURN 
      END     

      FUNCTION g021_MUL_Kg21_OVER_Kg22(ETA, XI, a)
      IMPLICIT NONE
#include "EEPARAMS.h"
      
      _RL ETA, XI, a
      _RL Kg21_OVER_Kg22, g0_OFFDIAG, g021_MUL_Kg21_OVER_Kg22
      
      g021_MUL_Kg21_OVER_Kg22 = g0_OFFDIAG(ETA, XI) 
     &                        * Kg21_OVER_Kg22(ETA, XI, a)

      RETURN 
      END    

      FUNCTION g022_OVER_Kg22(ETA, XI, a)
      IMPLICIT NONE
#include "EEPARAMS.h"
      
      _RL ETA, XI, a
      _RL recip_Kg22, g0_22, g022_OVER_Kg22
      
      g022_OVER_Kg22 = g0_22(a) * recip_Kg22(ETA, XI, a)

      RETURN 
      END   

      FUNCTION g022_MUL_Kg21_OVER_Kg22(ETA, XI, a)
      IMPLICIT NONE
#include "EEPARAMS.h"
      
      _RL ETA, XI, a
      _RL Kg21_OVER_Kg22, g0_22, g022_MUL_Kg21_OVER_Kg22
      
      g022_MUL_Kg21_OVER_Kg22 = g0_22(a) 
     &                        * Kg21_OVER_Kg22(ETA, XI, a)

      RETURN 
      END  