# Name and section:
# Partner's Name and section:

# This MIPS assembly language program loops to read a
# user-entered integer (entered in decimal).  For each valid
# integer read, the integer is printed back out,
# first in decimal, and then in base 2.
# The program ends when a poorly-formed integer is
# read.

.data
int_prompt: .asciiz "Enter an integer: "
test:       .asciiz "hi"

# Registers:
# $8 - return value from get_integer:








.text
__start:
    sub   $sp, $sp, 8   # 2 word AR, for 2 parameters
while:    

    puts  int_prompt
    jal   get_integer 
    bltz  $v1, end       # end when $v1 return value is less than 0
    move  $8, $v0

    sw    $8, 4($sp)
    li    $9, 10        # set base of integer to 10
    sw    $9, 8($sp)
    jal   print_integer
    putc  '\n'

    sw    $8, 4($sp)
    li    $9, 2         # set base of integer to 2
    sw    $9, 8($sp)
    jal   print_integer
    putc  '\n'

    b     while

end:
    putc  '\n'
    add   $sp, $sp, 8   # pop AR
    done
          
####################

#get_integer: 
# A function that reads in, and returns a user-integer in $v0.
# A badly formed integer leads to a negative return value in $v1.
# A well-formed integer has an optional '-' character followed by
# digits '0'-'9', and is ended with the newline character.

get_integer:
   sub  $sp, $sp, 24         # allocate AR
   sw   $ra, 24($sp)         # save registers in AR
   sw   $8,  4($sp)
   sw   $9,  8($sp)
   sw   $10, 12($sp)
   sw   $11, 16($sp)
   sw   $12, 20($sp)

   li   $10, 0               # $10 is the calcuated integer
   li   $v1, 0               # assume int is good
   li   $12, 0               # $12 is now flag, 1 means negative
                             #  and 0 means not negative
   getc $8                   # $8 holds 1 user-entered character 
   li   $11, '-'             # check if 1st character is '-'
   bne  $8, $11, notneg
   li   $12, 1               # is negative
   getc $8                   
notneg:
   li   $9, 10               # check if 1st character is newline
   beq  $8, $9, not_good_int

gi_while_1:
   li   $9, 10               # check if character is newline
   beq  $8, $9, gi_finish

   li   $9, 48               # $9 is the ASCII character '0'
   blt  $8, $9, not_good_int
   sub  $8, $8, $9           # $8 is now 2's comp rep that is >= 0

   li   $9, 10               # $9 is now the constant 10
   bge  $8, $9, not_good_int
	 
   mul  $10, $10, $9         # int = ( int * 10 ) + digit
   add  $10, $10, $8
         
   getc $8
   b    gi_while_1           # loop to get more digits

not_good_int:  
   li   $v1, -1	             # return value = -1 for bad int
   b    gi_epilogue

gi_finish: 
   beqz $12, gi_epilogue 
   mul  $10, $10, -1
gi_epilogue: 
   move $v0, $10             # set return value in its proper register
   lw   $8,  4($sp)          # restore register values
   lw   $9,  8($sp)
   lw   $10, 12($sp)
   lw   $11, 16($sp)
   lw   $12, 20($sp)
   lw   $ra, 24($sp)
   add  $sp, $sp, 24         # deallocate AR space
   jr   $ra                  # return



##################################
#print_integer:
# 354 students put your own description and code for print_integer here

print_integer:
   sub  $sp, $sp, 36         #allocate AR
   sw   $ra, 36($sp)         # save registers in AR
   sw   $8,  4($sp)
   sw   $9,  8($sp)
   sw   $10, 12($sp)
   sw   $11, 16($sp)
   sw   $12, 20($sp)
   sw   $13, 24($sp)
   sw   $14, 28($sp)
   sw   $15, 32($sp)

   lw   $8,  40($sp)         #load parameters
   lw   $9,  44($sp)

   add  $14, $9, 0
   and  $10, $10, 0
   bgtz $8, single_digit_check

   sub  $8, $10, $8
   li   $10, '-'
   putc $10

single_digit_check:
   li  $10, 10
   blt $8, $10, less_than_ten
   li $10, 0

find_base:
   add $10, $8, 0
   add $11, $8, 0
   and $12, $12, 0

find_base2:
   div  $11, $11, $9
   add  $12, $12, 1
   bgtz $11, find_base2

   sub $12, $12, 2

find_base3:
   beqz $12, print_digits
   mul $9, $9, $14
   sub $12, $12, 1

   b find_base3

print_digits:
   beqz $9, print_epilogue
   div $13, $10, $9
   add $13, $13, 48
   putc $13
   rem $10, $10, $9
   div $9, $9, $14
   b print_digits

less_than_ten:
   add $8, $8, 48
   putc $8

print_epilogue:
   li  $v0, 0
   lw   $8,  4($sp)          # restore register values
   lw   $9,  8($sp)
   lw   $10, 12($sp)
   lw   $11, 16($sp)
   lw   $12, 20($sp)
   lw   $13, 24($sp)
   lw   $14, 28($sp)
   lw   $15, 32($sp)
   lw   $ra, 36($sp)
   add  $sp, $sp, 36         # deallocate AR space
   jr   $ra                  # return

