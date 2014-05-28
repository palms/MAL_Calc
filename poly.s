# Saul Laufer - Lecture 2
# This program asks for the degree and coefficients of a polynomial
# and prints a formatted version of the coefficients entered.


   .data
        degreeMessage:    .asciiz "Enter degree: "
	badInputMessage:    .asciiz "\nBad input.  Qutting."
        coefficientPrompt:   .asciiz "\nEnter coefficient: "
        coefficientEntered1:   .asciiz "x^"
        coefficientEntered2:   .asciiz " coefficient is "

# register assignments
#   $8 -- the degree of the polynomial (char value then integer)
#   $9 -- the lower bound of ascii values
#   $10 -- the upper bounds of ascii values (52 then 57)
#   $11 -- number of coefficients
#   $12 -- input char to input integer
#   $13 -- integer value 10 (also keeps base)
#   $14 -- coefficient integer value
#   $15 -- keeps track of base
#   $16 -- for printing coefficient
#   $17 -- char value of $11
#   $18 -- determine if coefficient is negative
#   $19 -- value of dash ascii character '-'
#   $20 -- integer value 0
#   $25 -- output messages



   .text
__start:
        #gets the degree of polynomial, translates ascii value to integer
        la $25, degreeMessage
        puts $25
        getc $8
	li $9, 48
        li $10, 52
        blt $8, $9, bad_input                #test if degree > 0
        bgt $8, $10, bad_input               #test if degree < 4 
        sub $8, $8, 48                       #translation from ascii value to integer
        add $11, $8, 0
        li $10, 57                           #change upper bound of allowed ascii values to 9
        and $19, $19, 0
        add $19, $19, 45                     #ascii value of '-' for negative values
        and $20, $20, 0

while_more_coefficients:
        #clears coefficient value, base value and negative determinant registers
        #prompts for coefficient
        li $13, 10
        la $25, coefficientPrompt
        puts $25
        and $14, $14, 0
        and $15, $15, 0
        and $18, $18, 0

while_more_digits:
        getc $12
        beq $12, $9, leading_zeroes          #branch if input is zero

return_from_zero_check:
        beq $12, $19, negative_number        #branch if input is negative
        beq $13, $12, end_while_more_digits  #end loop if null character detected

        #display and quit if input not integer
        blt $12, $9, bad_input
        bgt $12, $10, bad_input
        sub $12, $12, 48                     #translates from ascii value to integer

        #multiplies current coefficient value by 10 and adds new coefficient digit
        #to determine integer values of large coefficients
        mul $14, $14, 10
        add $14, $14, $12
        add $15, $15, 1                      #updates number of digits in coefficient
        b while_more_digits

end_while_more_digits:
        sub $15, $15, 2                      #for calculation of base
        la $25, coefficientEntered1
        puts $25
        add $17, $11, 48                     #translate degree from integer to ascii value
        putc $17
        la $25, coefficientEntered2
        puts $25
        bgtz $18, print_negative_symbol      #branch if coefficient negative

print_coefficient:
        bgt $14, $13, find_base              #branch if coefficient is greater than single-digit
        add $16, $14, 48                     #translate integer to ascii value
        putc $16

end_while_more_coefficients:
        bgtz $18, negate_number              #branch if coefficient is negative

end_negate:
        sub $11, $11, 1                      #decrement counter for coefficients left to be entered
        bgez $11, while_more_coefficients    #branch if more coefficients to be entered

end:
        done                                 #program exit point

bad_input:
        #if bad input detected, prints bad input message, quits program
	la $25, badInputMessage
	puts $25
        b end

leading_zeroes:
       #if character is a leading zero, dismisses, otherwise counts as part of coefficient
        beq $15, $20, while_more_digits
        b return_from_zero_check

negative_number:
        add $18, $18, 1                      #sets the negative coefficient 'flag'
        b while_more_digits

print_negative_symbol:
       #prints the '-' character
        putc $19
        b print_coefficient

negate_number:
       #makes integer value into its negative equivalent
       #for later implementation using value, not for printing
       sub $14, $20, $14
       b end_negate

find_base:
        #determines the base of a coefficient
        beqz $15, translate                  #branches upon completion of calculation
        mul $13, $13, 10                     #advances base by one degree
        sub $15, $15, 1                      #decrements base counter
        b find_base

translate:
        #translates integer value to individual ascii characters for printing
        #by dividing value by base, printing character, then modding the value by
        #the base and decrementing the base

        #ends loop when base is zero (completion of process)
        beqz $13, end_while_more_coefficients
        div $16, $14, $13                    #value of digit
        add $16, $16, 48                     #translates integer to ascii value
        putc $16
        rem $14, $14, $13                    #remainder division to get other digits
        div $13, $13, 10                     #decrementing base by one power
        b translate

