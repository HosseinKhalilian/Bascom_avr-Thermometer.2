'======================================================================='

' Title: 3-Digit 7Segment LED Thermometer DS1621
' Last Updated :  05.2022
' Author : A.Hossein.Khalilian
' Program code  : BASCOM-AVR 2.0.8.5
' Hardware req. : At90s2313 + DS1621 + 3-Digit 7Segment

'======================================================================='

$crystal = 10000000

Config Portb = Output
Config Pind.4 = Output
Config Pind.5 = Output
Config Pind.6 = Output

Config Sda = Portd.1
Config Scl = Portd.0

Dim D As Byte
Dim N0 As Byte , N1 As Byte , N2 As Byte , N3 As Byte
Dim Teller As Word
Dim Tempmsb As Byte
Dim Templsb As Byte
Dim T As Single

Const Digit1 = &B01000000
Const Digit2 = &B00100000
Const Digit3 = &B00010000

Declare Sub Cpos(number As Byte)
Declare Sub Cover
Declare Sub Readtemp(tempmsb As Byte)
Declare Sub Startconvert()

Call Startconvert
Waitms 1000

'--------------------------------------------

Do
Call Readtemp(tempmsb)
Tempmsb = Tempmsb - 2

   If Tempmsb < 128 Then
      T = Tempmsb
      If Templsb > 0 Then T = T + 0.5
      T = T * 1.8
      T = T + 32
      Tempmsb = T

   Else
      T = Tempmsb
      T = T - 256
      If Templsb > 0 Then T = T + 0.5
      T = T * 1.8
      T = T + 32
      Tempmsb = T
   End If

    For Teller = 1 To 250

          Select Case Tempmsb
          Case 0 To 210 : Call Cpos(tempmsb)                'temp >0 show temp on display
          Case 210 To 255 : Call Cover
          End Select

    Next Teller

    If Tempmsb = 0 Or Tempmsb < 100 Then
    D = D + 1
    End If

Loop
end

'-------------------------------------------------

Sub Startconvert()
I2cstart
I2cwbyte &H90
I2cwbyte &HEE
I2cstop
End Sub

''''''''''''''''''''''''''''''''''''''''
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

''''''''''''''''''''''''''''''''''''''

Sub Cpos(number)

   If Number < 100 Then
          N1 = Number Mod 10
          D = Lookup(n1 , Digits)
          Portd = Digit1
          Portb = D
          Waitms 5

          N2 = Number \ 10
          D = Lookup(n2 , Digits)
          Portd = Digit2
          Portb = D
          Waitms 5

          Portd = Digit3
          Portb = 0
          Waitms 5
   Else
         N1 = Number Mod 10
         D = Lookup(n1 , Digits)
         Portd = Digit1
         Portb = D
         Waitms 5

         N2 = Number \ 10
         N2 = N2 Mod 10
         D = Lookup(n2 , Digits)
         Portd = Digit2
         Portb = D
         Waitms 5

         N3 = Number \ 100
         D = Lookup(n3 , Digits)
         Portd = Digit3
         Portb = D
         Waitms 5

         End If

Portd = 0

End Sub

'''''''''''''''''''''''''''''''''''''''''''''

Sub Cover
N0 = 10
D = Lookup(n0 , Digits)
Portd = &B01110000
Portb = D
Waitms 15

End Sub

'------------------------------------------------
'---------------- Data --------------------------
Digits:
Data 63 , 6 , 91 , 79 , 102 , 109 , 125 , 7 , 127 , 111 , 64
'     0    1   2    3    4     5     6     7   8     9     -
'------------------------------------------------