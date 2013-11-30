C  ***  SIMPLE TEST PROGRAM FOR DGLG AND DGLF  ***
C
      program madsen
      INTEGER IV(92), LIV, LV, NOUT, UI(1)
      DOUBLE PRECISION V(200), X(2), UR(1)
      EXTERNAL I7MDCN, MADRJ, RHOLS
      INTEGER I7MDCN
C
C I7MDCN... RETURNS OUTPUT UNIT NUMBER.
C
      INTEGER COVPRT, COVREQ, LASTIV, LASTV, LMAX0, RDREQ
      PARAMETER (COVPRT=14, COVREQ=15, LASTIV=44, LASTV=45, LMAX0=35,
     1           RDREQ=57)
C
C+++++++++++++++++++++++++++++++  BODY  ++++++++++++++++++++++++++++++++
C
      NOUT = I7MDCN(1)
      LV = 200
      LIV = 92
C
C  ***  SPECIFY INITIAL X  ***
C
      X(1) = 3.D+0
      X(2) = 1.D+0
C
C  ***  SET IV(1) TO 0 TO FORCE ALL DEFAULT INPUT COMPONENTS TO BE USED.
C
       IV(1) = 0
C
       WRITE(NOUT,10)
 10    FORMAT(' DGLG ON PROBLEM MADSEN...')
C
C  ***  CALL DGLG, PASSING UI FOR RHOI, UR FOR RHOR, AND MADRJ FOR
C  ***  UFPARM (ALL UNUSED IN THIS EXAMPLE).
C
      CALL DGLG(3, 2, 2, X, RHOLS, UI, UR, IV, LIV, LV, V, MADRJ, UI,
     1          UR, MADRJ)
C
C  ***  SEE HOW MUCH STORAGE DGLG USED...
C
      WRITE(NOUT,20) IV(LASTIV), IV(LASTV)
 20   FORMAT(' DGLG NEEDED LIV .GE. ',I3,' AND LV .GE.',I4)
C
C  ***  SOLVE THE SAME PROBLEM USING DGLF...
C
      WRITE(NOUT,30)
 30   FORMAT(/' DGLF ON PROBLEM MADSEN...')
      X(1) = 3.D+0
      X(2) = 1.D+0
      IV(1) = 0
      CALL DGLF(3, 2, 2, X, RHOLS, UI, UR, IV, LIV, LV, V, MADRJ, UI,
     1          UR, MADRJ)
C
C  ***  REPEAT THE LAST RUN, BUT WITH A DIFFERENT INITIAL STEP BOUND
C  ***  AND WITH THE COVARIANCE AND REGRESSION DIAGNOSTIC CALCUATIONS
C  ***  SUPPRESSED...
C
C  ***  FIRST CALL DIVSET TO GET DEFAULT IV AND V INPUT VALUES...
C
      CALL DIVSET(1, IV, LIV, LV, V)
C
C  ***  NOW ASSIGN THE NONDEFAULT VALUES.
C
      IV(COVPRT) = 0
      IV(COVREQ) = 0
      IV(RDREQ) = 0
      V(LMAX0) = 0.1D+0
      X(1) = 3.D+0
      X(2) = 1.D+0
C
      WRITE(NOUT,40)
 40   FORMAT(/' DGLF ON PROBLEM MADSEN AGAIN...')
C
      CALL DGLF(3, 2, 2, X, RHOLS, UI, UR, IV, LIV, LV, V, MADRJ, UI,
     1          UR, MADRJ)
C
c      STOP
      END