C23456789012345678901234567890123456789012345678901234567890123456789012

      SUBROUTINE CONTRACT_Kg(ETA, XI, RESULT)
      IMPLICIT NONE

      REAL ETA, XI
      REAL RESULT(2, 2)
      REAL K(2, 2), g0(2,2)
      REAL TMP_SUM

      INTEGER i, j, kIdx

      COMMON /DIFFUSION_MATRIX/ K

      CALL STORE_g0(ETA, XI, g0)

      DO i=1,2
       DO j=1,2
        TMP_SUM = 0.0
        DO kIdx=1,2
        TMP_SUM = TMP_SUM + K(i,kIdx) * g0(kIdx, j)
        ENDDO
        RESULT(i,j) = TMP_SUM
       ENDDO
      ENDDO

      END

C     Store "1/Kg"- and "Kg/Kg"-type constructions 
      REAL FUNCTION recip_Kg22(ETA, XI)
      IMPLICIT NONE
      
      REAL ETA, XI
      REAL Kg(2,2)

      CALL CONTRACT_Kg(ETA, XI, KG)

      recip_Kg22 = 1 / Kg(2,2)

      RETURN 
      END

      REAL FUNCTION Kg21_OVER_Kg22(ETA, XI)
      IMPLICIT NONE
      
      REAL ETA, XI
      REAL Kg(2,2)

      CALL CONTRACT_Kg(ETA, XI, KG)

      Kg21_OVER_Kg22 = Kg(2,1) / Kg(2,2)

      RETURN 
      END


C     Construct helper "constants" c^2_1 and c^1_1
      SUBROUTINE C21(XI, RESULT)
      IMPLICIT NONE

      REAL XI
      REAL RESULT
      REAL recip_Kg22
      EXTERNAL recip_Kg22

      CALL AVERAGE(recip_Kg22, XI, RESULT)

      RESULT = 1.0 / RESULT
      
      END

      SUBROUTINE C11(XI, RESULT)
      IMPLICIT NONE

      REAL XI
      REAL RESULT
      REAL C21_val
      REAL Kg21_OVER_Kg22
      EXTERNAL Kg21_OVER_Kg22

      CALL AVERAGE(Kg21_OVER_Kg22, XI, RESULT)
      CALL C21(XI, C21_val)

      RESULT = C21_val * RESULT
      
      END

C     Construct averaging integrands for gbar
C     (these would be lambda functions in python)
C23456789012345678901234567890123456789012345678901234567890123456789012

      REAL FUNCTION g012_OVER_Kg22(ETA, XI)
      IMPLICIT NONE
      
      REAL ETA, XI
      REAL g0_OFFDIAG
      REAL recip_Kg22
      
      g012_OVER_Kg22 = g0_OFFDIAG(ETA, XI) * recip_Kg22(ETA, XI)

      RETURN 
      END     

      REAL FUNCTION g021_MUL_Kg21_OVER_Kg22(ETA, XI)
      IMPLICIT NONE
      
      REAL ETA, XI
      REAL g0_OFFDIAG
      REAL Kg21_OVER_Kg22
      
      g021_MUL_Kg21_OVER_Kg22 = g0_OFFDIAG(ETA, XI) 
     &                        * Kg21_OVER_Kg22(ETA, XI)

      RETURN 
      END    

      REAL FUNCTION g022_OVER_Kg22(ETA, XI)
      IMPLICIT NONE
      
      REAL ETA, XI
      REAL g0_22
      REAL recip_Kg22
      
      g022_OVER_Kg22 = g0_22() * recip_Kg22(ETA, XI)

      RETURN 
      END   

      REAL FUNCTION g022_MUL_Kg21_OVER_Kg22(ETA, XI)
      IMPLICIT NONE
      
      REAL ETA, XI
      REAL g0_22
      REAL Kg21_OVER_Kg22
      
      g022_MUL_Kg21_OVER_Kg22 = g0_22() 
     &                        * Kg21_OVER_Kg22(ETA, XI)

      RETURN 
      END  