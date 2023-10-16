INCLUDE irvine32.inc
INCLUDE macros.inc

BUFFER_SIZE = 5000
BUFFER_SIZE2 = 5000

openingFile PROTO ,
	filename : dword

CalculateforLoop PROTO,
	targetOffset:DWORD,
	lengthTarget:DWORD

clearTokenArray PROTO,
	toeknoffset:DWORD,
	lengthofToken:DWORD


tokenize PROTO,
	targetOffset:DWORD,
	lengthTarget:DWORD,
	tokenOffset:DWORD,
	index:DWORD

Str_concat PROTO,
	source:DWORD, 			; source string
	target:DWORD,			; target string
	lengthofSor:DWORD,
	x : dword

get_prevtokenlength PROTO,
	tokenn:DWORD

ClearSpecialCharacters PROTO,
		stringRecieved:DWORD,character:BYTE,stringLength:DWORD


.data

;<--------------------PROJECT TITLE-------------------->
	asciBuffer BYTE BUFFER_SIZE DUP(0)
	asciFile BYTE "ASCIIART.txt",0
	asciFileHandle HANDLE ?

;<--------------------User Input and File Reading-------------------->
	source byte BUFFER_SIZE dup(0)
	target byte BUFFER_SIZE dup(0)
	buffer BYTE BUFFER_SIZE DUP(0)
	filename1 byte 15 dup(0)
	filename2 byte 15 dup(0)
	fileHandle HANDLE ?
	txt BYTE ".txt",0
	promttitle BYTE "File Name Error",0
	promtstring BYTE "Please place an exsisting file or a Valid extension!",0
	prompt BYTE "Plagirized String: ",0
	prompt1 BYTE "Word Count in Source: ",0
	prompt2 BYTE "Word Count in Target: ",0

;<--------------------User Input and File Reading-------------------->
	token BYTE LENGTHOF target DUP(?)
	token2 BYTE LENGTHOF source DUP(?)
	forloopCount DWORD ?
	matchedstring BYTE BUFFER_SIZE DUP(0)
	tokenlen DWORD ?
	savedEAX DWORD ?
	savedEBX DWORD ?
	WordsinTarget DWORD ?
	WordsinSource DWORD ?
	SpecialCharacters BYTE	"!", "@" , "#" , "$" , "%" , "^", "&" , "*" , "(" , ")" , "." , "?", "'", ";", ","
	SimilarWords DWORD 0
	percentage DWORD 0
	WordsinT DWORD -1
	WordsinS Dword 1
	fn byte "File 1.txt",0

.code

	main PROC
;<--------------------PROJECT TITLE-------------------->

	mov edx,OFFSET asciFile
	call OpenInputFile
	mov asciFileHandle, eax

	mov edx,OFFSET asciBuffer 
	mov ecx,BUFFER_SIZE
	call ReadFromFile
	mov asciBuffer[eax],0 ; insert null terminator
	mWriteString offset asciBuffer

;<--------------------------END------------------------->


;<--------------------User Input and File Reading-------------------->
	
		mov  eax,(black)+(white*16);
		call setTextColor
		mov DL,30
		mov DH,24
		call gotoxy											;(DH=row , DL=col)
		mWrite"Enter File Name to Check for Plagiarism "

		;call ClrScr
		mov  eax,yellow+(black*16);
		call setTextColor

ReWrite:		mov dh , 26
				mov dl , 35
				call gotoxy
				mwrite "(1) Enter File Name: "
				mov edx , offset filename1
				mov ecx , 15
				call readstring

validatefileName1:										;<-----Validating if EXTENSION .txt exist----->
					mov edi,OFFSET filename1
					mov esi,OFFSET txt
					mov ecx,eax			;lengthof string entered.
					mov eax,0			;for validation, if '.' exsist.
					mov bl,'.'
					L1:	
						cmp [edi],bl
						JNE incrementedi
							L2:
							mov bl,[esi]
							cmp [edi],bl
							JNE displayError
							inc eax
							inc esi
							inc edi	
							loop L2
							jmp outsideloop
incrementedi:			inc edi
					loop L1

outsideloop:		cmp eax,3
					JB displayError

					jmp InputNextFile

displayError:				mov edx,OFFSET promtstring
							mov ebx,OFFSET promttitle
							call MsgBox
							jmp ReWrite


InputNextFile:		INVOKE openingFile , offset filename1
				
					
ReWrite2:		mov dh , 27
				mov dl , 35
				call gotoxy
				mwrite "(2) Enter File Name: "
				mov edx , offset filename2
				mov ecx , 15
				call readstring

validatefileName2:										;<-----Validating if EXTENSION .txt exist----->
					mov edi,OFFSET filename2
					mov esi,OFFSET txt
					mov ecx,eax			;lengthof string entered.
					mov eax,0			;for validation, if '.' exsist.
					mov bl,'.'
					L3:	
							cmp [edi],bl
							JNE incrementedi2

							L4:
							mov bl,[esi]
							cmp [edi],bl
							JNE displayError2
							inc eax
							inc esi
							inc edi	
							loop L4
							jmp outsideloop2
incrementedi2:				inc edi
					loop L3

outsideloop2:		cmp eax,4
					JB displayError2
					jmp InputNextFile2

displayError2:				mov edx,OFFSET promtstring
							mov ebx,OFFSET promttitle
							call MsgBox
							jmp ReWrite2

InputNextFile2:		INVOKE openingFile , offset filename2

;<----------------------------END----------------------------------->

;<-------------------- Removing the Special Characters ----------------->

					mov ecx,LENGTHOF SpecialCharacters
					mov esi,OFFSET SpecialCharacters
					Loop1:
						mov bl,[esi]
						INVOKE ClearSpecialCharacters ,ADDR source , bl , LENGTHOF source
						inc esi
					loop Loop1

					mov ecx,LENGTHOF SpecialCharacters
					mov esi,OFFSET SpecialCharacters
					Loop2:
						mov bl,[esi]
						INVOKE ClearSpecialCharacters ,ADDR target , bl , LENGTHOF target
						inc esi
					loop Loop2

;<---------------------------- END ------------------------------------->


;<-------------------- Extracting Number of Words -------------------->

					mov esi, offset source
					mov ecx, lengthof source
					X1:
						mov dl,[esi]
						cmp dl,32
						JNE increment
						add WordsinS,1
						increment: add esi,1
					loop X1
					

					mov esi, offset target
					mov ecx, lengthof target
					X2:
						mov dl,[esi]
						cmp dl,32
						JNE increment1
						add WordsinT,1
						increment1: add esi,1
					loop X2

;<---------------------------- END ------------------------------------->

;<--------------------------- Printing both the strings ---------------->
					
					mwrite "Source: "
					mov edx , offset source
					call writestring
					call crlf

					mwrite "Target: "
					mov edx , offset target
					call writestring
					call crlf
					call crlf

					mov  eax,(black)+(cyan*16);
					call setTextColor
					mov edx , offset prompt1
					call writestring
					mov  eax,(yellow)+(black*16);
					call setTextColor
					mwrite " "
					mov eax , WordsinS
					call writedec
					call crlf

					mov  eax,(black)+(cyan*16);
					call setTextColor
					mov edx , offset prompt2
					call writestring
					mov  eax,(yellow)+(black*16);
					call setTextColor
					mwrite " "
					mov eax , WordsinT
					call writedec
					call crlf
					call crlf
;<----------------------------END------------------------------------->



;<-------------------- Plag Checking Logic -------------------->
INVOKE CalculateforLoop, OFFSET target,LENGTHOF target			;returns the number of words in the target string. 
	mov ecx,forloopCount
	add ecx,1
	mov eax,0			;TARGET indexing
	mov ebx,0			;SOURCE indexing
	mov edx,0			;min matched count needs to be 3 for there to detect plag.

	Loopforcomparing:

;<-------------------- Converting to upper case -------------------->
		
		INVOKE Str_Ucase , ADDR source
		INVOKE Str_Ucase , ADDR target

	;---------- Breaks down each word one at a time everytime the loop iterates ----------

		INVOKE tokenize, OFFSET target, LENGTHOF target, OFFSET token,eax
		INVOKE tokenize, OFFSET source, LENGTHOF source, OFFSET token2,ebx

	;---------- If word is matched JUMP to the Label ----------
		
		INVOKE str_compare, ADDR token, ADDR token2
		JZ incrementBoth
		;call CRLF
		
			;---------- when there is a mismatch---------- 

		NotMatched: 
					cmp edx,3
					JL checkeax
					PUSH EDX
					PUSH eax
					mov  eax,(black)+(yellow*16);
					call setTextColor
					mov edx , offset prompt
					call writestring
					pop eax
					push eax
					mov  eax,(yellow)+(black*16);
					call setTextColor
					mov edx,OFFSET matchedstring			;printing RESULT
					call WriteString
					pop eax
					POP EDX

					push ecx
					mov esi, offset matchedstring
					mov ecx, lengthof matchedstring
					Y1:
						mov dl,[esi]
						cmp dl,32
						JNE increment2
						add SimilarWords,1
						increment2: add esi,1
					loop Y1
					pop ecx

					INVOKE clearTokenArray, ADDR matchedstring, LENGTHOF matchedstring
					call CRLF
					mov edx,0
					jmp lagain

;----------Target is traversed until the desired value is found and starts comparing onwards.----------

checkeax:	INVOKE clearTokenArray, ADDR matchedstring, LENGTHOF matchedstring
			inc eax
			cmp eax,forloopCount		;forloopccount contains the number of words in Target
			JG lagain
			mov savedEAX,eax
			mov ecx,ecx
			PUSH ECX

			;----------Target is tokenized till the end and each target word is compared to a single word in token2----------

				L5:
					INVOKE tokenize, OFFSET target, LENGTHOF target, OFFSET token,eax
					INVOKE str_compare, ADDR token, ADDR token2
					JZ incrementBoth
					inc eax
					cmp eax,forloopCount
					JG ResetEAXtoPREVPos

				 loop L5
				POP ECX

ResetEAXtoPREVPos:		mov eax,savedEAX
						inc eax
						inc ebx
						add ecx,200		;increasing COUNTER.
						jmp lagain

		incrementBoth:
			inc eax
			inc ebx
			inc edx		;min matched count needs to be 3 --this acts as a counter.
			
			INVOKE Str_concat, ADDR token, ADDR matchedstring,tokenlen,1
								
lagain:	dec cx
		JNZ Loopforcomparing

;<----------------------------END---------------------------->

;<-------------Calculating Percentage------------>
	
	push eax
	push ebx
	push edx

	mov eax , SimilarWords
	call WriteDec
	mov ebx , 100
	imul ebx
	mov edx , 0
	mov ebx , WordsinT
	div ebx
	mov percentage , eax
	pop edx
	pop ebx
	pop eax
	
;<----------------------------END---------------------------->

LEXIT:
;<----------------------------Printing similar Words---------------------------->

	push eax
	call crlf
	call crlf
	mov  eax,(black)+(cyan*16);
	call setTextColor
	mwrite "Similar Words in both the strings :"
	mov  eax,(yellow)+(black*16);
	call setTextColor
	mwrite " "
	mov eax , SimilarWords
	call writedec
	call crlf

	mov  eax,(black)+(cyan*16);
	call setTextColor
	mwrite "Percentage of plagirism :"
	mov  eax,(yellow)+(black*16);
	call setTextColor
	mwrite " "
	mov eax , percentage
	call writedec
	mwrite "%"
	call crlf
	pop eax
	exit
	main ENDP

;<------------------------------------------------------------------------>
;<------------------------------------------------------------------------>
;<------------------------------------------------------------------------>
;<------------------------------------------------------------------------>

openingFile PROC , filename : dword
		mov edx , filename
		call OpenInputFile
		mov fileHandle,eax  
		mov edx,OFFSET buffer	;Read the file into a buffer.
		mov ecx,BUFFER_SIZE2
		call ReadFromFile
		mov buffer[eax],0		; insert null terminator
		mov ebx , eax; saving filesize
		call writedec
		cmp ebx , 300
		jl l1
		cld
		mov esi , offset buffer
		mov edi , offset target
		mov ecx , ebx
		rep movsb
		mov target[ebx] , " "
		mov target[ebx+1] , 0
		jmp lexit
		l1:
		cld
		mov esi , offset buffer
		mov edi , offset source
		mov ecx , ebx
		rep movsb
		mov target[ebx] , " "
		mov source[ebx+1] , 0
	lexit:
	mov eax,fileHandle
	call CloseFile
	ret
openingFile ENDP

;<------------------------------------------------------------------------>
;<------------------------------------------------------------------------>
;<------------------------------------------------------------------------>
;<------------------------------------------------------------------------>

tokenize PROC uses ecx eax ebx esi edi edx, 
	targetOffset:DWORD,
	lengthTarget:DWORD,
	tokenOffset:DWORD,
	index:DWORD

	;-----CODE START-----;

	mov esi,targetOffset
	mov edi,tokenOffset
	mov ecx,lengthTarget
	mov ebx,0			;acts as count to compare with index.
	mov eax,0 

	L1:
		mov dl,[esi]
		cmp dl,32
		JE checkIndex
		mov [edi],dl
		inc edi
		inc esi
		inc eax
		jmp toloop

		;-----CHECKS to make sure we have the required word-----;

		checkIndex:
			cmp ebx,index
			JE returnword
			add ebx,1

			INVOKE clearTokenArray,tokenOffset,lengthTarget			;-----Clears Previous word.
			mov edi, tokenOffset
			inc esi
			mov eax,0

toloop:	mov tokenlen,eax
		loop L1

returnword:	ret
tokenize ENDP

;<------------------------------------------------------------------------>
;<------------------------------------------------------------------------>
;<------------------------------------------------------------------------>
;<------------------------------------------------------------------------>

clearTokenArray PROC USES edi esi ecx eax ebx edx,
	toeknoffset:DWORD,
	lengthofToken:DWORD

	cld
	mov ecx, lengthofToken
	mov edi, toeknoffset
	mov eax,0
	rep stosb

	ret
clearTokenArray ENDP

;<------------------------------------------------------------------------>
;<------------------------------------------------------------------------>
;<------------------------------------------------------------------------>
;<------------------------------------------------------------------------>

CalculateforLoop PROC USES edx eax ebx edx,
	targetOffset:DWORD,
	lengthTarget:DWORD

	mov esi, targetOffset
	mov ecx, lengthTarget
	mov eax,0

	L1:
	mov dl,[esi]
	cmp dl,32
	JNE increment
	add eax,1
increment: add esi,1

	loop L1

	mov forloopCount,eax

	ret
CalculateforLoop ENDP

;<------------------------------------------------------------------------>
;<------------------------------------------------------------------------>
;<------------------------------------------------------------------------>
;<------------------------------------------------------------------------>

Str_concat PROC USES eax ebx ecx esi edi edx, tokenn : DWORD , matchedstringg : DWORD , lengthoftoken : DWORD , prevtokenlength : DWORD
	mov esi,tokenn
	mov ecx,lengthoftoken
	mov edi,matchedstringg

	L1:
		mov al,0
		cmp [edi],al
		JE lexit
		inc edi
	jmp L1

	lexit:
		mov al,32
		mov [edi],al
		inc edi
		L2:
			mov al,[esi]
			mov [edi],al
			inc esi
			inc edi
			inc ebx
		loop L2
	ret
Str_concat ENDP

;<------------------------------------------------------------------------>
;<------------------------------------------------------------------------>
;<------------------------------------------------------------------------>
;<------------------------------------------------------------------------>

ClearSpecialCharacters PROC USES ECX ESI, 
		stringRecieved:DWORD, character:BYTE, stringLength:DWORD

		mov esi , stringRecieved
		mov ecx , stringLength
		mov dl , character

		L1:
			cmp [esi],	dl
			JNE moveAhead

			L2:
			mov al,[esi+1]
			mov [esi],al
			inc esi
			loop L2
			jmp return

			moveAhead:	inc esi

		loop L1
return:		ret
	ClearSpecialCharacters ENDP


END MAIN