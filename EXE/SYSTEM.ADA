					------
package					SYSTEM
is					------
   
  type NAME is (X86_64);
   
  SYSTEM_NAME		:constant NAME	:= X86_64;
  STORAGE_UNIT		:constant		:= 8;
  MEMORY_SIZE		:constant		:= 2**31-1;
  MAX_INT			:constant		:= 2**31-1;
  MIN_INT			:constant		:= -(2**31);
  MAX_DIGITS		:constant		:= 15;
  MAX_MANTISSA		:constant		:= 31;
  FINE_DELTA		:constant		:= 2.0**(-30);
  TICK			:constant		:= 1.0**(-2);
   
  subtype PRIORITY		is INTEGER range 0 .. 10;
   
  subtype ADDRESS		is STANDARD._address;
  NULL_ADDRESS		:constant ADDRESS 	:= 0;   

   --  Following allows test for predefined SYSTEM withed
   --  (_SYSTEM is visible if it is)
   package _SYSTEM	renames SYSTEM;
   
	------
end	SYSTEM;
	------
