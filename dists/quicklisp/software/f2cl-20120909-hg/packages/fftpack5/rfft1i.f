CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C   FFTPACK 5.0 
C
C   Authors:  Paul N. Swarztrauber and Richard A. Valent
C
C   $Id$
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

      SUBROUTINE RFFT1I ( N, WSAVE, LENSAV, IER )
      INTEGER    N, LENSAV, IER
      REAL       WSAVE(LENSAV)
C
      IER = 0
C
      IF (LENSAV .LT. N + INT(LOG(REAL(N))) +4) THEN
        IER = 2
        CALL XERFFT ('RFFT1I ', 3)
      ENDIF
C
      IF (N .EQ. 1) RETURN
C
      CALL RFFTI1 (N,WSAVE(1),WSAVE(N+1))
      RETURN
      END
