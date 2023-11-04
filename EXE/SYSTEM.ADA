--|-------------------------------------------------------------------------------------------------
--|		PACKAGE SYSTEM
PACKAGE SYSTEM IS
--|-------------------------------------------------------------------------------------------------
   
  TYPE NAME IS (IBM_PC);
   
  SYSTEM_NAME		: CONSTANT NAME	:= IBM_PC;
  STORAGE_UNIT		: CONSTANT	:= 8;
  MEMORY_SIZE		: CONSTANT	:= 2**31-1;
  MAX_INT		: CONSTANT	:= 2**31-1;
  MIN_INT		: CONSTANT	:= -(2**31);
  MAX_DIGITS		: CONSTANT	:= 15;
  MAX_MANTISSA		: CONSTANT	:= 31;
  FINE_DELTA		: CONSTANT	:= 2.0**(-30);
  TICK		: CONSTANT	:= 1.0**(-2);
   
  SUBTYPE PRIORITY		IS INTEGER RANGE 0 .. 10;
   
  SUBTYPE ADDRESS		IS STANDARD._address;
  NULL_ADDRESS		: CONSTANT ADDRESS := 0;   

   --  Following allows test for predefined SYSTEM withed
   --  (_SYSTEM is visible if it is)
   PACKAGE _SYSTEM	RENAMES SYSTEM;
   
--|-------------------------------------------------------------------------------------------------
END SYSTEM;
