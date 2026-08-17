C23456789012345678901234567890123456789012345678901234567890123456789012

      SUBROUTINE gbar11(XI, RESULT)
      IMPLICIT NONE

      REAL XI, RESULT

      REAL g0_11, g012_OVER_Kg22, g021_MUL_Kg21_OVER_Kg22
      EXTERNAL g0_11, g012_OVER_Kg22, g021_MUL_Kg21_OVER_Kg22

      REAL AVG_1, AVG_2, AVG_3

      REAL C11_val

      CALL AVERAGE(g0_11, XI, AVG_1)
      CALL AVERAGE(g012_OVER_Kg22, XI, AVG_2)
      CALL AVERAGE(g021_MUL_Kg21_OVER_Kg22, XI, AVG_3)

      CALL C11(XI, C11_val)

      RESULT = AVG_1 + C11_val*AVG_2 - AVG_3

      END

      SUBROUTINE gbar12(XI, RESULT)
      IMPLICIT NONE

      REAL XI, RESULT
      
      REAL g012_OVER_Kg22
      EXTERNAL g012_OVER_Kg22

      REAL AVG

      REAL C21_val

      CALL AVERAGE(g012_OVER_Kg22, XI, AVG)
      CALL C21(XI, C21_val)

      RESULT = C21_val*AVG

      END

      SUBROUTINE gbar21(XI, RESULT)
      IMPLICIT NONE

      REAL XI, RESULT

      REAL g0_OFFDIAG, g022_OVER_Kg22, g022_MUL_Kg21_OVER_Kg22
      EXTERNAL g0_OFFDIAG, g022_OVER_Kg22, g022_MUL_Kg21_OVER_Kg22

      REAL AVG_1, AVG_2, AVG_3

      REAL C11_val

      CALL AVERAGE(g0_OFFDIAG, XI, AVG_1)
      CALL AVERAGE(g022_OVER_Kg22, XI, AVG_2)
      CALL AVERAGE(g022_MUL_Kg21_OVER_Kg22, XI, AVG_3)

      CALL C11(XI, C11_val)

      RESULT = AVG_1 + C11_val*AVG_2 - AVG_3

      END     

      SUBROUTINE gbar22(XI, RESULT)
      IMPLICIT NONE

      REAL XI, RESULT
      
      REAL g022_OVER_Kg22
      EXTERNAL g022_OVER_Kg22

      REAL AVG

      REAL C21_val

      CALL AVERAGE(g022_OVER_Kg22, XI, AVG)
      CALL C21(XI, C21_val)

      RESULT = C21_val*AVG

      END

      SUBROUTINE STORE_gbar(XI, MATRIX)
      IMPLICIT NONE

      REAL MATRIX(2,2)
      REAL XI

      REAL res11, res12, res21, res22
      
      CALL gbar11(XI, res11)
      CALL gbar12(XI, res12)
      CALL gbar21(XI, res21)
      CALL gbar22(XI, res22)

      MATRIX(1,1) = res11
      MATRIX(1,2) = res12
      MATRIX(2,1) = res21
      MATRIX(2,2) = res22

      END


      SUBROUTINE TEST_GBAR(XI)
      IMPLICIT NONE
       
      REAL XI 
      REAL RESULT(2,2)
      INTEGER i,j

      XI = 0.5
      CALL STORE_gbar(XI, RESULT)
      
      DO i=1,2
       DO j=1,2
       PRINT*, "gbar(",i,",",j,")=", RESULT(i,j)
       ENDDO
      ENDDO

      END
