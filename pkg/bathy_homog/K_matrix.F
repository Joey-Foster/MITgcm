C23456789012345678901234567890123456789012345678901234567890123456789012

      SUBROUTINE READ_EXPLICIT_K(diffKh, diffKz)
      IMPLICIT NONE

      REAL diffKh, diffKz
      REAL K(2,2)

      COMMON /DIFFUSION_MATRIX/ K

      K(1,1) = diffKh
      K(1,2) = 0.0
      K(2,1) = 0.0
      K(2,2) = diffKz

      END

      SUBROUTINE USE_IMPLICIT_K(dx, dz, u, w, courant_x, courant_z)
      IMPLICIT NONE

      REAL dx, dz, u, w, courant_x, courant_z
      REAL implicit_diffKh, implicit_diffKz
      REAL K(2,2)

      COMMON /DIFFUSION_MATRIX/ K

      implicit_diffKh = 0.5 * ABS(u) * dx
      implicit_diffKz = 0.5 * ABS(w) * dz

      K(1,1) = implicit_diffKh
      K(1,2) = 0.0
      K(2,1) = 0.0
      K(2,2) = implicit_diffKz

      PRINT*, "bathy homog", K(1,1), K(2,1), K(2,2)

      END