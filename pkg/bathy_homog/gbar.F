C23456789012345678901234567890123456789012345678901234567890123456789012
      
      SUBROUTINE STORE_g0(ETA, XI, MATRIX)
      IMPLICIT NONE

      REAL MATRIX(2,2)
      REAL ETA, XI

      REAL g0_11, g0_22, OFFDIAG

      MATRIX(1,1) = g0_11(ETA, XI)
      MATRIX(1,2) = OFFDIAG(ETA, XI)
      MATRIX(2,1) = OFFDIAG(ETA, XI)
      MATRIX(2,2) = g0_22(ETA, XI)

      END

      SUBROUTINE CONTRACT_KG(ETA, XI, g0, RESULT)
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

      SUBROUTINE GBARTEST(ETA, XI)
       
      REAL ETA, XI
      REAL K(2,2), g0(2,2)
      REAL RESULT(2,2)
      INTEGER i,j

      CALL CONTRACT_KG(ETA, XI, g0, RESULT)
      
      PRINT*, "K@g0 = "
      DO i=1,2
       DO j=1,2
       PRINT*, RESULT(i,j)
       ENDDO
      ENDDO

      END
