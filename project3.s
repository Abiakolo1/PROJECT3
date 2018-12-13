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
        move $a2, $s7 #set length of string
        jal convertChar #go to convertChar
        move $s5, $v0 #move value of $v0 into $s5
        li $v0, 1
        move $a0, $s5 #move $s5 into arguement register #a0
        syscall
        lw $ra, 0($sp)  #restore return address
        addi $sp, $sp, 4 #deallocate space
        jr $ra
    convertChar:
        addi $sp, $sp, -20  #allocate space
        sw $ra, 0($sp)  #set return address
        sw $s0, 4($sp)  #set s0  = address of arr
        sw $s4, 8($sp)  #set s1  = length arr
        sw $s3, 12($sp)  #set s2  = first num
        sw $s1, 16($sp)  #set s3  = power of 36
        move $s0, $a0  #transfer arguement register $a0 which is the address of array into the saved register $s0
        move $s4, $a2  #transfer arguement register $a0 which is the length of array into the saved register $s0
        li $s5, 1 #in the base case
        bne $s4, $s5, DecideNum    #if length == 1 then
        lb $t7, 0($s0) #loads the first element of the array
        move $a0, $t7 #set char to arg for CovertCharToNum function
        jal CovertCharToNum #go to convertchartonum
        move $t7, $v0  #get result
        move $v0, $t7 #moves first element to $v0
        j exitconvertChar #exitconvertchar is called
    DecideNum:
        addi $s4, $s4, -1  #decrement length
        move $a0, $s4  #set arguments for MakePow
        jal MakePow #jump to make pow
        move $s1, $v0  # get registers s1 = 36 ^ (len-1)
        lb $s5, 0($s0) #loads the first element of the array
        move $a0, $s5 #moved register $s5 into $a0
        jal CovertCharToNum #convert the character to a number
        move $s5, $v0 #move $s5 into $v0
        mul $s3, $s5, $s1
        addi $s0, $s0, 1  #increment ptr to beginning of the array
        move $a0, $s0  #set arguement for conversion
        move $a2, $s4
        jal convertChar #jump to convert Char label
        move $s5, $v0  #get conversion
        add $v0, $s3, $s5  #return conversion + addition
    exitconvertChar:
        lw $ra, 0($sp)  #reset return address
        lw $s0, 4($sp)  #reset s0  = addr of arr
        lw $s4, 8($sp)  #reset s1  = length arr
        lw $s3, 12($sp)  #reset s2  = first num
        lw $s1, 16($sp)  #set s3  = power of 36
        addi $sp, $sp, 20  #deallocate space
        jr $ra
    MakePow:
        addi $sp, $sp, -4 #allocate space
        sw $ra, 0($sp) #set return address
        li $s5, 0 #load 0 zero into $s5
        bne $a0, $s5, IsFirstChar
        li $v0, 1
        j exitPow
    IsFirstChar:
        addi $a0, $a0, -1  #setting arg for recursion call
        jal MakePow
        move $t7, $v0 #result in $v0 moved to $t7
        li $t5,36 #first number
        mul $v0, $t5, $t7 #takes the mult result and puts it into $v0
    exitPow:
        lw $ra, 0($sp)  #restore return address
        addi $sp, $sp, 4 #deallocated space
        jr $ra
    CovertCharToNum:
        li $t5, 65
        li $t1, 90 #convert character to digit
        blt $a0, $t5, NoConvertUpDigit  #if char >= 65 and
        bgt $a0, $t1, NoConvertUpDigit # char <= 90

