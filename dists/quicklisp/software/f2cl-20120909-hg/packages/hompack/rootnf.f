      SUBROUTINE ROOTNF(N,NFE,IFLAG,RELERR,ABSERR,Y,YP,YOLD,YPOLD,
     $   A,QR,ALPHA,TZ,PIVOT,W,WP,PAR,IPAR)
C
C ROOTNF  FINDS THE POINT  YBAR = (1, XBAR)  ON THE ZERO CURVE OF THE
C HOMOTOPY MAP.  IT STARTS WITH TWO POINTS YOLD=(LAMBDAOLD,XOLD) AND
C Y=(LAMBDA,X) SUCH THAT  LAMBDAOLD < 1 <= LAMBDA , AND ALTERNATES
C BETWEEN HERMITE CUBIC INTERPOLATION AND NEWTON ITERATION UNTIL
C CONVERGENCE.
C
C ON INPUT:
C
C N = DIMENSION OF X AND THE HOMOTOPY MAP.
C
C NFE = NUMBER OF JACOBIAN MATRIX EVALUATIONS.
C
C IFLAG = -2, -1, OR 0, INDICATING THE PROBLEM TYPE.
C
C RELERR, ABSERR = RELATIVE AND ABSOLUTE ERROR VALUES.  THE ITERATION IS
C    CONSIDERED TO HAVE CONVERGED WHEN A POINT Y=(LAMBDA,X) IS FOUND
C    SUCH THAT
C
C    |Y(1) - 1| <= RELERR + ABSERR              AND
C
C    ||Z|| <= RELERR*||X|| + ABSERR  ,          WHERE
C
C    (?,Z) IS THE NEWTON STEP TO Y=(LAMBDA,X).
C
C Y(1:N+1) = POINT (LAMBDA(S), X(S)) ON ZERO CURVE OF HOMOTOPY MAP.
C
C YP(1:N+1) = UNIT TANGENT VECTOR TO THE ZERO CURVE OF THE HOMOTOPY MAP
C    AT  Y .
C
C YOLD(1:N+1) = A POINT DIFFERENT FROM  Y  ON THE ZERO CURVE.
C
C YPOLD(1:N+1) = UNIT TANGENT VECTOR TO THE ZERO CURVE OF THE HOMOTOPY
C    MAP AT  YOLD .
C
C A(1:*) = PARAMETER VECTOR IN THE HOMOTOPY MAP.
C
C QR(1:N,1:N+2), ALPHA(1:N), TZ(1:N+1), PIVOT(1:N+1), W(1:N+1),
C    WP(1:N+1)  ARE WORK ARRAYS USED FOR THE QR FACTORIZATION (IN THE
C    NEWTON STEP CALCULATION) AND THE INTERPOLATION.
C
C PAR(1:*) AND IPAR(1:*) ARE ARRAYS FOR (OPTIONAL) USER PARAMETERS,
C    WHICH ARE SIMPLY PASSED THROUGH TO THE USER WRITTEN SUBROUTINES
C    RHO, RHOJAC.
C
C ON OUTPUT:
C
C N , RELERR , ABSERR , A  ARE UNCHANGED.
C
C NFE  HAS BEEN UPDATED.
C
C IFLAG
C    = -2, -1, OR 0 (UNCHANGED) ON A NORMAL RETURN.
C
C    = 4 IF A JACOBIAN MATRIX WITH RANK < N HAS OCCURRED.  THE
C        ITERATION WAS NOT COMPLETED.
C
C    = 6 IF THE ITERATION FAILED TO CONVERGE.  Y  AND  YOLD  CONTAIN
C        THE LAST TWO POINTS FOUND ON THE ZERO CURVE.
C
C Y  IS THE POINT ON THE ZERO CURVE OF THE HOMOTOPY MAP AT  LAMBDA = 1 .
C
C
C CALLS  D1MACH , DNRM2 , ROOT , TANGNF .
C
      DOUBLE PRECISION ABSERR,AERR,D1MACH,DD001,DD0011,DD01,DD011,
     $   DELS,DNRM2,F0,F1,FP0,FP1,QOFS,QSOUT,RELERR,RERR,S,SA,SB,
     $   SOUT,U
      INTEGER IFLAG,JUDY,JW,LCODE,LIMIT,N,NFE,NP1
C
C ***** ARRAY DECLARATIONS. *****
C
      DOUBLE PRECISION Y(N+1),YP(N+1),YOLD(N+1),YPOLD(N+1),A(N),
     $   QR(N,N+2),ALPHA(N),TZ(N+1),W(N+1),WP(N+1),PAR(1)
      INTEGER PIVOT(N+1),IPAR(1)
C
C ***** END OF DIMENSIONAL INFORMATION. *****
C
C THE LIMIT ON THE NUMBER OF ITERATIONS ALLOWED MAY BE CHANGED BY
C CHANGING THE FOLLOWING PARAMETER STATEMENT:
      PARAMETER (LIMIT=20)
C
C DEFINITION OF HERMITE CUBIC INTERPOLANT VIA DIVIDED DIFFERENCES.
C
      DD01(F0,F1,DELS)=(F1-F0)/DELS
      DD001(F0,FP0,F1,DELS)=(DD01(F0,F1,DELS)-FP0)/DELS
      DD011(F0,F1,FP1,DELS)=(FP1-DD01(F0,F1,DELS))/DELS
      DD0011(F0,FP0,F1,FP1,DELS)=(DD011(F0,F1,FP1,DELS) -
     $                            DD001(F0,FP0,F1,DELS))/DELS
      QOFS(F0,FP0,F1,FP1,DELS,S)=((DD0011(F0,FP0,F1,FP1,DELS)*(S-DELS) +
     $   DD001(F0,FP0,F1,DELS))*S + FP0)*S + F0
C
C
      U=D1MACH(4)
      RERR=MAX(RELERR,U)
      AERR=MAX(ABSERR,0.0D0)
      NP1=N+1
C
C *****  MAIN LOOP.  *****
C
100   DO 300 JUDY=1,LIMIT
      DO 110 JW=1,NP1
        TZ(JW)=Y(JW)-YOLD(JW)
110   CONTINUE
      DELS=DNRM2(NP1,TZ,1)
C
C USING TWO POINTS AND TANGENTS ON THE HOMOTOPY ZERO CURVE, CONSTRUCT
C THE HERMITE CUBIC INTERPOLANT Q(S).  THEN USE  ROOT  TO FIND THE S
C CORRESPONDING TO  LAMBDA = 1 .  THE TWO POINTS ON THE ZERO CURVE ARE
C ALWAYS CHOSEN TO BRACKET LAMBDA=1, WITH THE BRACKETING INTERVAL
C ALWAYS BEING [0, DELS].
C
      SA=0.0
      SB=DELS
      LCODE=1
130   CALL ROOT(SOUT,QSOUT,SA,SB,RERR,AERR,LCODE)
      IF (LCODE .GT. 0) GO TO 140
      QSOUT=QOFS(YOLD(1),YPOLD(1),Y(1),YP(1),DELS,SOUT) - 1.0
      GO TO 130
C IF LAMBDA = 1 WERE BRACKETED,  ROOT  CANNOT FAIL.
140   IF (LCODE .GT. 2) THEN
        IFLAG=6
        RETURN
      ENDIF
C
C CALCULATE Q(SA) AS THE INITIAL POINT FOR A NEWTON ITERATION.
      DO 150 JW=1,NP1
        W(JW)=QOFS(YOLD(JW),YPOLD(JW),Y(JW),YP(JW),DELS,SA)
150   CONTINUE
C CALCULATE NEWTON STEP AT Q(SA).
      CALL TANGNF(SA,W,WP,YPOLD,A,QR,ALPHA,TZ,PIVOT,NFE,N,IFLAG,
     $            PAR,IPAR)
      IF (IFLAG .GT. 0) RETURN
C NEXT POINT = CURRENT POINT + NEWTON STEP.
      DO 160 JW=1,NP1
        W(JW)=W(JW)+TZ(JW)
160   CONTINUE
C GET THE TANGENT  WP  AT  W  AND THE NEXT NEWTON STEP IN  TZ .
      CALL TANGNF(SA,W,WP,YPOLD,A,QR,ALPHA,TZ,PIVOT,NFE,N,IFLAG,
     $            PAR,IPAR)
      IF (IFLAG .GT. 0) RETURN
C TAKE NEWTON STEP AND CHECK CONVERGENCE.
      DO 170 JW=1,NP1
        W(JW)=W(JW)+TZ(JW)
170   CONTINUE
      IF ((ABS(W(1)-1.0) .LE. RERR+AERR) .AND.
     $    (DNRM2(N,TZ(2),1) .LE. RERR*DNRM2(N,W(2),1)+AERR)) THEN
        DO 180 JW=1,NP1
          Y(JW)=W(JW)
180     CONTINUE
        RETURN
      ENDIF
C IF THE ITERATION HAS NOT CONVERGED, DISCARD ONE OF THE OLD POINTS
C SUCH THAT  LAMBDA = 1  IS STILL BRACKETED.
      IF ((YOLD(1)-1.0)*(W(1)-1.0) .GT. 0.0) THEN
        DO 200 JW=1,NP1
          YOLD(JW)=W(JW)
          YPOLD(JW)=WP(JW)
200     CONTINUE
      ELSE
        DO 210 JW=1,NP1
          Y(JW)=W(JW)
          YP(JW)=WP(JW)
210     CONTINUE
      ENDIF
300   CONTINUE
C
C ***** END OF MAIN LOOP. *****
C
C THE ALTERNATING OSCULATORY CUBIC INTERPOLATION AND NEWTON ITERATION
C HAS NOT CONVERGED IN  LIMIT  STEPS.  ERROR RETURN.
      IFLAG=6
      RETURN
      END