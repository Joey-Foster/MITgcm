C23456789012345678901234567890123456789012345678901234567890123456789012

      BLOCK DATA INITIALISE_DIFFUSION_MATRIX
      
      REAL K(2,2)

      COMMON /DIFFUSION_MATRIX/ K

C     fortran is column first!
      DATA K /1.0, 1.0, 0.0, 7.0/

      END
      
      SUBROUTINE READ_diffK(KappaRT)
      IMPLICIT NONE

      REAL KappaRT

      PRINT*, "bathy_homog. reading kappa:", KappaRT

      END