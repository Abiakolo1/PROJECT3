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
    la $s5, userStr      #  the address of the string
    li $t5, 0       #initialized i= 0
    li $t1, 32      #  space here
    li $s0, 0       #initialized previous character to 0
    li $s7, 0       #initialized numofchracters
    li $t6, 0x0A    #  new line here
    li $s6, 0       #num Spaces
    loop:
        lb $t7, 0($s5) #got a character of the string
        beq $t7, $t6, breakloop #break when newline
        beq $t7, $t1, noCharError #if the character is not a space and
        bne $s0, $t1, noCharError #if the previous character is a space and
        beq $s7, $0, noCharError          #if the num of previously seen characters is not zero and
        beq $t7, $0, noCharError          #if the chLaracter is not null and
        beq $t7, $t6, noCharError         #if the character is not new line then print invalid
        li $v0, 4
        la $a0, wrongCharErrorMsg
        syscall         #print invalid spaces
        jr $ra
    noCharError:
        beq $t7, $t1, NoIncrement      #if character is not equal to a space, increment numchars
        addi $s7, $s7, 1
    NoIncrement:
        bne $t7, $t1, NoCount        #if space and
        bne $s7, $0, NoCount         #if prevNum is equal to 0 then count space
        addi $s6, $s6, 1
    NoCount:
        move $s0, $t7           #set prev char to current one
        addi $s5, $s5, 1        #incremented the address
        addi $t5, $t5, 1        #incremented i
        j loop
    breakloop:
        li $t7, 4
        ble $s7, $t7, OutputnotLong #checks if user input is greater than 4
        li $v0, 4
        la $a0, tooLongErrorMsg
        syscall         #printed too long error for the input
        jr $ra
    OutputnotLong:
            bne $s7, $zero, NonEmptyStringOuput   #if user input is empty, and
            beq $t7, $t6, NonEmptyStringOuput     #if user input is a newline print empty error message
            li $v0, 4
            la $a0, EmptyErrorMsg
            syscall
            jr $ra
    NonEmptyStringOuput:
            li $s5, 0       #initialized inde
            addi $t7, $s7, -1       #initialize j
            la $s0, userStr      #string address
            add $s0, $s0, $s6       #start number
            add $s0,$s0, $t7        #add length -1 to the address(starts from the end)
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
