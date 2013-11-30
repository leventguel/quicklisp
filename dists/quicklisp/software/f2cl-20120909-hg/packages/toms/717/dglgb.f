      SUBROUTINE DGLGB(N, P, PS, X, B, RHO, RHOI, RHOR, IV, LIV, LV,
     1                V, CALCRJ, UI, UR, UF)
C
C *** GENERALIZED LINEAR REGRESSION A LA NL2SOL, PLUS SIMPLE BOUNDS ***
C
C  ***  PARAMETERS  ***
C
      INTEGER N, P, PS, LIV, LV
      INTEGER IV(LIV), RHOI(*), UI(*)
      DOUBLE PRECISION B(2,P), X(P), RHOR(*), V(LV), UR(*)
      EXTERNAL CALCRJ, RHO, UF
C
C  ***  PARAMETER USAGE  ***
C
C N....... TOTAL NUMBER OF RESIDUALS.
C P....... NUMBER OF PARAMETERS (COMPONENTS OF X) BEING ESTIMATED.
C PS...... NUMBER OF NON-NUISANCE PARAMETERS (THOSE INVOLVED IN S).
C X....... PARAMETER VECTOR BEING ESTIMATED (INPUT = INITIAL GUESS,
C             OUTPUT = BEST VALUE FOUND).
C B....... BOUNDS TO ENFORCE... B(1,I) .LE. X(I) .LE. B(2,I).
C RHO..... SUBROUTINE FOR COMPUTING LOSS FUNCTIONS AND THEIR DERIVS.
C             SEE  DRGLG FOR DETAILS ABOUT RHO.
C RHOI.... PASSED WITHOUT CHANGE TO RHO.
C RHOR.... PASSED WITHOUT CHANGE TO RHO.
C IV...... INTEGER VALUES ARRAY.
C LIV..... LENGTH OF IV (SEE DISCUSSION BELOW).
C LV...... LENGTH OF V (SEE DISCUSSION BELOW).
C V....... FLOATING-POINT VALUES ARRAY.
C CALCRJ.. SUBROUTINE FOR COMPUTING RESIDUAL VECTOR AND JACOBIAN MATRIX.
C UI...... PASSED UNCHANGED TO CALCRJ.
C UR...... PASSED UNCHANGED TO CALCRJ.
C UF...... PASSED UNCHANGED TO CALCRJ.
C
C *** CALCRJ CALLING SEQUENCE...
C
C      CALL CALCRJ(N, P, X, NF, NEED, R, RP, UI, UR, UF)
C
C PARAMETERS N, P, X, UI, UR, AND UF ARE AS ABOVE.
C R AND RP ARE FLOATING-POINT ARRAYS DIMENSIONED R(N) AND RP(P,N).
C NEED IS AN INTEGER ARRAY OF LENGTH 2...
C   NEED(1) = 1 MEANS CALCRJ SHOULD COMPUTE THE RESIDUAL VECTOR R,
C             AND NEED(2) IS THE VALUE NF HAD AT THE LAST X WHERE
C             CALCRJ MIGHT BE CALLED WITH NEED(1) = 2.
C   NEED(1) = 2 MEANS CALCRJ SHOULD COMPUTE THE JACOBIAN MATRIX RP,
C             WHERE RP(J,I) = DERIVATIVE OF R(I) WITH RESPECT TO X(J).
C (CALCRJ SHOULD NOT CHANGE NEED AND SHOULD CHANGE AT MOST ONE OF R
C AND RP.  IF R OR RP, AS APPROPRIATE, CANNOT BE COMPUTED, THEN CALCRJ
C SHOULD SET NF TO 0.  OTHERWISE IT SHOULD NOT CHANGE NF.)
C
C  ***  GENERAL  ***
C
C     CODED BY DAVID M. GAY.
C
C+++++++++++++++++++++++++++  DECLARATIONS  +++++++++++++++++++++++++++
C
C  ***  EXTERNAL SUBROUTINES  ***
C
      EXTERNAL DIVSET,  DRGLGB
C
C DIVSET.... PROVIDES DEFAULT IV AND V INPUT COMPONENTS.
C DRGLGB... CARRIES OUT OPTIMIZATION ITERATIONS.
C
C
C  ***  LOCAL VARIABLES  ***
C
      INTEGER D1, DR1, I, IV1, NEED1(2), NEED2(2), NF, R1, RD1
C
C  ***  IV COMPONENTS  ***
C
      INTEGER D, J, NEXTV, NFCALL, NFGCAL, R, REGD, REGD0, TOOBIG, VNEED
      PARAMETER (D=27, J=70, NEXTV=47, NFCALL=6, NFGCAL=7, R=61,
     1           REGD=67, REGD0=82, TOOBIG=2, VNEED=4)
      SAVE NEED1, NEED2
      DATA NEED1(1)/1/, NEED1(2)/0/, NEED2(1)/2/, NEED2(2)/0/
C
C---------------------------------  BODY  ------------------------------
C
      IF (IV(1) .EQ. 0) CALL DIVSET(1, IV, LIV, LV, V)
      IV1 = IV(1)
      IF (IV1 .EQ. 14) GO TO 10
      IF (IV1 .GT. 2 .AND. IV1 .LT. 12) GO TO 10
      IF (IV1 .EQ. 12) IV(1) = 13
      I = (P-PS+2)*(P-PS+1)/2
      IF (IV(1) .EQ. 13) IV(VNEED) = IV(VNEED) + P + N*(P+1+I)
      CALL DRGLGB(B, X, V, IV, LIV, LV, N, PS, N, P, PS, V, V,
     1            RHO, RHOI,RHOR, V, X)
      IF (IV(1) .NE. 14) GO TO 999
C
C  ***  STORAGE ALLOCATION  ***
C
      IV(D) = IV(NEXTV)
      IV(R) = IV(D) + P
      IV(REGD0) = IV(R) + (P - PS + 1)*N
      IV(J) = IV(REGD0) + ((P-PS+2)*(P-PS+1)/2)*N
      IV(NEXTV) = IV(J) + N*PS
      IF (IV1 .EQ. 13) GO TO 999
C
 10   D1 = IV(D)
      DR1 = IV(J)
      R1 = IV(R)
      RD1 = IV(REGD0)
C
 20   CALL DRGLGB(B, V(D1), V(DR1), IV, LIV, LV, N, PS, N, P, PS,
     1            V(R1), V(RD1), RHO, RHOI, RHOR, V, X)
      IF (IV(1)-2) 30, 50, 60
C
C  ***  NEW FUNCTION VALUE (R VALUE) NEEDED  ***
C
 30   NF = IV(NFCALL)
      NEED1(2) = IV(NFGCAL)
      CALL CALCRJ(N, PS, X, NF, NEED1, V(R1), V(DR1), UI, UR, UF)
      IF (NF .GT. 0) GO TO 40
         IV(TOOBIG) = 1
         GO TO 20
 40   IF (IV(1) .GT. 0) GO TO 20
C
C  ***  COMPUTE DR = GRADIENT OF R COMPONENTS  ***
C
 50   CALL CALCRJ(N, PS, X, IV(NFGCAL), NEED2, V(R1), V(DR1), UI, UR,UF)
      IF (IV(NFGCAL) .EQ. 0) IV(TOOBIG) = 1
      GO TO 20
C
C  ***  INDICATE WHETHER THE REGRESSION DIAGNOSTIC ARRAY WAS COMPUTED
C  ***  AND PRINT IT IF SO REQUESTED...
C
 60   IF (IV(REGD) .GT. 0) IV(REGD) = RD1
C
 999  RETURN
C
C  ***  LAST LINE OF DGLGB FOLLOWS  ***
      END