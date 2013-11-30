C---------------------------------------------------
      DOUBLE PRECISION FUNCTION ALNORM(X,UPPER)
      DOUBLE PRECISION X
      LOGICAL UPPER
C
C   ALGORITHM AS 66 BY I.D. HILL
C
      LOGICAL UP
      DOUBLE PRECISION Y, Z

      DOUBLE PRECISION CON, HALF, LTONE, ONE, UTZERO, ZERO
      PARAMETER (CON=1.28D0, HALF=0.5D0, LTONE=5.D0, ONE=1.D0,
     1           UTZERO=12.5D0, ZERO=0.D0)

      UP=UPPER
      Z=X
      IF(Z.GE.ZERO) GO TO 10
      UP=.NOT.UP
      Z=-Z
 10   IF(Z .LE. LTONE .OR. UP .AND. Z .LE. UTZERO) GO TO 20
      ALNORM = ZERO
      GO TO 40
 20   Y=HALF*Z*Z
      IF(Z.GT.CON) GO TO 30
      ALNORM = HALF - Z * (0.398942280444D0 - 0.399903438504D0*Y/
     1             (Y + 5.75885480458D0 - 29.8213557808D0/
     2             (Y + 2.62433121679D0 + 48.6959930692D0/
     3             (Y + 5.92885724438D0))))
      GO TO 40
 30   ALNORM = 0.398942280385D0 * EXP(-Y)/
     1             (Z - 3.8052D-8 + 1.00000615302D0/
     2             (Z + 3.98064794D-4 + 1.98615381364D0/
     3             (Z - 0.151679116635D0 + 5.29330324926D0/
     4             (Z + 4.8385912808D0 - 15.1508972451D0/
     5             (Z + 0.742380924027D0 + 30.789933034D0/
     6             (Z + 3.99019417011D0))))))
 40   IF(.NOT.UP) ALNORM = ONE - ALNORM
      END
