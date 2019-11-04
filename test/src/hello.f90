PROGRAM hello
CHARACTER(255) :: who = 'World'
IF (COMMAND_ARGUMENT_COUNT() > 0) THEN
  CALL GET_COMMAND_ARGUMENT(1, who)
END IF
WRITE(*, '(a,1x,a,a)') 'Hello', TRIM(who), '!'
END PROGRAM hello
