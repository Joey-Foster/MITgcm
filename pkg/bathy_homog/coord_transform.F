C23456789012345678901234567890123456789012345678901234567890123456789012
#include "CPP_OPTIONS.h"

      SUBROUTINE COMPUTE_TrigAlpha(delX, delZ, hFacC, hFacW, TRIGs)
      IMPLICIT NONE
C     this computes trig(alpha) PER GRID CELL
#include "EEPARAMS.h"

      _RL delX, delZ
      _RS hFacC, hFacW
      _RL TRIGs(2)

      _RL sinAlpha, cosAlpha, tanAlpha 

      tanAlpha = delZ/delX * (hFacC - hFacW) 
      sinAlpha = tanAlpha / SQRT( 1.0 + tanAlpha**2)
      cosAlpha = 1.0 / SQRT( 1.0 + tanAlpha**2)

      TRIGs(1) = sinAlpha
      TRIGs(2) = cosAlpha

      END

      SUBROUTINE FLAT2ROT_coords(X, Z, x_np1, z_np1, 
     &                           delX, delZ, hFacC, hFacW)
      IMPLICIT NONE
C     take a specific (X,Z) pair and move them to their corresponding
C     position with respect to the rotation of the cell alpha is
C     calculated for. Rotation is about (x_np1, z_np1) for that cell.
#include "EEPARAMS.h"

      _RS X, Z, x_np1, z_np1
      _RL delX, delZ
      _RS hFacC, hFacW
      _RL TRIGs(2)

      CALL COMPUTE_TrigAlpha(delX, delZ, hFacC, hFacW, TRIGs)

      X = (X - x_np1)*TRIGs(2) + (Z - z_np1)*TRIGs(1) 
     &                         + x_np1
      Z = (x_np1 - X)*TRIGs(1) + (Z - z_np1)*TRIGs(2)
     &                         + z_np1 + delZ*(1-hFacC)

      END

      SUBROUTINE MAP2XI_coords(X, Z, delX, delZ, hFacC, hFacW)
      IMPLICIT NONE
C     convert rotated (X,Z) -> (x_1, x_2) rescaled -> (xi_1, xi_2)
C     **maybe unecessary? Currently not called in any case...**
#include "EEPARAMS.h"

      _RS X, Z
      _RL delX, delZ
      _RS hFacC, hFacW
      _RL a /* my notation */

      _RL x1, x2 
      _RL xi1, xi2 

C     swap horiz and vert in accordance with my original notation
      x1 = Z 
      x2 = -X 

C     rescale x2 by 1/delX to ensure "b=1" (my notation), and do it
C     to both coords to preserve the aspect ratio of the cell
      x1 = 1/delX * x1
      x2 = 1/delX * x2

C     map to xi coords (to leading order)
      a = delZ/delX
      xi1 = x1 / a 
      xi2 = x2      /* b=1 */

C     store back in (X,Z)
      X = xi1 
      Z = xi2

      END

      SUBROUTINE velTrans_unitsquare(x_n, x_np1, z_np1,
     I                               delX, delZ, 
     I                               recip_hFacC, recip_hFacW,
     U                               uTrans_i, uTrans_ip1, wTrans_i)
      IMPLICIT NONE
C     takes in corners of rotated cell
C     defines velocities from transports
C     computes transports on the unit square with respect to rotated coords
C     modifies transport velocites INPLACE!
#include "EEPARAMS.h"

      _RS x_n, x_np1, z_np1
      _RL delX, delZ
      _RS recip_hFacC, recip_hFacW
      _RL uTrans_i, uTrans_ip1, wTrans_i

      _RL uL, uR, uT 

      PRINT*, "orig uTrans_i, uTrans_ip1, wTrans_i", 
     &              uTrans_i, uTrans_ip1, wTrans_i

      PRINT*, "recip_hFacW, delZ", recip_hFacW, delZ

      uL = (uTrans_i / delZ) * recip_hFacW
      uR = (uTrans_ip1 / delZ) * recip_hFacC
      uT = wTrans_i / delX

      PRINT*, "uL, uR, uT", uL, uR, uT

      uTrans_i = -uL * ((x_np1 + delX) / delX) 
     &           + uR * ((x_n + delX) / delX)
      uTrans_ip1 = -uL * x_np1 / delX + uR * x_n / delX

      wTrans_i = uT * ((delZ - z_np1) / delZ)

      PRINT*, "new uTrans_i, uTrans_ip1, wTrans_i", 
     &             uTrans_i, uTrans_ip1, wTrans_i

      END