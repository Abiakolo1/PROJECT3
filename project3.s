.data
userStr:    .space 2000
tooLongErrorMsg:    .asciiz "Input is too long." # use this if the length of the string starting from the first letter to the next letter is longer than the input of 4 digits
wrongCharErrorMsg:    .asciiz "Invalid base-36 number."#we use this for numbers that have spaces inbetween them and numbers and for numbers that have invalid characters such as the @ symbol in them
EmptyErrorMsg: .asciiz "Input is empty." #we use this for numbers where the input is only filled with spaces and if there is a null character, therefore I will need to check if it is a null string
.text
.globl main
main:
    li $v0, 8       #takes user input
    la $a0, userStr
    syscall
    la $s5, userStr #the address of the string
    li $t5, 0       #initialized i= 0
    li $t1, 32      #space here
    li $s0, 0       #initialized previous character to 0
    li $s7, 0       #initialized numofchracters
    li $t6, 0x0A    #new line here
    li $s6, 0       #num Spaces

    loop:
        lb $t7, 0($s5) #get each character of the string
        beq $t7, $t6, breakLoop #when s6 contains a newline char, the end of the string has been reached and therfore breakLoop should be called
        beq $t7, $t1, noCharError #break if the character is a space and check its position in noCharError
        bne $s0, $t1, noCharError #go to noCharError if the previous char is equal to zero
        beq $s7, $zero, noCharError #if the num of previously seen characters is not zero and
        beq $t7, $zero, noCharError #if the chLaracter is not null and
        beq $t7, $t6, noCharError #if the character is not new line then print invalid, check if string is too long first before checking if there are invalid characters
        sub $s5, $t5, $s6 #s5 = i - num of spaces
        addi $s5, $s5, 1 #s5++ the index
        li $t7, 4  #t1 = 4
        ble $s5, $t7, LengthCheck #if the string is less than t7, check the length
        li $v0, 4 #load message
        la $a0, tooLongErrorMsg #load tooLong error message into register $a0
        syscall #printed too long error for the input
        jr $ra
    LengthCheck:
        li $v0, 4 #load message
        la $a0, wrongCharErrorMsg #load wrong char message into register $a0
        syscall #output to console
        jr $ra #exit after output
    noCharError:
        beq $t7, $t1, NoIncrement #if the character is equal to a space, increment the number
        addi $s7, $s7, 1 #increase numlength
    NoIncrement:
        bne $t7, $t1, NoCount #if current char is a space and
        bne $s7, $zero, NoCount         #if prevNum is equal to 0 then count space
        addi $s6, $s6, 1
    NoCount:
        move $s0, $t7 #set previ char with current one
        addi $s5, $s5, 1 #increment address of char
        addi $t5, $t5, 1  #increment i
        j loop #go to the loop with the next value
    breakLoop:
        li $t7, 4 #load the value 4 into $t7
        ble $s7, $t7, OutputnotLong #checks if user input is greater than 4 go to outputnotlong to determine if there it is made of spaces
        li $v0, 4 #load value of string into v0
        la $a0, tooLongErrorMsg #load address of toolongerrormsg into a0 for output
        syscall #output too long error for the input to console
        jr $ra #exit after output
    OutputnotLong:
        bne $s7, $zero, NonEmptyStringOuput #if length of the string is zero, go to label
        beq $t7, $t6, NonEmptyStringOuput #if user input is a newline, and then end is reached and the string is empty, go to label
        li $v0, 4 #load value of string into register $v0
        la $a0, EmptyErrorMsg #load value of empty error message into the arguement register $a0
        syscall #output the value of empty error message to console
        jr $ra #exit after output
    NonEmptyStringOuput:
        la $s0, userStr #load address of userStr into register $s0
        add $s0, $s0, $s6 #got the address of the start of the number
        addi $sp, $sp, -4 #allocate space
        sw $ra, 0($sp) #store return address
        move $a0, $s0 #set address of start of number
            li $t2, 1       #initialized power of 36
            li $t9, 0       #initialized sum of decimal value
            li $s3, 36      #constant of 36
    ConvertCharLoop:
            li $t0, -1      #initialized  to -1
            lb $s1, 0($s0)
            li $t5, 65      #a
            li $t1, 90      #z
            blt $s1, $t5, NoConvertUpDigit     #if >= 65 and
            bgt $s1, $t1, NoConvertUpDigit     #if <= 90
            addi $t0, $s1, -55      #got decimal value
    NoConvertUpDigit:
                li $t5, 97      #A
                li $t1, 122     #Z
                blt $s1, $t5, NoConvertCase    #if >= 97 and
                bgt $s1, $t1, NoConvertCase     #if <= 122
                addi $t0, $s1, -87      #got the decimal value of the capital letter
    NoConvertCase:
                li $t5, 48      #0
                li $t1, 57      #9
                blt $s1, $t5, NoConvert       #>= 48 and
                bgt $s1, $t1, NoConvert       #<= 57
                addi $t0, $s1, -48      #got the decimal value of the capital letter
    NoConvert:
                li $s4, -1      #initialized -1 in $s4
                bne $t0, $s4, NoInvalidOutput #if $t0 is -1 then print wrongCharErrorMsg
                li $v0, 4
                la $a0, wrongCharErrorMsg
                syscall
                jr $ra
    NoInvalidOutput:
                mul $s2, $t0, $t2       #value = digit * powerof36
                mul $t2, $t2, $s3       #powerofbase *= 36
                add $t9, $t9, $s2       #sum  = value
                addi $s5, $s5, 1        #increase  i
                addi $t7, $t7, -1       #decremented j
                addi $s0, $s0, -1       #incremented the address to get the next character
                blt $s5, $s7, ConvertCharLoop
                li $v0, 1
                move $a0, $t9
                syscall         #prints sum of the decimal value
                jr $ra
