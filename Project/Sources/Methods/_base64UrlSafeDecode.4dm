//%attributes = {"invisible":true}
/*
    Largely inspired by UTL_base64UrlSafeDecode.4dm 
    From blegay's acme_component here: https://github.com/blegay/acme_component
    
    MIT License
    
    Copyright (c) 2020 blegay
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
*/
#DECLARE($inBase64Encoded : Text) : Text

var $outDecodedString : Text

If (Asserted(Count parameters>0; "requires 1 parameter"))
    
    // replace the "\r" and "/n" we may find...
    $inBase64Encoded:=Replace string($inBase64Encoded; "\r"; ""; *)
    $inBase64Encoded:=Replace string($inBase64Encoded; "\n"; ""; *)
    
    $inBase64Encoded:=Replace string($inBase64Encoded; "_"; "/"; *)  // convert "_" to "/"
    $inBase64Encoded:=Replace string($inBase64Encoded; "-"; "+"; *)  // convert "-" to "+"
    
    // if the base64 encoded does not contain the padding characters ("="), lets add them
    // base64 encoded data should have a length multiple of 4
    var $padModulo : Integer
    $padModulo:=Mod(Length($inBase64Encoded); 4)
    If ($padModulo>0)
        $inBase64Encoded:=$inBase64Encoded+((4-$padModulo)*"=")
    End if 
    
    BASE64 DECODE($inBase64Encoded; $outDecodedString)  // decode to plain text
    
End if 

return $outDecodedString
