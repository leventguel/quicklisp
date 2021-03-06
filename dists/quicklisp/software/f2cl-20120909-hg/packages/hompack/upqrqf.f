        SUBROUTINE UPQRQF(N,ETA,S,F0,F1,QT,R,W,T)
C
C SUBROUTINE  UPQRQF  PERFORMS A BROYDEN UPDATE ON THE  Q R
C FACTORIZATION OF A MATRIX  A, (AN APPROXIMATION TO J(X0)),
C RESULTING IN THE FACTORIZATION  Q+ R+ OF
C
C       A+  =  A  +  (Y - A*S) (ST)/(ST * S),
C
C (AN APPROXIMATION TO J(X1))
C WHERE S = X1 - X0, ST = S TRANSPOSE,  Y = F(X1) - F(X0).
C
C THE ENTRY POINT  R1UPQF  PERFORMS THE RANK ONE UPDATE ON THE QR
C FACTORIZATION OF
C
C       A+ =  A + Q*(T*ST).
C
C
C ON INPUT:
C
C N  IS THE DIMENSION OF X AND F(X).
C
C ETA  IS A NOISE PARAMETER.  IF (Y-A*S)(I) .LE. ETA*(|F1(I)|+|F0(I)|)
C    FOR 1 .LE. I .LE. N, THEN NO UPDATE IS PERFORMED.
C
C S(1:N) = X1 - X0   (OR S FOR THE ENTRY POINT R1UPQF).
C
C F0(1:N) = F(X0).
C
C F1(1:N) = F(X1).
C
C QT(1:N,1:N)  CONTAINS THE OLD Q TRANSPOSE, WHERE  A = Q*R .
C
C R(1:N*(N+1)/2)  CONTAINS THE OLD R, STORED BY ROWS.
C
C W(1:N), T(1:N)  ARE WORK ARRAYS ( T  CONTAINS THE VECTOR T FOR THE
C    ENTRY POINT  R1UPQF ).
C
C
C ON OUTPUT:
C
C N  AND  ETA  ARE UNCHANGED.
C
C QT  CONTAINS Q+ TRANSPOSE.
C
C R   CONTAINS R+, STORED BY ROWS.
C
C S, F0, F1, W, AND T  HAVE ALL BEEN CHANGED.
C
C
C CALLS  DAXPY, DDOT, AND DNRM2.
C
C ***** DECLARATIONS *****
C
C     FUNCTION DECLARATIONS
C
        DOUBLE PRECISION DDOT, DNRM2
C
C     LOCAL VARIABLES
C
        DOUBLE PRECISION C, DEN, ONE, SS, WW, YY
        INTEGER I, INDEXR, INDXR2, J, K
        LOGICAL SKIPUP
C
C     SCALAR ARGUMENTS
C
        DOUBLE PRECISION ETA
        INTEGER N
C
C     ARRAY DECLARATIONS
C
        DOUBLE PRECISION  S(N), F0(N), F1(N), QT(N,N), R(N*(N+1)/2),
     $    W(N), T(N), TT(2)
C
C ***** END OF DECLARATIONS *****
C
C ***** FIRST EXECUTABLE STATEMENT *****
C
        ONE = 1.0
        SKIPUP = .TRUE.
C
C ***** DEFINE T AND S SUCH THAT *****
C
C           A+ = Q*(R + T*ST).
C
C T = R*S.
C
        INDEXR = 1
        DO 10 I=1,N
          T(I) = DDOT(N-I+1,R(INDEXR),1,S(I),1)
          INDEXR = INDEXR + N - I + 1
  10    CONTINUE
C
C W = Y - Q*T  = Y - A*S.
C
        DO 20 I=1,N
          W(I) = F1(I) - F0(I) - DDOT(N,QT(1,I),1,T,1)
C
C         IF W(I) IS NOT SMALL, THEN UPDATE MUST BE PERFORMED,
C         OTHERWISE SET W(I) TO 0.
C
          IF (ABS(W(I)) .GT. ETA*(ABS(F1(I)) + ABS(F0(I)))) THEN
            SKIPUP = .FALSE.
          ELSE
            W(I) = 0.0
          END IF
  20    CONTINUE
C
C  IF NO UPDATE IS NECESSARY, THEN RETURN.
C
        IF (SKIPUP) RETURN
C
C T = QT*W = QT*Y - R*S.
C
        DO 30 I=1,N
          T(I) = DDOT(N,QT(I,1),N,W,1)
  30    CONTINUE
C
C S = S/(ST*S).
C
        DEN = 1.0/DDOT(N,S,1,S,1)
        CALL DSCAL(N,DEN,S,1)
C
C ***** END OF COMPUTATION OF  T & S      *****
C       AT THIS POINT,  A+ = Q*(R + T*ST).
C
        CALL r1upqf(n, s, t, qt, r, w)
        RETURN
        END
