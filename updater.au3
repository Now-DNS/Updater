;Script for IP update when your public IP changes

#include <WinAPIFiles.au3>
#include <TrayConstants.au3>
#include <Base64.au3>

;handle errors
Global $oMyError = ObjEvent("AutoIt.Error","funcCatch")

;Ini file that holds your username and password hostname and frequency
$strIni = "Updater.ini"

;URL where I can get my public IP from
$strIpUrl = "https://now-ip.com/ip"

;URL where I can update my IP
$strUpdateUrl = "https://now-ip.com/update"

;Read in settings from the Ini File
funcReadIni()

;URL where I can update my IP
Global $strUpdateUrl = "https://now-ip.com/update?hostname=" & $strHostname

;Build the Basic Auth header
Global $strBasicAuthentication = _Base64Encode($strEmail & ":" & $strPass)

;Variable to hold current IP
Global $strCurrentIP = ""

;Loop for ever
While True

   Local $strIP = funcHttpGet($strIpUrl, False)
   if  $strIP == "FAIL" Then
		 sleep(1000)
		 ContinueLoop
   EndIf

   ;first Run better checkin
   if $strCurrentIp = "" Then
	  $strCurrentIP = $strIP
	  Local $strCode = funcHttpGet($strUpdateUrl, True)
   EndIf

   ;check if the public IP has changed since last check
   if $strCurrentIP == $strIP Then
   else
	  ;TrayTip("Updater", "Public IP change detected - " & $strIP, 0, $TIP_ICONASTERISK)
	  Local $strCode = funcHttpGet($strUpdateUrl, True)
	  $strCurrentIP = $strIP
   EndIf

   sleep($intSleep)

WEnd

Func funcHttpGet(ByRef $strUrl, $blnAuth = False)
   Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1")
   ;
   ;testing only, disable ssl validations
   ;$oHTTP.Option(4) = 0x3300 ;WinHttpRequestOption_SslErrorIgnoreFlags
   ;$oHTTP.Option(9) = 0x0080 ;WinHttpRequestOption_SecureProtocols
   ;
   $oHTTP.Open("GET", $strUrl, False)
   if $blnAuth Then
	  $oHTTP.SetRequestHeader ("Authorization", "Basic " & $strBasicAuthentication)
   EndIf

   $oHTTP.Send()

   $oReceived = $oHTTP.ResponseText
   $oStatusCode = $oHTTP.Status
   If $oStatusCode == 200 then
	  Return $oReceived
   EndIf

   Return "FAIL"

EndFunc


Func funcReadIni()

   ; Read the INI file for the hostname
   Global $strHostname = IniRead($strIni, "General", "Hostname", "fail.now-ip.com")
   Global $strEmail = IniRead($strIni, "General", "Email", "fail@now-ip.com")
   Global $strPass = IniRead($strIni, "General", "Password", "")
   Local $intFreq = IniRead($strIni, "General", "Frequency", 60)
   Global $intSleep = $intFreq * 1000

EndFunc

Func funcCatch()
   return "FAIL"
EndFunc

