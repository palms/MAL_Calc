# Name and section: 

# This program reads in a single character representing a polynomial's
# degree.  It then reads in coefficients for the polynomial, placing
# each into an array.  The polynomial is printed out, and an integer
# is prompted for.  With a valid integer, the polynomial is evaluated
# at that value, and the result is printed out.

.data
ARRAY_SIZE:     .word   5
array:          .word   0:5        # array for coefficients
str_prompt1:    .asciiz "Polynomial program:\nEnter degree:  "
str_prompt2:    .asciiz "Enter coefficient for x^"
str_prompt3:    .asciiz ":"
str_prompt4:    .asciiz "Enter x:  "
msg_out1:       .asciiz "Polynomial entered:\n"
msg_out2:       .asciiz "x^"
msg_out3:       .asciiz " + "
msg_out4:       .asciiz "f("
msg_out5:       .asciiz ") = "
str_badinput:   .asciiz "\nBad input.  Quitting.\n"	
newline:        .asciiz "\n"	

 .text
__start:        
   sub  $sp, $sp, 12             # 3 parameters (max) passed from main()
                                 #   so allocate stack space for them
   puts str_prompt1

   jal  get_integer              # get degree
   # check validity of degree
   bltz $v1, bad_input
   li   $8, 4                    # maximum degree allowed
   move $9, $v0
   bgt  $9, $8, bad_input
   bltz $9, bad_input

   sw   $9, 4($sp)              # P1 is degree of polynomial
   la   $10, array              # P2 is base addr of array to hold coeffs
   sw   $10, 8($sp) 
   jal  read_coefficients
   bltz $v0, bad_input          # return value is -1 for bad input

   sw   $9, 4($sp)              # same parameters to print_polynomial
   sw   $10, 8($sp) 
   jal  print_polynomial

   # prompt for and get x value
   puts str_prompt4
   jal  get_integer             # get x value; check that it was a valid int
   bltz $v1, bad_input
   move $8,  $v0                # $8 is now the x value
   sw   $v0, 4($sp)             # P1 is x value
   sw   $9,  8($sp)             # P2 is degree of polynomial
   sw   $10, 12($sp)            # P3 is base addr of array holding coeffs
   jal  evaluate
   move $9, $v0                 # $9 is polynomial's value at x

   # print result
   puts msg_out4
   sw   $8, 4($sp)              # P1 is x
   li   $10, 10                 # P2 is radix to print in ($10 is radix=10)
   sw   $10, 8($sp)               
   jal  print_integer
   puts msg_out5
   sw   $9, 4($sp)              # P1 is evaluated value at x
   sw   $10, 8($sp)             # P2 is radix to print (10)
   jal  print_integer
   puts newline
   b    end_program

bad_input:  
   puts str_badinput
   b    end_program

end_program:    
   add  $sp, $sp, 12
   done


####################
#read_coefficients
# 354 students put your own description and code for read_coefficients here

read_coefficients:
   sub  $sp, $sp, 24         # allocate AR
   sw   $ra, 24($sp)         # save registers in AR
   sw   $8,  4($sp)
   sw   $9,  8($sp)
   sw   $10, 12($sp)
   sw   $11, 16($sp)
   sw   $12, 20($sp)

   lw   $8,  28($sp)         #degree
   lw   $9,  32($sp)         #base address of array
   li   $10, 0

get_coeffs:
   
   bltz $8, valid_read

   la   $10, str_prompt2
   puts $10
   add  $10, $8, 48
   putc $10
   la   $10, str_prompt3
   puts $10

   li   $10, 0
   jal get_integer
   bnez $v1, bad_read
   move $12, $v0

   mul $10, $8, 4
   add $11, $9, $10
   sw  $12, ($11)

   sub $8, $8, 1
   b   get_coeffs

bad_read:
   li $v0, -1
   b rc_epilogue

valid_read:
   li $v0, 0

rc_epilogue:
   lw   $8,  4($sp)          # restore register values
   lw   $9,  8($sp)
   lw   $10, 12($sp)
   lw   $11, 16($sp)
   lw   $12, 20($sp)
   lw   $ra, 24($sp)
   add  $sp, $sp, 24         # deallocate AR space
   jr   $ra                  # return

####################
#evaluate
# 354 students put your own description and code for evaluate() here

evaluate:
   sub  $sp, $sp, 40         # allocate AR
   sw   $ra, 40($sp)         # save registers in AR
   sw   $8,  4($sp)
   sw   $9,  8($sp)
   sw   $10, 12($sp)
   sw   $11, 16($sp)
   sw   $12, 20($sp)
   sw   $13, 24($sp)
   sw   $14, 28($sp)
   sw   $15, 32($sp)
   sw   $16, 36($sp)

   lw   $8,  44($sp)         # x value
   lw   $9,  48($sp)         # degree
   lw   $10, 52($sp)         # base address of array

   li   $v0, 0
   li   $15, 0
   add   $16, $8, 0

evaluation:
   add  $11, $9, 0
   add $8, $16, 0

   mul  $13, $9, 4
   add  $14, $10, $13
   lw   $12, ($14)

   beqz $9, last_coeff

   li   $13, 1

power:
   ble  $11, $13, sum
   mul  $8, $8, $8
   sub  $11, $11, 1
   b power

sum:
   mul $12, $12, $8
   add $15, $15, $12
   sub $9, $9, 1
   b evaluation

last_coeff:
   add $15, $15, $12

eval_epilogue:
   move $v0, $15
   lw   $8,  4($sp)          # restore register values
   lw   $9,  8($sp)
   lw   $10, 12($sp)
   lw   $11, 16($sp)
   lw   $12, 20($sp)
   lw   $13, 24($sp)
   lw   $14, 28($sp)
   lw   $15, 32($sp)
   lw   $16, 36($sp)
   lw   $ra, 40($sp)
   add  $sp, $sp, 40         # deallocate AR space
   jr   $ra                  # return

##################################
#print_polynomial:
# 354 students put your own description and code for print_polynomial here

print_polynomial:
   sub  $sp, $sp, 32         # allocate AR (2 params)
   sw   $ra, 32($sp)         # save registers in AR
   sw   $8,  12($sp)
   sw   $9,  16($sp)
   sw   $10, 20($sp)
   sw   $11, 24($sp)
   sw   $12, 28($sp)

   lw   $8,  36($sp)         #degree
   lw   $9,  40($sp)         #base address of array

   la   $10, msg_out1
   puts $10

print_coeffs:
   mul  $10, $8, 4
   add  $11, $9, $10
   lw   $12, ($11)

   li   $11, 10
   sw   $12, 4($sp)
   sw   $11, 8($sp)
  
   jal  print_integer

   la   $10, msg_out2
   puts $10
   add  $10, $8, 48
   putc $10

   beqz $8, pp_epilogue

   sub $8, $8, 1
   la   $10, msg_out3
   puts $10
   b print_coeffs

pp_epilogue:
   la $10, newline
   puts $10
   li $v0, 0
   lw   $8,  12($sp)          # restore register values
   lw   $9,  16($sp)
   lw   $10, 20($sp)
   lw   $11, 24($sp)
   lw   $12, 28($sp)
   lw   $ra, 32($sp)
   add  $sp, $sp, 32         # deallocate AR space
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


