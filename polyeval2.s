# Saul Laufer - Lecture 2
# This program asks for the degree and coefficients of a polynomial
# stores them in an array and prints out a formatted version of the polynomial.


   .data
        welcomeMessage:        .asciiz "Polynomial program:\n"
        degreeMessage:         .asciiz "Enter degree: "
	badInputMessage:       .asciiz "\nBad input.  Qutting."
        coefficientPrompt:     .asciiz "Enter coefficient for x^"
        coefficientPrompt2:    .asciiz ":"
        xDisplay:              .asciiz "x^"
        polyMessage:           .asciiz "Polynomial entered:\n"
        addDisplay:            .asciiz " + "

        coeffs: .word 0:5


# register assignments
#   $8 -- the degree of the polynomial (char value then integer)
#   $9 -- the lower bound of ascii values
#   $10 -- the upper bounds of ascii values (52 then 57)
#   $11 -- number of coefficients (also counter using this value)
#   $12 -- input char to input integer
#   $13 -- integer value 10 (also keeps base)
#   $14 -- leading zero counter for degree / coefficient integer value
#   $15 -- calculating base of degree and coeffs
#   $16 -- for printing coefficient
#   $17 -- char value of $11
#   $18 -- determine if coefficient is negative
#   $19 -- value of dash ascii character '-'
#   $20 -- integer value 0
#   $21 -- copy of coefficient to find base
#   $22 -- offset for array
#   $23 -- address for array input
#   $24 -- copy of integer coefficient
#   $25 -- output messages and array address



   .text
__start:
        #gets the degree of polynomial, translates ascii value to integer
        li $13, 10
        and $15, $15, 0
        and $14, $15, 0
        and $20, $20, 0
        li $9, 48                      #loads lower bound of acceptable value
        li $10, 52                     #loads upper bound of acceptable value
        la $25, welcomeMessage
        puts $25
        la $25, degreeMessage
        puts $25


enter_degree:
        getc $8
        beq $8, $13, end_degree        #if user inputs newline character
        bgtz $15, bad_input            #if more than single digit detected
        beq $8, $9, leading_zeroes_degree   #accounts for leading zeroes


return_from_zero_degree:
        blt $8, $9, bad_input            #test if degree > 0
        bgt $8, $10, bad_input           #test if degree < 4
        sub $8, $8, 48                   #translation to integer
        add $11, $8, 0
        add $14, $14, 1                  #updates counter for leading zeroes
        add $15, $15, 1                  #updates digit counter
        b enter_degree


end_degree:
        add $8, $11, 0                   #reverts $8 to degree
        li $10, 57                       #new upper bound of acceptable values
        and $19, $19, 0
        add $19, $19, 45                 #ascii value of '-' for negative vals.
        and $15, $15, 0


while_more_coefficients:
        #clears coefficient value base value and negative determinant registers
        #prompts for coefficient
        la $25, coefficientPrompt
        puts $25
        add $17, $11, 48                #translate degree to ascii value
        putc $17
        la $25, coefficientPrompt2
        puts $25
        and $14, $14, 0
        and $18, $18, 0
        and $15, $15, 0


while_more_digits:
        getc $12
        beq $12, $9, leading_zeroes_coeff      #branch if input is zero


return_from_zero_check:
        beq $12, $19, negative_number    #branch if input is negative

        #end loop if null character detected
        beq $13, $12, end_while_more_digits

        #display and quit if input not integer
        blt $12, $9, bad_input
        bgt $12, $10, bad_input
        sub $12, $12, 48                 #translate from ascii value to integer

        #multiplies current coefficient value by 10 and adds new coefficient
        #digit to determine integer values of large coefficients
        mul $14, $14, 10
        add $14, $14, $12
        add $15, $15, 1
        b while_more_digits


end_while_more_digits:
        add $24, $14, 0                  #stores integer value prior to use
        bgtz $18, negate_number          #branch if negative coefficient


end_negate:
        #places coefficient in corresponding array address (reverse order)
        la $25, coeffs
        mul $22, $11, 4
        add $23, $25, $22
        sw $24, ($23)
        sub $11, $11, 1                  #remaining coeff. counter decremented
        bgez $11, while_more_coefficients   #while coeffs. remaining

        la $25, polyMessage
        puts $25
        add $11, $8, 0                   #reverts $11 back to degree


outputting_coeffs:
        and $13, $13, 0
        add $13, $13, 10
        and $15, $15, 0
        
        #calculates address of coefficients in array and places them in $14
        la $25, coeffs
        mul $22, $11, 4
        add $23, $25, $22
        lw $14, ($23)
        bltz $14, print_negative_symbol  #branch to print '-' if coeff. negative

end_negative:
        bltz $14, make_positive          #branch if coeff. negative


print_coefficient:
        add $24, $14, 0                  #copy of coefficient
        bgt $14, $13, find_base          #branch if coefficient is > 9
        add $24, $24, 48
        putc $24


end_translate:
        #formatted output
        la $25, xDisplay
        puts $25
        add $8, $11, 48
        putc $8
        
        sub $11, $11, 1                  #decrement coefficient counter
        #branch if more coefficients printed
        bgez $11, print_space


end:
        done                             #program exit point


bad_input:
        #if bad input detected, prints bad input message, quits program
	la $25, badInputMessage
	puts $25
        b end


leading_zeroes_coeff:
       #if character is a leading zero, dismisses, otherwise include in coeff.
        beq $15, $20, while_more_digits
        b return_from_zero_check


negative_number:
        add $18, $18, 1                  #sets the negative coefficient 'flag'
        b while_more_digits


print_negative_symbol:
       #prints the '-' character
        putc $19
        b end_negative


negate_number:
       #makes integer value into its negative equivalent
       #for later implementation using value, not for printing
       sub $24, $20, $24
       b end_negate


find_base:
        #determines the base of a coefficient
        add $21, $14, 0

find_base2:
        div $21, $21, 10
        add $15, $15, 1                 #updates base counter
        bgtz $21, find_base2
        sub $15, $15, 2

find_base3:
        beqz $15, translate              #branches on completion of calculation
        mul $13, $13, 10                 #advances base by one degree
        sub $15, $15, 1                  #decrements base counter
        b find_base3


translate:
        #translates integer value to individual ascii characters for printing
        #by dividing value by base, printing character, then modding the value
        #by the base and decrementing the base

        #ends loop when base is zero (completion of process)
        beqz $13, end_translate
        div $16, $14, $13                #value of digit
        add $16, $16, 48                 #translates integer to ascii value
        putc $16
        rem $14, $14, $13                #rem. division to get other digits
        div $13, $13, 10                 #decrementing base by one power
        b translate


make_positive:
        #translates negative coefficient into positive with same absolute value
        sub $14, $20, $14
        b print_coefficient


print_space:
        #outputs two space characters and '+' in between if more output remains
        la $25, addDisplay
        puts $25
        b outputting_coeffs


leading_zeroes_degree:
        #checks if degree input is a leading zero, if not, sends to bad_input
        beq $14, $20, enter_degree
        b bad_input

