'======================================================================='

' Title: LCD Display Clock * DS1307
' Last Updated :  04.2022
' Author : A.Hossein.Khalilian
' Program code  : BASCOM-AVR 2.0.8.5
' Hardware req. : Atmega8 + DS1307 + 16x2 Character lcd display

'======================================================================='

$regfile = "m8def.dat"
$crystal = 1000000

Config Lcd = 16 * 2
Config Lcdpin = Pin , Rs = Pind.0 , E = Pind.1 , Db4 = Pind.2 , Db5 = Pind.3 , Db6 = Pind.4 , Db7 = Pind.5
Cls

$lib "ds1307clock.lib"
'configure the scl and sda pins
Config Sda = Portd.7
Config Scl = Portd.6
'address of ds1307
Const Ds1307w = &HD0                                        ' Addresses of Ds1307 clock
Const Ds1307r = &HD1

Config Pinc.1 = Input
Config Pinc.2 = Input
Config Pinc.3 = Input
Config Pinc.4 = Input

Config Debounce = 30

Dim Seco As Byte
Dim Mine As Byte
Dim Hour As Byte
Cursor off
'-----------------------------------------------------------

Main:

Do

Gosub Ds1307
Gosub 24_12
Gosub Chekkey

Loop
end

'-----------------------------------------------------------

Ds1307:
        I2cstart                                            ' Generate start code
        I2cwbyte Ds1307w                                    ' send address
        I2cwbyte 0                                          ' start address in 1307
        I2cstart                                            ' Generate start code
        I2cwbyte Ds1307r                                    ' send address
        I2crbyte Seco , Ack                                 'sec
        I2crbyte Mine , Ack                                 ' MINUTES
        I2crbyte Hour , Nack                                ' Hours
        I2cstop

        Seco = Makedec(seco) : Mine = Makedec(mine) : Hour = Makedec(hour)

        If Seco > 59 Then Seco = 0
        If Mine > 59 Then Mine = 0
        If Hour > 23 Then
        Hour = 0
        Gosub Seco_s
        End If

Return

''''''''''''''''''''''''''''''

 24_12:
 If Pinc.4 = 1 Then Gosub Disply_24
 If Pinc.4 = 0 Then Gosub Disply_12
 Return

''''''''''''''''''''''''''''''

Disply_24:

         Locate 1 , 1
         Lcd "Time = " ; Hour ; ":" ; Mine ; ":" ; Seco ; "      "
         Locate 2 , 6
         Lcd "(24)"
Return

''''''''''''''''''''''''''''''

Disply_12:

         If Hour = 0 Then Hour = 12
         If Hour > 12 Then Hour = Hour - 12

         Locate 1 , 1
         Lcd "Time = " ; Hour ; ":" ; Mine ; ":" ; Seco ; "      "
         Locate 2 , 6
         Lcd "(12)"
Return

''''''''''''''''''''''''''''''

Chekkey:

         Debounce Pinc.1 , 0 , Seco_s  , Sub
         Debounce Pinc.2 , 0 , Mine_s  , Sub
         Debounce Pinc.3 , 0 , Hour_s  , Sub


Return

''''''''''''''''''''''''''''''

Seco_s:
         Incr Seco
         If Seco > 59 Then Seco = 0
         Seco = Makebcd(seco)
         I2cstart                                           ' Generate start code
         I2cwbyte Ds1307w                                   ' send address
         I2cwbyte 0                                         ' starting address in 1307
         I2cwbyte Seco
         I2cstop
Return

''''''''''''''''''''''''''''''

Mine_s:
         Incr Mine
         If Mine > 59 Then Mine = 0
         Mine = Makebcd(mine)
         I2cstart                                           ' Generate start code
         I2cwbyte Ds1307w                                   ' send address
         I2cwbyte 1                                         ' starting address in 1307
         I2cwbyte Mine
         I2cstop
Return

''''''''''''''''''''''''''''''

Hour_s:
         Incr Hour
         If Hour > 23 Then Hour = 0
         Hour = Makebcd(hour)
         I2cstart                                           ' Generate start code
         I2cwbyte Ds1307w                                   ' send address
         I2cwbyte 2                                         ' starting address in 1307
         I2cwbyte Hour
         I2cstop

Return

'-----------------------------------------------------------
