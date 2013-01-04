VIProductVersion              "1.0.0.0" ; set version here
VIAddVersionKey "FileVersion" "1.0.0.0" ; and here!
VIAddVersionKey "CompanyName" "peek.org.uk"
VIAddVersionKey "LegalCopyright" "© peek.org.uk 2012"
VIAddVersionKey "FileDescription" "SqlToGraphite installer"
OutFile SqlToGraphite-Setup.exe
RequestExecutionLevel admin

!include FileFunc.nsh
!insertmacro GetParameters
!insertmacro GetOptions

# uncomment the following line to make the installer silent by default.
;SilentInstall silent

Function StrStr
  Exch $1 ; st=haystack,old$1, $1=needle
  Exch    ; st=old$1,haystack
  Exch $2 ; st=old$1,old$2, $2=haystack
  Push $3
  Push $4
  Push $5
  StrLen $3 $1
  StrCpy $4 0
  ; $1=needle
  ; $2=haystack
  ; $3=len(needle)
  ; $4=cnt
  ; $5=tmp
  loop:
    StrCpy $5 $2 $3 $4
    StrCmp $5 $1 done
    StrCmp $5 "" done
    IntOp $4 $4 + 1
    Goto loop
  done:
  StrCpy $1 $2 "" $4
  Pop $5
  Pop $4
  Pop $3
  Pop $2
  Exch $1
FunctionEnd

Function GetParameters
  Push $0
  Push $1
  Push $2
  StrCpy $0 $CMDLINE 1
  StrCpy $1 '"'
  StrCpy $2 1
  StrCmp $0 '"' loop
    StrCpy $1 ' ' ; we're scanning for a space instead of a quote
  loop:
    StrCpy $0 $CMDLINE 1 $2
    StrCmp $0 $1 loop2
    StrCmp $0 "" loop2
    IntOp $2 $2 + 1
    Goto loop
  loop2:
    IntOp $2 $2 + 1
    StrCpy $0 $CMDLINE 1 $2
    StrCmp $0 " " loop2
  StrCpy $0 $CMDLINE "" $2
  Pop $2
  Pop $1
  Exch $0
FunctionEnd

; GetParameterValue
; Chris Morgan<cmorgan@alum.wpi.edu> 5/10/2004
; -Updated 4/7/2005 to add support for retrieving a command line switch
;  and additional documentation
;
; Searches the command line input, retrieved using GetParameters, for the
; value of an option given the option name.  If no option is found the
; default value is placed on the top of the stack upon function return.
;
; This function can also be used to detect the existence of just a
; command line switch like /OUTPUT  Pass the default and "OUTPUT"
; on the stack like normal.  An empty return string "" will indicate
; that the switch was found, the default value indicates that
; neither a parameter or switch was found.
;
; Inputs - Top of stack is default if parameter isn't found,
;  second in stack is parameter to search for, ex. "OUTPUT"
; Outputs - Top of the stack contains the value of this parameter
;  So if the command line contained /OUTPUT=somedirectory, "somedirectory"
;  will be on the top of the stack when this function returns
;
; Register usage
;$R0 - default return value if the parameter isn't found
;$R1 - input parameter, for example OUTPUT from the above example
;$R2 - the length of the search, this is the search parameter+2
;      as we have '/OUTPUT='
;$R3 - the command line string
;$R4 - result from StrStr calls
;$R5 - search for ' ' or '"'
 
Function GetParameterValue
  Exch $R0  ; get the top of the stack(default parameter) into R0
  Exch      ; exchange the top of the stack(default) with
            ; the second in the stack(parameter to search for)
  Exch $R1  ; get the top of the stack(search parameter) into $R1
 
  ;Preserve on the stack the registers used in this function
  Push $R2
  Push $R3
  Push $R4
  Push $R5
 
  Strlen $R2 $R1+2    ; store the length of the search string into R2
 
  Call GetParameters  ; get the command line parameters
  Pop $R3             ; store the command line string in R3
 
  # search for quoted search string
  StrCpy $R5 '"'      ; later on we want to search for a open quote
  Push $R3            ; push the 'search in' string onto the stack
  Push '"/$R1='       ; push the 'search for'
  Call StrStr         ; search for the quoted parameter value
  Pop $R4
  StrCpy $R4 $R4 "" 1   ; skip over open quote character, "" means no maxlen
  StrCmp $R4 "" "" next ; if we didn't find an empty string go to next
 
  # search for non-quoted search string
  StrCpy $R5 ' '      ; later on we want to search for a space since we
                      ; didn't start with an open quote '"' we shouldn't
                      ; look for a close quote '"'
  Push $R3            ; push the command line back on the stack for searching
  Push '/$R1='        ; search for the non-quoted search string
  Call StrStr
  Pop $R4
 
  ; $R4 now contains the parameter string starting at the search string,
  ; if it was found
next:
  StrCmp $R4 "" check_for_switch ; if we didn't find anything then look for
                                 ; usage as a command line switch
  # copy the value after /$R1= by using StrCpy with an offset of $R2,
  # the length of '/OUTPUT='
  StrCpy $R0 $R4 "" $R2  ; copy commandline text beyond parameter into $R0
  # search for the next parameter so we can trim this extra text off
  Push $R0
  Push $R5            ; search for either the first space ' ', or the first
                      ; quote '"'
                      ; if we found '"/output' then we want to find the
                      ; ending ", as in '"/output=somevalue"'
                      ; if we found '/output' then we want to find the first
                      ; space after '/output=somevalue'
  Call StrStr         ; search for the next parameter
  Pop $R4
  StrCmp $R4 "" done  ; if 'somevalue' is missing, we are done
  StrLen $R4 $R4      ; get the length of 'somevalue' so we can copy this
                      ; text into our output buffer
  StrCpy $R0 $R0 -$R4 ; using the length of the string beyond the value,
                      ; copy only the value into $R0
  goto done           ; if we are in the parameter retrieval path skip over
                      ; the check for a command line switch
 
; See if the parameter was specified as a command line switch, like '/output'
check_for_switch:
  Push $R3            ; push the command line back on the stack for searching
  Push '/$R1'         ; search for the non-quoted search string
  Call StrStr
  Pop $R4
  StrCmp $R4 "" done  ; if we didn't find anything then use the default
  StrCpy $R0 ""       ; otherwise copy in an empty string since we found the
                      ; parameter, just didn't find a value
 
done:
  Pop $R5
  Pop $R4
  Pop $R3
  Pop $R2
  Pop $R1
  Exch $R0 ; put the value in $R0 at the top of the stack
FunctionEnd



Section Main    
    SetOutPath $PROGRAMFILES\SqlToGraphite
    SetOverwrite on    
	; Check to see if already installed
	ClearErrors
	ReadRegStr $0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SqlToGraphite" ""	
	IfErrors 0 +2
		DetailPrint "Installed aleady"
		ExecWait '"$OUTDIR\uninstall.exe " _?=$OUTDIR /s '		
			
	DetailPrint "Now installing"				
		File /r output\*.*
		WriteUninstaller $OUTDIR\uninstall.exe  
    
		WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SqlToGraphite" \
                 "DisplayName" "SqlToGraphite record metrics in graphite"
		WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SqlToGraphite" \
                 "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
		
		Push "HOSTNAME"   ; push the search string onto the stack
		Push "metrics"   ; push a default value onto the stack
		Call GetParameterValue
		Pop $2
		Var /GLOBAL hostname 
		StrCpy $hostname "hostname=$2" 
		DetailPrint "Value of hostname parameter is '$hostname'"

		Push "USERNAME"   
		Push ""   
		Call GetParameterValue
		Pop $2
		Var /GLOBAL username 
		StrCpy $username "username=$2" 
		DetailPrint "Value of username parameter is '$username'"

		Push "PASSWORD"   
		Push ""   
		Call GetParameterValue
		Pop $2
		Var /GLOBAL password 
		StrCpy $password "password=$2" 
		DetailPrint "Value of password parameter is '$password'"

		Push "CONFIGUPDATE"   
		Push "15"   
		Call GetParameterValue
		Pop $2
		Var /GLOBAL configupdate 
		StrCpy $configupdate "configupdate=$2" 
		DetailPrint "Value of configupdate parameter is '$configupdate'"

		Push "CONFIGRETRY"   
		Push "15"   
		Call GetParameterValue
		Pop $2
		Var /GLOBAL configRetry 
		StrCpy $configRetry "configRetry=$2" 
		DetailPrint "Value of configRetry parameter is '$configRetry'"

		Push "CACHELENGTH"   
		Push "15"   
		Call GetParameterValue
		Pop $2
		Var /GLOBAL cachelength 
		StrCpy $cachelength "cachelength=$2" 
		DetailPrint "Value of cachelength parameter is '$cachelength'"

		Push "CONFIGURI"   
		Push "http://metrics/svn/config.xml"   
		Call GetParameterValue
		Pop $2
		Var /GLOBAL configuri 
		StrCpy $configuri "configuri=$2" 
		DetailPrint "Value of configuri parameter is '$configuri'"

		Push "PATH"   
		Push "$OUTDIR\sqltographite.exe.config"   
		Call GetParameterValue
		Pop $2
		Var /GLOBAL path 
		StrCpy $path "path=$2" 
		DetailPrint "Value of path parameter is '$path'"


		DetailPrint '"$OUTDIR\ConfigPatcher.exe" $hostname $username $password $configuri $cachelength $configretry $configupdate "$path"'
		ExecWait '"$OUTDIR\ConfigPatcher.exe" $hostname $username $password $configuri $cachelength $configretry $configupdate "$path"' $0

		ExecWait '"$OUTDIR\sqltographite.host.exe" install' $0
		DetailPrint "Returned $0"
		ExecWait '"Net" start SqlToGraphite' $0
		DetailPrint "Returned $0"
SectionEnd

Section "Uninstall"  
  ExecWait '"Net" stop SqlToGraphite' $0
  DetailPrint "Returned $0"
  ExecWait '"taskkill" /f /IM sqltographite.exe' $0
  DetailPrint "Returned $0"  
  ExecWait '"$INSTDIR\sqltographite.exe" uninstall'
  Delete $INSTDIR\*.exe
  Delete $INSTDIR\*.dll
  Delete $INSTDIR\*.exe.config
  Delete $INSTDIR\*.xml
  RMDir $INSTDIR\logs
  Delete $INSTDIR\uninstall.exe ; delete self (see explanation below why this works)
  RMDir $INSTDIR  
  Quit  
SectionEnd

