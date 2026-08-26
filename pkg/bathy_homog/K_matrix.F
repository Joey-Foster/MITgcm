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

      END

      SUBROUTINE USE_IMPLICIT_K(dx, dz, u, w, courant_x, courant_z)
      IMPLICIT NONE
#include "EEPARAMS.h"

      _RL dx, dz, u, w, courant_x, courant_z
      _RL implicit_diffKh, implicit_diffKz
      _RL K(2,2)

      COMMON /DIFFUSION_MATRIX/ K

C     use upwind numerical diffusion for now (very overdamped)
      implicit_diffKh = 0.5 * ABS(u) * dx * (1 - courant_x)
      implicit_diffKz = 0.5 * ABS(w) * dz * (1 - courant_z)

      K(1,1) = implicit_diffKh
      K(1,2) = 0.0
      K(2,1) = 0.0
      K(2,2) = implicit_diffKz

      PRINT*, "bathy homog Korig=", K(1,1), K(2,1), K(2,2)

      END