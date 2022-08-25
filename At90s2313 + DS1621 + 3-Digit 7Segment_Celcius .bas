'======================================================================='

' Title: 3-Digit 7Segment LED Thermometer DS1621
' Last Updated :  05.2022
' Author : A.Hossein.Khalilian
' Program code  : BASCOM-AVR 2.0.8.5
' Hardware req. : At90s2313 + DS1621 + 3-Digit 7Segment

'======================================================================='

$crystal=1000000

Config Portb = Output
Config Pind.4 = Output
Config Pind.5 = Output
Config Pind.6 = Output
Config Sda = Portd.1
Config Scl = Portd.0

Dim D As Byte
Dim N As Byte
Dim  W As Byte
Dim Teller As Word
Dim Tempmsb As Byte
Dim Templsb As Byte
Dim Nneg As Byte
Dim Alarmtemp As Byte

Const Digit1 = &B01000000
Const Digit2 = &B00100000
Const Digit3 = &B00010000

Declare Sub Cpos(number As Byte)
Declare Sub Cneg(number As Byte)
Declare Sub Cover
Declare Sub Readtemp(tempmsb As Byte)
Declare Sub Startconvert()

Alarmtemp = 30

Call Startconvert
Waitms 1000

'--------------------------------------------------
Do
Call Readtemp(tempmsb)
Tempmsb = Tempmsb - 3

For Teller = 1 To 250
Select Case Tempmsb
Case 0 To 99 : Call Cpos(tempmsb)                           'temp >0 show temp on display
Case 100 To 127 : Call Cover                                'temp > 99.5 show -- on display
Case 128 To 245 : Call Cover                                'temp < -9.5 show -- on dsiplay
Case 246 To 255 : Call Cneg(tempmsb)                        'temp <0 show temp on displa
End Select
Next Teller
Loop
end
'-------------------------------------------------

Sub Startconvert()
I2cstart
I2cwbyte &H90
I2cwbyte &HEE
I2cstop
End Sub

''''''''''''''''''''''''''''''''''''

Sub Readtemp(tempmsb As Byte)
I2cstart
I2cwbyte &H90                                               'send adress byte
I2cwbyte &HAA                                               'send register byte
I2cstop

I2cstart
I2cwbyte &H91                                               'read register
I2crbyte Tempmsb , Ack
I2crbyte Templsb , Nack
I2cstop
End Sub Readtemp

'''''''''''''''''''''''''''''''''''

Sub Cpos(number)

   If Templsb = 0 Then
      N = 0
      Else
      N = 5
   End If

   D = Lookup(n , Digits)
   Portd = Digit1
   Portb = D
   Waitms 5

   N = Number Mod 10
   D = Lookup(n , Digits)
   Portd = Digit2
   Portb = D + 128
   Waitms 5

   N = Number \ 10
   D = Lookup(n , Digits)
   Portd = Digit3

   If N < 1 Then
      Portb = 0
      Else
      Portb = D
   End If
   Waitms 5

Portd = 0

If Tempmsb > Alarmtemp Then
For W = 1 To 10
Waitms 15
Next W
End If

End Sub

'''''''''''''''''''''''''''''''''''''

Sub Cneg(number)

Nneg = 0 - Number

Nneg = Nneg - 1

If Templsb = 0 Then N = 5 Else N = 0                        'If Templsb = 0 Then N = 0 Else N = 5
D = Lookup(n , Digits)
Portd = Digit1
Portb = D
Waitms 5

N = Nneg Mod 10
D = Lookup(n , Digits)
Portd = Digit2
Portb = D + 128
Waitms 5

N = 10
D = Lookup(n , Digits)
Portd = Digit3
Portb = D
Waitms 5

End Sub Cneg(number As Byte)

''''''''''''''''''''''''''''''''''''''''''

Sub Cover
N = 10
D = Lookup(n , Digits)
Portd = Digit1
Portb = D
Waitms 5

N = 10
D = Lookup(n , Digits)
Portd = Digit2
Portb = D
Waitms 5

N = 10
D = Lookup(n , Digits)
Portd = Digit3
Portb = D
Waitms 5

End Sub
End
'----------------------------------------------------------
'------------------------- Data ---------------------------
Digits:
Data 63 , 6 , 91 , 79 , 102 , 109 , 125 , 7 , 127 , 111 , 64 , 128 , 56 , 70
'     0    1   2    3    4     5     6     7   8     9     -    dp    L    +
'-----------------------------------------------------------