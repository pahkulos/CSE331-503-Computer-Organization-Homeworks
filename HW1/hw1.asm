
.data
buffer: .space 40 #array
arrString: .space 40
sizeOfLis: .space 40
answerIndex: .space 40
space: .asciiz " "
newline: .asciiz "\n"
size:	.asciiz "]  size = "
inputText: .asciiz "input.dat"      # filename for input
fileName: .asciiz "output.txt"     # filename for output
arrtext: .space 1024
writeText: .space 1024
outputText:.ascii "Array_outp: ["
.text
main:
	la  $s3,writeText
	j readfile
readfile:
	#open a file for writing
	li   $v0, 13       # system call for open file
	la   $a0, inputText     # board file name
	li   $a1, 0        # Open for reading
	li   $a2, 0
	syscall            # open a file (file descriptor returned in $v0)
	move $s6, $v0      # save the file descriptor 

	#read from file
	li   $v0, 14       # system call for read from file
	move $a0, $s6      # file descriptor 
	la   $a1, arrtext  # address of buffer to which to read
	la   $s7,0($a1)
	li   $a2, 1024     # hardcoded buffer length
	syscall            # read from file


	# Close the file 
	li   $v0, 16       # system call for close file
	move $a0, $s6      # file descriptor to close
	syscall            # close file
	j readOneArrayMain
	
readOneArrayMain:
	la $s0,buffer
	la $s6,buffer
	la $a1,arrString
	j takeOneArrFromFile

takeOneArrFromFile:
	lb $t1, 0($s7)
	beq $t1,13,lineTransition
	beqz $t1,exit
	sb $t1, 0($a1)
	addi $s7,$s7,1
	addi $a1,$a1,1
	j takeOneArrFromFile

lineTransition:
	addi $s7,$s7,1 #newline
	addi $s7,$s7,1 #for taking first element of new array
	sb $t1, 0($a1)
	la $a1,arrString
	j myAtoi
myAtoi:
	li $t0,0	#k
	li $t1,0	#res
	li $t2,	0	#i
	li $t9,10
	j atoiLoop
atoiLoop:
	lb $t3,0($a1)	#str[i]=x
	beq $t3,13,exitif
	bne $t3,44,ifblock
	#else block
	sb $t1,0($s0)
	addi $t0,$t0,1	#size
	addi $a1,$a1,1 #i++
	addi $s0,$s0,1 #k++
	li $t1,0
	j transitionAtoi
	

transitionAtoi:
	addi $a1,$a1,1 #i++
	j atoiLoop
ifblock:
	subi $t8,$t3,48	#str[i]-'0'
	mult  $t1, $t9
	mflo  $t4	#res*10
	add $t1,$t4,$t8 	
	j transitionAtoi
exitif:
	sb $t1,0($s0)
	addi $t0,$t0,1	#size
	
	j lis
#t0=size
#buffer is array
	
lis:
	
	la $t3, 0($t0) #size
	la $t0, sizeOfLis
	la $s0, answerIndex
	li $t1, 0
	li $t2, 1
	li $t7, -1
	li $s2, 1 #maxIndex
	addi $t4,$t3,0	#$t4 =size
	j initLoop
	
initLoop:
	sb $t2, 0($t0) # 1,1,1,1,1,1 :answer
	sb $t7, 0($s0) # -1,-1,-1,-1,-1,-1 
	addi $t0, $t0, 1
	addi $s0, $s0, 1
	addi $t1, $t1, 1
	blt  $t1, 10, initLoop
	la $t0, sizeOfLis	# t0 baþa dondu
	la $s0, answerIndex
	la $t1, buffer	# t1 de array var
	li $t2, 1	# t2 1 =i
	j dynamicLoop

dynamicLoop:
	beq $t2, $t4, printTrans
	li $t3, 0 # =j
	j dynamicInnerLoop

ifEqualTransition: # i ve j esýt olunca geçmek ýcýn
	addi $t2, $t2, 1
	j  dynamicLoop

dynamicInnerLoop:
	beq $t3, $t2, ifEqualTransition
	li $t5, 1
	mult  $t5, $t2
	mflo  $t6	#i*4
	mult $t3, $t5
	mflo $t7	#j*4
	add $t8, $t1, $t6 #arr[i]
	add $t9, $t1, $t7 #arr[j]
	lb $t6 0($t8)	#arr[i] = x
	lb $t7 0($t9)	#arr[j]	= x
	ble $t6, $t7, otherif #if(arr[j] >= arr[i] j++
	mult  $t5, $t2
	mflo  $t6
	mult $t3, $t5
	mflo $t7
	add $t8, $t0, $t6	#sizeOfLis[i]
	add $t9, $t0, $t7	#sizeOfLis[j]
	lb $t6, 0($t8)	#sizeOfLis[i]=x
	lb $t7, 0($t9)	#sizeOfLis[j]=x
	addi $t7, $t7, 1 #sizeOfLis{j]+1
	bge $t6, $t7, transition
	sb $t7, 0($t8) #sizeOfLis[i]= sizeOfLis[j]+1;
	lb $t6, 0($t8)
	subi $t6,$t6,2
	mult  $t5, $t6
	mflo  $t6	#sizeOfLis{i]-2=x
	add $s1, $s0, $t6#[sizeOfLis[i]-2]
	lb $t6,0($s1)
	beq $t6,-1, assignIndex
	j continue
otherif:		#if(arr[i]<arr[j]&&sizeOfLis[i]==sizeOfLis[j])
	mult  $t5, $t2
	mflo  $t6
	mult $t3, $t5
	mflo $t7
	add $t8, $t0, $t6	#sizeOfLis[i]
	add $t9, $t0, $t7	#sizeOfLis[j]
	lb $t6, 0($t8)	#sizeOfLis[i]=x
	lb $t7, 0($t9)	#sizeOfLis[j]=x
	beq $t6,$t7,innerif
innerif:
	subi $t6,$t4,1
	bne $t2,$t6 transition2
transition2:
	subi $t7,$t7,1
	j transition
continue:
	mult  $t5, $s2
	mflo  $t6
	add $t8,$t0,$t6
	lb $t6,0($t8)
	bgt $t7,$t6, findMaxIndex
	j transition
assignIndex:
	sb $t3, 0($s1)	#answerIndex[i]=j;
	j continue
findMaxIndex:
	move $s2,$t2
	j transition
transition:	# jye 1 ekler
	addi $t3, $t3, 1
	j dynamicInnerLoop

printTrans:
	li $t2 0
	lb $t5, 0($t0)
	j maxLoop	

putMax:
	move $t5, $t3
	j maxLoop
	
maxLoop:
	beq $t2, $t4, printLongestSub
	lb $t3, 0($t0)
	addi $t0, $t0 1
	addi $t2, $t2, 1
	bgt $t3, $t5, putMax
	j maxLoop
	

printLongestSub:
	li $t2,1
	subi $t3,$t5,1
	mult  $t2, $t3
	mflo  $t3
	add $s1,$s0,$t3
	sb $s2,0($s1)
	addi $t3,$0,0
	li $v0,4
	la $a0,outputText
	syscall
	li $t7,0
writeOutputText:
	beq $t7,13,printLoop
	lb $t6,0($a0)
	sb $t6,0($s3)
	addi $s3,$s3,1
	addi $a0,$a0,1
	addi $t7,$t7,1
	j writeOutputText
printLoop:
	beq $t3,$t5 printSize
	mult  $t2, $t3
	mflo  $t4
	add $s1,$s0,$t4	  #[i]
	lb $t6,0($s1)	#[i]=x
	mult  $t2, $t6
	mflo  $t6
	add $t9,$t1,$t6
	lb $t6,0($t9)
	li $v0,1
	la $a0,0($t6)
	syscall
	li $v0, 4
	la $a0,space
	syscall
	addi $t3,$t3,1
	blt $t6,10,oneStep
	bgt $t6,99,threeStep
	j twoStep
continue2:
	li $t6,32
	sb $t6,0($s3)
	addi $s3,$s3,1
	j printLoop
	
twoStep:		#itoa for 2 digit number 
	div $t6,$t6,10
	addi $t6,$t6,48
	sb $t6,0($s3)
	addi $s3,$s3,1
	subi $t6,$t6,48
	mulo $t6,$t6,10
	sub $t6,$t6,$t6
	j oneStep
oneStep:		#itoa for 1 digit number 
	addi $t6,$t6,48
	sb $t6,0($s3)
	addi $s3,$s3,1
	j continue2
threeStep:		#itoa for 3 digit number 
	div $t6,$t6,100
	addi $t6,$t6,48
	sb $t6,0($s3)
	addi $s3,$s3,1
	subi $t6,$t6,48
	mulo $t6,$t6,100
	sub $t6,$t6,$t6
	j twoStep
	
	
	
printSize:
	li $v0,4
	la $a0,size
	syscall
	li $t7,0
writeSizeText:	# it just write ]size: character by character 
	beq $t7,9,writeSize
	lb $t6,0($a0)
	sb $t6,0($s3)
	addi $s3,$s3,1
	addi $a0,$a0,1
	addi $t7,$t7,1
	j writeSizeText
writeSize:		# it just write size integer like size character
	move $a0, $t5
	li $v0, 1
	syscall
	addi $t5,$t5,48
	sb $t5,0($s3)
	addi $s3,$s3,1
	li $v0, 4
	la $a0,newline
	syscall
	li $t6,10
	sb $t6,0($s3)
	addi $s3,$s3,1
	
	j readOneArrayMain	
	
exit:
	jal writeToFile
	li $v0, 10
	syscall
writeToFile:
    	li $v0,13           	# open_file syscall code = 13
    	la $a0,fileName     	# get the file name
    	li $a1,1           	# file flag = write (1)
    	syscall
    	move $s1,$v0        	# save the file descriptor. $s0 = file

    	li $v0,15		# write_file syscall code = 15
    	move $a0,$s1		# file descriptor
    	la $a1,writeText		# the string that will be written
    	la $a2,300		# length of the toWrite string
    	syscall
    	
    	li $v0,16         		# close_file syscall code
    	move $a0,$s1      		# file descriptor to close
    	syscall
	jr $ra

