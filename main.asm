# Author: Massimiliano Sirgiovanni                                        Date: 04/09/2019
# email: massimiliano.sirgiovanni@stud.unifi.it

.data

     #Buffers
     key: .space 4
     buffer: .space 178831
     supportBuffer: .space 178831
     
     K: .word 4
     
     #File di Input e Output  
     outputDecrypted: .asciiz "messaggioDecifrato.txt"
     inKey: .asciiz "chiave.txt"
     fin: .asciiz "messaggio.txt"
     fileOUT:	.asciiz	"messaggioCifrato.txt"
     fnf:	.ascii  "The file was not found"
     errMessage: .ascii "An incorrect character was entered in the KEY"

.text

.globl main
main:
        
start:        
         jal inputKey  # Using the jump and link instruction, select the procedure that will read the key from the text file
                                
         jal inputFile # As previously done for the key, the message to be encrypted is read from the text file
                                                                                              
         li $t6, 0  # $t6 = 0; Reset the registers $ t7 and $ t6 used previously to load the message on the buffer
        
         
algorithmSelection:
                    li $t7, 0   # $t7 = 0;
                    bge $s5, 4, endSelection  # if($s5 >= 4) => jump to endSelection. The maximum length allowed for the key is 4                  
                    lb $t0, key($s5)       # $t0 = key[i] with  0<=i<4    
                    beq $t0, 65, algorithmA  # if($t0 == A) => algorithmA; An equivalent instruction must be executed for the other algorithms
                    beq $t0, 66, algorithmB  # if($t0 == B) => algorithmB;
                    beq $t0, 67, algorithmC  # if($t0 == C) => algorithmC;
                    beq $t0, 68, algorithmD  # if($t0 == D) => algorithmD;
                    beq $t0, 69, algorithmE  # if($t0 == E) => algorithmE;
                    bnez $t0, printError    # if($t0 != null) => printError
                    # In the event that $ t0 had passed all the "if" statements, or must be zero, because the message is finished, or there is an error in the key
endSelection:                    
                    move $v1, $s5                   
                    j print       # Once the algorithms to be applied to the message to be encrypted are finished, the message is printed in the "messageCriptato.txt" output file

printError: 
                    li	$v0, 4		# Print String Syscall
	            la	$a0, errMessage	# Load Error String
	            syscall
	            j endSelection
                                                   
################################################                     
algorithmA:
           lb $s0, buffer($t7)    # $s0 = buffer[$t7]; 
           beqz $s0, endAlgorithmA # if($s0 = null) => endAlgorithmA; The algorithm terminates if the i-th element of the buffer is null
           move $a0, $s0     # Pass to the procedure funcitonA the parameter $s0
           jal functionA     # The functionA procedure is called in order to apply the function required by algorithm A
           addi $t7, $t7, 1  # $t7 = $t7 + 1;  The pointer represented by the register $t7 indicates the position within the message
           j algorithmA      # Call the "algorithmA" procedure to create a cycle that will allow you to apply the "functionA" function to the whole message                                         
           
functionA: 
           lw $t0, K    # $t0 = K; The constant K is equal to 4  
           add $a0, $a0, $t0  # $a0 = $a0 + K;  $a0 was passed by the calling procedure
           li $t1, 256  # $t1 = 256;  We will need it to apply the form function
           divu $a0, $t1  # $a0 : $t1; the quotient is saved in the "lo" register while the rest in the "hi" register
           mfhi $a0   #  $a0 = hi;
           
           sb $a0, buffer($t7) # buffer[t7] = $a0
        
           jr $ra   # ou jump through the register and continue to execute the instructions within the "algorithmA" cycle
           
endAlgorithmA:    
# Once the algorithm A is finished, the pointers are canceled
             li $t1, 0     #  $t1 = 0;
             li $t0, 0     # $t0 = 0;
             j endAlgorithm  # => endAlgorithm
#######################################################                                                                                               
algorithmB:
           
           lb $s0, buffer($t7)       # $s0 = buffer[$t7]; 
           beqz $s0,endAlgorithmA    # if($s0 == null) => endAlgorithmA; The algorithm terminates if the i-th element of the buffer is null
           move $a0, $s0          # Pass to the procedure funcitonA the parameter $s0
           jal functionA     # The functionA procedure is called in order to apply the function required by algorithm A
           addiu $t7, $t7, 2  # $t7 = $t7 + 2; the algorithm should be applied only to characters present in even positions
           j algorithmB      # The loop is started to apply the algorithm B to all the characters of the message
           
############################################################
                   
algorithmC:
           li $t7, 1      # $t7 = 1; The algorithm C requires to apply the algorithm A to the characters present in the odd positions. For this reason the pointer of a position is immediately advanced. 
           j algorithmB            # => algorithmB; The cycle used for the algorithm B is equivalent to that used for the algorithm C, code repetition is avoided and the algorithm B is recalled directly

################################################################
algorithmD:
            jal count       # The "count" procedure is called which returns the number of elements present in the buffer
            move $s3, $v1            # $s3 = $v1; The number of elements returned by the procedure count in the register $s3 is saved
            li $t8, 0      # $t8 = 0; The register $ t8 is reinitialized to use it as a pointer for the algorithm D                  
funzioneD: 
             beqz  $s3, reloadBuffer   # if($s3==0) => reloadBuffer; If the register $ s3, that is the pointer that starts from the final position of the buffer, is equal to zero the algorithm ends.
             sub $s3, $s3, 1         # $s3 = $s3 - 1; 
             lb $t2, buffer($s3)       # $t2 = buffer[$t3];
             sb $t2, supportBuffer($t8)   #supportBuffer[$t8] = $t2; Starting from position 0, the buffer elements are loaded into a support buffer. A new pointer is used.
             addi $t8, $t8, 1          # $t8 = $t8 + 1
             j funzioneD               # A loop is created to apply the D algorithm to all the characters of the message
                                                              
fineD: 
# The registers that were used are reset 
      li $s3, 0   # $s3 = 0; 
      li $t8, 0   # $t8 = 0
      li $t4, 0   # $t4 = 0
      beqz $s7, endAlgorithm  # if($s7 = null) => endAlgorithm; The register $ s7 is used to avoid repetition of code, and to allow the use of algorithm D both for encryption and decryption.
      j endDecryption    # else => endDecryption
 
#######################################################                  
algorithmE: 
             jal count   # The "count" procedure is called which returns the number of elements present in the buffer
             move $s3, $v1  # $s3 = $v1; The number of elements returned by the procedure count in the register $s3 is saved
             li $t5, 0   # $t5 = 0; The registers to be used during the algorithm are reset 
             li $t1, 0   # $t1 = 0;
             li $t9, 0   # $t9 = 0;
startE:      
             beq $t1, $s3, endE    # if($t1 == $s3) => endE; $s3 is equal to buffer.length
             lb $s4, buffer($t1)   # $s4 = buffer[$t1];
             beqz $s4, skipPosition  # if($s4 == null) => skipPosition; If the i-th element is null, the current position is skipped.
             sb $s4, supportBuffer($t9) # supportBuffer($t9) = $s4;
             addiu $t9, $t9, 1  # $t9 = $t9 + 1; Move the pointer forward one position
             move $t5, $t1     # A copy of the pointer $t1 is created inside the register $t5 to be able to use the pointer, without modifying it, in the next cycle
                          
searchSameChar: 
# This procedure creates a cycle that looks for, inside the buffer, all the characters equivalent to the one previously saved in register $t2
               lb $t2, buffer($t5)  # $t2 = buffer[$t5]; 
               beq $t2, $s4, addDash # if($t2 == $s4) => addDash; 
               bge $t5, $s3, addSpace # if($t5 >= $s3) => addSpace; If the pointer is greater than or equal to the maximum position of the buffer, it means that equivalent characters are no longer present
               addiu $t5, $t5, 1 # $t5 = $t5 + 1; Move the pointer forward one position
               j searchSameChar  # => searchSameChar; A cycle is created that re-runs the "searchSameChar" procedure

addDash: 
#This procedure is called when a character similar to the one previously loaded in the register $s4 is found inside the buffer  
         li $t8, 45   # $t8 = 45; In the register $ t8 the ASCII code of "-" is inserted to be able to use it in the algorithm E        
         sb $t8, supportBuffer($t9) # supportBuffer[$t9] = $t8; It is inserted in the support buffer, in which the encrypted message is inserted, the dash "-"
         addiu $t9, $t9, 1          # $t9 = $t9 + 1; 
         
addNumber: 
           move $t4, $t5   # $t4 = $t5; Pass the value of register $ t5 in the register $ t4 to be able to perform calculations
           li $t2, 10000   # $t2 = 10000; The number 10000 is inserted in the register $t2 in order to make the divisions necessary for the success of the algorithm
           div $t4, $t2    # $t4 : $t2 => The quotient and the rest sell saved in the "lo" and "hi" registers
           jal operAddNumb # => operAddNumb; We call the "operAddNumb" procedure to enter the tens of thousands
           move $s6, $v1   # $s6 = $v1; The result of the procedure called is kept in $ s6
           beq $s6, 48, calculateNumber  # if($s6 == 0) => calculateNumber;
           addi $t9, $t9, 1  # $t9 = $t9 + 1; 
 
calculateNumber:
#This procedure allows, starting from the units of thousands, to calculate, and insert in the buffer, all the digits of the position saved in $t4
            divu $t2, $t2, 10  # $t2 = $t2 : 10; Starting from register $t2 = 10000 the register is gradually reduced up to $t2 = 1
            div $t4, $t2   # The position previously saved in the register $t4 is divided by a number between {1000, 100, 10, 1} in order to obtain all the necessary figures
            jal operAddNumb   # We call the "operAddNumb" procedure to enter the digits
            move $s6, $v1     # $s6 = $v1; The result of the procedure called is kept in $ s6
            beq $t2, 1, endCalculate  # if($t2 == 1) => endCalculate; 
            bne $s6, 48 addPosition  # if($s6 != 0) => addPosition; 
            sub $s2, $t9, 1   # $s2 = $t9 - 1; In the register $ s2 the position preceding the one indicated by $ t9 is loaded
            lb $s1, supportBuffer($s2)    # $s1 = supportBuffer($s2);
            beq $s1, 45, calculateNumber  # if($s1== "-") => calculateNumber; The cycle is restarted
            addiu $t9, $t9, 1 # $t9 = $t9 + 1; If the previous instruction is false, the pointer is advanced
            j calculateNumber # => calculateNumber; The procedure is restarted by creating a cycle
            
addPosition:                        
            addiu $t9, $t9, 1  # $t9 = $t9 + 1
            j calculateNumber  # => calculateNumber                                                   
                     
endCalculate: 
# All the digits of the position of the character selected in the support buffer have been calculated and entered
           addiu $t9, $t9, 1    # $t9 = $t9 + 1; 
           li $s1, 0  # $s1 = 0; All the registers used are reinitialized
           li $s2, 0  # $s2 = 0;
           li $t2, 0  # $t2 = 0;
           li $s6, 0  # $s6 = 0;
           
replaceWithZero:      
         sb $zero, buffer($t5)  # buffer[$t5} = 0; Replace the character in the original buffer with a zero
         j searchSameChar       # => searchSameChar; It continues with the search for characters equivalent to the one selected
         
operAddNumb:  
# Operation that allows us to insert the figures just found
         mflo $v1     # $v1 = lo; The result of the previously made division is recovered from the register
         addi $v1, $v1, 48   # $v1 = $v1 + 4; The number 48 is added to that result, which represents the zero in the ascii code
         sb $v1, supportBuffer($t9)  # supportBuffer[$t9] = $v1; 
         mfhi $t4    # $t4 = hi; We retrieve the rest of the division just made and save it in the register $t4
         jr $ra      

addSpace: 
         li $s0, 32      # $s0 = " "; 32 is the ascii code of space
         sb $s0, supportBuffer($t9)   # supportBuffer[$t9]= $s0; 
         addiu $t9, $t9, 1          # $t9++; The pointers are advanced
         
skipPosition:
           addiu $t1, $t1, 1  #$t1++;
           j startE         # => startE; The algorithm E is restarted to choose another character
                                                       
endE: 
      sub $t9, $t9, 1    # $t9--; The pointer is moved back one position
      sb $zero, supportBuffer($t9) # supportBuffer[$t9] = 0;  Since an extra space has been inserted at the end of algorithm E it is eliminated by replacing it with zero
      li $t9, 0  # $t9 = 0; The registers used for the algorithm E are reset
      li $t8, 0  # $t8 = 0
      li $t5, 0  # $t5 = 0
      li $s3, 0  # $s3 = 0
      li $t1, 0  # $t1 = 0
      li $v1, 0  # $v1 = 0
      j reloadBuffer     # => reloadBuffer
##########################################################
endAlgorithm:
               addiu $s5, $s5, 1   #$t5++;
               j algorithmSelection  # => algorithmSelection; Return to algorithm selection
               
###########################################################              
count:     
           li $v1, 0  # $v1 = 0;
loopCount:           
           lb $t2, buffer($v1) # $t2 = buffer[$v1];
           beqz $t2, endCount  # if($t2 == null) => endCount;  In this case the count procedure is terminated
           addiu $v1, $v1, 1    # $v1 = $v1 + 1; The pointer $s3 is increased, which at the end of the procedure will be equal to the number of elements present in the buffer
           j loopCount    # => loopCount; A cycle is created
endCount: 
          jr $ra  
          
############################################################            
          
reloadBuffer:  
             li $t7, 0   # $t7 = 0; The register $t7 is reset to zero, to use it as a pointer
loopReload:
             lb $t2, supportBuffer($t7) # $t2 = supportBuffer[$t7]; 
             beqz $t2, clearSupportBuffer  # if($t2 == null) => clearSupportBuffer; 
             sb $t2, buffer($t7)     # buffer[$t7] = $t2; 
             addi $t7, $t7, 1        # $t7 = $t7 + 1; The pointer identified by the register $ t7 is increased
             j loopReload            # => loopReload; The cycle is restarted  
          
clearSupportBuffer:
# The support buffer is reinitialized so that it can be reused 
             li $t7, 0   # $t7 = 0; The register $ t7 is reset to zero, to use it as a pointer
loopClear:
             lb $t2, supportBuffer($t7)  # $t2 = supportBuffer[$t7];
             beqz $t2, fineD    # if($t2 == null) => fineD; 
             sb $zero, supportBuffer($t7)  # supportBuffer[$t7] = 0; The zero is inserted in the support buffer to reinitialize it
             addi $t7, $t7, 1    # $t7++;
             j loopClear         # => loopClear;                        
                

     
#################Decriptazione#################     

startDecryption: 
                 move $s5, $v1      # $s5 = $v1; The pointer to the "key" buffer is retrieved
                 sub $s5, $s5, 1    # $s5--; It is necessary to decrease the pointer of a unit, since no algorithm is called in the last execution of the "selectionAlgorithm" procedure.
                 li $s7, 1  # $s7 = 1; The register $s7 is used only to allow the program to understand if an encryption or decryption is taking place (Useful to avoid duplication of code for algorithm D)    
               
selectionDecryption:
                    li $t7, 0                 # $t7 = 0; The $t7 register is reinitialized so that it can be used as a pointer
                    lb $t0, key($s5)          # $t0 = key($s5); with  0<=i<4
                    beq $t0, 65, DecryptionA  # if($t0 == A) => DecryptionA; Si seleziona, tramite una serie di operatori condizionali, l'algoritmo di decriptazione da eseguire
                    beq $t0, 66, DecryptionB  # if($t0 == B) => DecryptionB;
                    beq $t0, 67, DecryptionC  # if($t0 == C) => DecryptionC;
                    beq $t0, 68, DecryptionD  # if($t0 == D) => DecryptionD;
                    beq $t0, 69, DecryptionE  # if($t0 == E) => DecryptionE;
                    j printDecrypted      # => printDecrypted; Once the algorithms to be applied to the message are finished, the decrypted message must be printed           
########################################################    
                                    
DecryptionA:
# The decryption algorithm A is very similar to the decryption algorithm, in fact the ASCII code of each character of the message, instead of added, is subtracted 4
           lb $s0, buffer($t7)  # $s0 = buffer[$t7];
           beqz $s0, endDecryption  # if($s0 == null) => endDecryption; 
           move $a0, $s0  # $a0 = $s0; The value of the register $a0 is passed to the "decrypA" procedure
           jal decrypA    # => decrypA; The "decrypA" procedure is called, which is the function to apply to the message 
           addi $t7, $t7, 1  # $t7++; 
           j DecryptionA     # => DecryptionA; The cycle is created which allows the decryption algorithm to be applied to all the characters of the message
           
                                           
decrypA:      
           lw $t0, K    # $t0 = K;  The constant K is equal to 4  
           sub $a0, $a0, $t0  # $a0 = $a0 - $t0;
           li $t1, 256  # $t1 = 256; The number 256 is saved in the register $ t1, which will be used to apply the module function
           add $a0, $a0, $t1 # $a0 = $a0 + $t1;
           divu $a0, $t1   # $a0 : $t1; the quotient is saved in the "lo" register while the rest in the "hi" register
           mfhi $a0   # $a0 = hi; The result of the module function, that is the rest of the division made in the previous instruction, is saved in the register $ t2
           
           sb $a0, buffer($t7)  # buffer[$t7]=$a0; 
        
           jr $ra

###############################################################                      

DecryptionB:
           lb $s0, buffer($t7)   # $s0 = buffer[$t7]
           beqz $s0, endDecryption  # if($s0 == null) => endDecryption; The algorithm terminates if the i-th element of the buffer is null
           move $a0, $s0   # $a0 = $s0; The value of the register $a0 is passed to the "decrypA" procedure 
           jal decrypA     # => decrypA; The "decrypA" procedure is called, which is the function to apply to the message 
           addi $t7, $t7, 2  # $t7 = $t7 + 2; the algorithm should be applied only to characters present in even positions
           j DecryptionB  # => DecryptionB; The cycle is created which allows the decryption algorithm to be applied to all the characters of the message
           
##################################################################           

DecryptionC:
            li $t7, 1 # $t7 = 1; The algorithm C requires to apply the algorithm A to the characters present in the odd positions. For this reason the pointer of a position is immediately advanced.
            j DecryptionB  # => DecryptionB; The cycle used for the algorithm B is equivalent to that used for the algorithm C, code repetition is avoided and the algorithm B is recalled directly
             
####################################################################             
             
DecryptionD: 
          
           j algorithmD # => algorithmD; Since the algorithm D is equivalent for both encryption and decryption, the encryption algorithm is called directly
           
####################################################################           
           
DecryptionE:
            li $s4, 0   # $s4 = 0; The register $ s4 is reset because it will be used as a pointer
            
startDecrypE:  
             lb $s2, buffer($s4)  # $s2 = buffer[$s4]; 
             beqz $s2, endDecrypE # if($s2 == null) => endDecrypE;
             
loopE:             
            addiu $s4, $s4, 1  # $s4 = $s4 + 1; 
            lb $s0, buffer($s4)  # $s0 = buffer($s4); This is the next element compared to the one entered in the register $s2
            move $a1, $s0      # $a1 = $s0; The value of $s0 is passed to the procedure
            jal checkEndLoop   # => checkEndLoop; It's called a procedure that allows you to understand if the cycle is over
            move $s0, $a1      # $s0 = $a1; The value returned by the procedure is resumed
            sub $s0, $s0, 48   # $s0 = $s0 - 48; If the character passed to the "checkEndLoop" procedure has passed the procedure itself, necessarily it is a ascii code number and for this reason it subtracts 48 (ascii code of 0)
            j checkDecimal     # => checkDecimal; Let's move on to adding the digits in the support buffer
            
checkEndLoop:             
#The procedure is used to carry out checks and act accordingly
            beq $a1, 45, loopE       # if($a1 == "-") => loopE; If the figure passed to the procedure is equal to 45, or the Ascii code of "-", the cycle is restarted
            beq $a1, 32, restartLoop # if($a1 == " ") => restartLoop; If the figure is equal to 32, or the Ascii code of the space, the algorithm E is restarted by choosing a new digit
            beqz $a1, endDecrypE  # if($a1 != null) => endDecrypE; If the digit is equal to 0, the algorithm ends
            jr $ra
            
restartLoop:
            addiu $s4, $s4, 1  # $s4 = $s4 + 1; 
            j startDecrypE     # =>startDecrypE;  The algorithm is restarted after increasing the pointer
          
checkDecimal:
            move $t9, $s4     # $t9 = $s4; Save the pointer in another register to use two different versions of the same pointer
            
loopCheckDec:            
            addiu $t9, $t9, 1    # $t9++; The pointer is advanced one position
            lb $s1, buffer($t9)  # $s1 = buffer[$t9];
            bge $s1, 58, insert  # if($s1 >= 58) => insert; If the character saved in register $ s1 should be greater than or equal to 58, or greater than the Ascii code of 9, the "insert" procedure is called
            ble $s1, 47, insert  # if($s1 <= 47) => insert; If the character saved in register $s1 should be less than or equal to 47, or less than the Ascii code of 0, the "insert" procedure is called
            sub $s1, $s1, 48     # $s1 = $s1 - 48; Since $ s1 has exceeded the two conditional operators it means for sure that it is the ascii code of a number.
            mul $s0, $s0, 10     # $s0 = $s0 * 10; 
            add $s0, $s0, $s1    # $s0 = $s0 + $s1;  Remember that the number in the register $s0 has been multiplied by 10.
            addiu $s4, $s4, 1     # $s4++; The pointer is advanced one position
            j loopCheckDec        # A cycle is created
            
insert:     
            sb $s2, supportBuffer($s0)  # supportBuffer[$s0] = $s2; 
            j loopE        # Return to the previous cycle
                                                                                                                                                                                     
endDecrypE:            
            li $s4, 0   # $s4 = 0; The registers used for the decryption algorithm E are reinitialized
            li $s0, 0   # $s0 = 0;
            li $t4, 0   # $t4 = 0;
            li $a1, 0   # $a1 = 0;
            li $s2, 0   # $s2 = 0;
            j clearBuffer

clearBuffer:  
# This procedure is used to reinitialize the buffer 
             lb $t2, buffer($t4)    # $t2 = buffer[$t4]; 
             beqz $t2, reloadBuffer # if($t2 == null) => reloadBuffer; If $ t2 is 0 (ASCII code of the null) then the procedure ends 
             sb $zero, buffer($t4)  # buffer[$t4] = 0;
             addiu $t4, $t4, 1   # $t4 = $t4 + 1; Move the pointer forward one position
             j clearBuffer    # A cycle is created
                            
####################################################################

endDecryption:
           
           sub $s5, $s5, 1        # $s5 = $s5 - 1; The pointer of the key of a position is moved back
           j selectionDecryption  # => selectionDecryption; Return to the selection of the decryption algorithms

                                        
 exit: 
     li $v0, 10   # End the program
     syscall                      
              


#####################Operazioni di Input################        
                    
inputFile:  
open: 
      li   $v0, 13       # system call for open file
      la   $a0, fin      # board file name
      li   $a1, 0        # Open for reading
      li   $a2, 0
      syscall            # open a file (file descriptor returned in $v0)
      move $s6, $v0      # save the file descriptor
      blt $v0, 0, err	# Goto Error 

read:
     li   $v0, 14       # system call for read from file
     move $a0, $s6      # file descriptor
     la   $a1, buffer   # address of supportBuffer to which to read
     li   $a2, 178831     # hardcoded supportBuffer length
     syscall            # read from file

closeInputFile: 
               li   $v0, 16       # system call for close file
               move $a0, $s6      # file descriptor to close
               syscall            # close file        
               jr $ra
               
               
               
inputKey:  
openKey: 
      li   $v0, 13       # system call for open file
      la   $a0, inKey      # board file name
      li   $a1, 0        # Open for reading
      li   $a2, 0
      syscall            # open a file (file descriptor returned in $v0)
      move $s6, $v0      # save the file descriptor 
      blt $v0, 0, err	# Goto Error 

readKey:
     li   $v0, 14       # system call for read from file
     move $a0, $s6      # file descriptor 
     la   $a1, key   # address of supportBuffer to which to read
     li   $a2, 4     # hardcoded supportBuffer length
     syscall            # read from file

closeInputFileKey: 
               li   $v0, 16       # system call for close file
               move $a0, $s6      # file descriptor to close
               syscall            # close file        
               jr $ra               
       
####################Operazioni di Output####################
# Write Data
print:
	li	$v0, 13		# Open File Syscall
	la	$a0, fileOUT	# Load File Name
        li $a1, 1            
        li $a2, 0	
	syscall
	move	$t1, $v0	# Save File Descriptor
	li	$v0, 15		# Write File Syscall
	move	$a0, $t1    	# Load File Descriptor
	la	$a1, buffer	# Load Buffer Address
	li	$a2, 178831	# Buffer Size 
	syscall
# Close File
close:
	li	$v0, 16		# Close File Syscall
	move	$a0, $t1	# Load File Descriptor
	syscall
	j	startDecryption		# Goto Decryption


#Output Decrypted

printDecrypted:  

	li	$v0, 13		# Open File Syscall
	la	$a0, outputDecrypted	# Load File Name
        li $a1, 1            
        li $a2, 0	

	syscall
	move	$t1, $v0	# Save File Descriptor

	li	$v0, 15		# Write File Syscall
	move	$a0, $t1    	# Load File Descriptor
	la	$a1, buffer	# Load Buffer Address
	li	$a2, 178831	# Buffer Size 
	syscall


 
# Close File
closeDecryptation:
	li	$v0, 16		# Close File Syscall
	move	$a0, $t1	# Load File Descriptor
	syscall
	j	exit		# Goto End

# Error
err:
	li	$v0, 4		# Print String Syscall
	la	$a0, fnf	# Load Error String
	syscall
