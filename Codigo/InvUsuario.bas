Attribute VB_Name = "InvUsuario"
'Argentum Online 0.12.2
'Copyright (C) 2002 Marquez Pablo Ignacio
'
'This program is free software; you can redistribute it and/or modify
'it under the terms of the Affero General Public License;
'either version 1 of the License, or any later version.
'
'This program is distributed in the hope that it will be useful,
'but WITHOUT ANY WARRANTY; without even the implied warranty of
'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'Affero General Public License for more details.
'
'You should have received a copy of the Affero General Public License
'along with this program; if not, you can find it at http://www.affero.org/oagpl.html
'
'Argentum Online is based on Baronsoft's VB6 Online RPG
'You can contact the original creator of ORE at aaron@baronsoft.com
'for more information about ORE please visit http://www.baronsoft.com/
'
'
'You can contact me at:
'morgolock@speedy.com.ar
'www.geocities.com/gmorgolock
'Calle 3 numero 983 piso 7 dto A
'La Plata - Pcia, Buenos Aires - Republica Argentina
'Codigo Postal 1900
'Pablo Ignacio Marquez

Option Explicit

Public Function TieneObjetosRobables(ByVal UserIndex As Integer) As Boolean
    '***************************************************
    'Author: Unknown
    'Last Modification: -
    ' 22/05/2010: Los items newbies ya no son robables.
    '***************************************************

    '17/09/02
    'Agregue que la funcion se asegure que el objeto no es un barco

    On Error GoTo errHandler

    Dim i        As Integer

    Dim ObjIndex As Integer
    
    For i = 1 To UserList(UserIndex).CurrentInventorySlots
        ObjIndex = UserList(UserIndex).Invent.Object(i).ObjIndex

        If ObjIndex > 0 Then
            If (ObjData(ObjIndex).OBJType <> eOBJType.otLlaves And ObjData(ObjIndex).OBJType <> eOBJType.otBarcos And Not ItemNewbie(ObjIndex)) Then
                TieneObjetosRobables = True
                Exit Function

            End If

        End If

    Next i
    
    Exit Function

errHandler:
    Call LogError("Error en TieneObjetosRobables. Error: " & Err.Number & " - " & Err.description)

End Function

Function ClasePuedeUsarItem(ByVal UserIndex As Integer, _
                            ByVal ObjIndex As Integer, _
                            Optional ByRef sMotivo As String) As Boolean
    '***************************************************
    'Author: Unknown
    'Last Modification: 01/04/2019
    '14/01/2010: ZaMa - Agrego el motivo por el que no puede equipar/usar el item.
    '08/08/2015: Shak - Hechizos por clase
    '01/04/2019: Recox - Se arreglo la prohibicion de hechizos por clase
    '***************************************************

    On Error GoTo manejador
  
    'Admins can use ANYTHING!
    If UserList(UserIndex).flags.Privilegios And PlayerType.User Then
        If ObjData(ObjIndex).ClaseProhibida(1) <> 0 Then

            Dim i As Integer

            For i = 1 To NUMCLASES

                If ObjData(ObjIndex).ClaseProhibida(i) = UserList(UserIndex).clase Then
              
                    '//Si es un hechizo
                    If ObjData(ObjIndex).OBJType = eOBJType.otPergaminos Then
                        sMotivo = "Tu clase no tiene la habilidad de aprender este hechizo."
                        ClasePuedeUsarItem = False
                        Exit Function
                    Else
                        sMotivo = "Tu clase no puede usar este objeto."
                        ClasePuedeUsarItem = False
                        Exit Function
                    End If

                End If
                
            Next i

        End If

    End If
  
    ClasePuedeUsarItem = True

    Exit Function

manejador:
    LogError ("Error en ClasePuedeUsarItem")

End Function

Sub QuitarNewbieObj(ByVal UserIndex As Integer)
    '***************************************************
    'Author: Unknown
    'Last Modification: -
    '
    '***************************************************

    Dim j As Integer

    With UserList(UserIndex)

        For j = 1 To UserList(UserIndex).CurrentInventorySlots

            If .Invent.Object(j).ObjIndex > 0 Then
             
                If ObjData(.Invent.Object(j).ObjIndex).Newbie = 1 Then Call QuitarUserInvItem(UserIndex, j, MAX_INVENTORY_OBJS)
                Call UpdateUserInv(False, UserIndex, j)
        
            End If

        Next j
    
        '[Barrin 17-12-03] Si el usuario dejo de ser Newbie, y estaba en el Newbie Dungeon
        'es transportado a su hogar de origen ;)
        If MapInfo(.Pos.Map).Restringir = eRestrict.restrict_newbie Then
        
            Dim DeDonde As WorldPos
        
            Select Case .Hogar

                Case eCiudad.cLindos 'Vamos a tener que ir por todo el desierto... uff!
                    DeDonde = Lindos

                Case eCiudad.cUllathorpe
                    DeDonde = Ullathorpe

                Case eCiudad.cBanderbill
                    DeDonde = Banderbill

                Case Else
                    DeDonde = Nix

            End Select
        
            Call WarpUserChar(UserIndex, DeDonde.Map, DeDonde.x, DeDonde.y, True)
    
        End If

        '[/Barrin]
    End With

End Sub

Sub LimpiarInventario(ByVal UserIndex As Integer)
    '***************************************************
    'Author: Unknown
    'Last Modification: -
    '
    '***************************************************

    Dim j As Integer

    With UserList(UserIndex)

        For j = 1 To .CurrentInventorySlots
            .Invent.Object(j).ObjIndex = 0
            .Invent.Object(j).Amount = 0
            .Invent.Object(j).Equipped = 0
        Next j
    
        .Invent.NroItems = 0
    
        .Invent.ArmourEqpObjIndex = 0
        .Invent.ArmourEqpSlot = 0
    
        .Invent.WeaponEqpObjIndex = 0
        .Invent.WeaponEqpSlot = 0
    
        .Invent.CascoEqpObjIndex = 0
        .Invent.CascoEqpSlot = 0
    
        .Invent.EscudoEqpObjIndex = 0
        .Invent.EscudoEqpSlot = 0
    
        .Invent.AnilloEqpObjIndex = 0
        .Invent.AnilloEqpSlot = 0
    
        .Invent.MunicionEqpObjIndex = 0
        .Invent.MunicionEqpSlot = 0
    
        .Invent.BarcoObjIndex = 0
        .Invent.BarcoSlot = 0
    
        .Invent.MochilaEqpObjIndex = 0
        .Invent.MochilaEqpSlot = 0

    End With

End Sub

Sub TirarOro(ByVal Cantidad As Long, ByVal UserIndex As Integer)

    '***************************************************
    'Autor: Unknown (orginal version)
    'Last Modification: 23/01/2007
    '23/01/2007 -> Pablo (ToxicWaste): Billetera invertida y explotar oro en el agua.
    '***************************************************
    On Error GoTo errHandler

    'If Cantidad > 100000 Then Exit Sub

    With UserList(UserIndex)

        'SI EL Pjta TIENE ORO LO TIRAMOS
        If (Cantidad > 0) And (Cantidad <= .Stats.Gld) Then

            Dim MiObj As Obj

            'info debug
            Dim loops As Integer
            
            'Seguridad Alkon (guardo el oro tirado si supera los 50k)
            If Cantidad > 50000 Then

                Dim j        As Integer

                Dim K        As Integer

                Dim M        As Integer

                Dim Cercanos As String

                M = .Pos.Map

                For j = .Pos.x - 10 To .Pos.x + 10
                    For K = .Pos.y - 10 To .Pos.y + 10

                        If InMapBounds(M, j, K) Then
                            If MapData(M, j, K).UserIndex > 0 Then
                                Cercanos = Cercanos & UserList(MapData(M, j, K).UserIndex).Name & ","

                            End If

                        End If

                    Next K
                Next j

                Call LogDesarrollo(.Name & " tira oro. Cercanos: " & Cercanos)

            End If

            '/Seguridad
            Dim Extra    As Long

            Dim TeniaOro As Long

            TeniaOro = .Stats.Gld

            If Cantidad > 500000 Then 'Para evitar explotar demasiado
                Extra = Cantidad - 500000
                Cantidad = 500000

            End If
            
            Do While (Cantidad > 0)
                
                If Cantidad > MAX_INVENTORY_OBJS And .Stats.Gld > MAX_INVENTORY_OBJS Then
                    MiObj.Amount = MAX_INVENTORY_OBJS
                    Cantidad = Cantidad - MiObj.Amount
                Else
                    MiObj.Amount = Cantidad
                    Cantidad = Cantidad - MiObj.Amount

                End If
    
                MiObj.ObjIndex = iORO
                
                If EsGm(UserIndex) Then Call LogGM(.Name, "Tiro cantidad:" & MiObj.Amount & " Objeto:" & ObjData(MiObj.ObjIndex).Name)

                Dim AuxPos As WorldPos
                
                If .clase = eClass.Pirat And .Invent.BarcoObjIndex = 476 Then
                    AuxPos = TirarItemAlPiso(.Pos, MiObj, False)

                    If AuxPos.x <> 0 And AuxPos.y <> 0 Then
                        .Stats.Gld = .Stats.Gld - MiObj.Amount

                    End If

                Else
                    AuxPos = TirarItemAlPiso(.Pos, MiObj, True)

                    If AuxPos.x <> 0 And AuxPos.y <> 0 Then
                        .Stats.Gld = .Stats.Gld - MiObj.Amount

                    End If

                End If
                
                'info debug
                loops = loops + 1

                If loops > 100 Then
                    LogError ("Error en tiraroro")
                    Exit Sub

                End If
                
            Loop

            If TeniaOro = .Stats.Gld Then Extra = 0
            If Extra > 0 Then
                .Stats.Gld = .Stats.Gld - Extra

            End If
        
        End If

    End With

    Exit Sub

errHandler:
    Call LogError("Error en TirarOro. Error " & Err.Number & " : " & Err.description)

End Sub

Sub QuitarUserInvItem(ByVal UserIndex As Integer, _
                      ByVal Slot As Byte, _
                      ByVal Cantidad As Integer)
    '***************************************************
    'Author: Unknown
    'Last Modification: -
    '
    '***************************************************

    On Error GoTo errHandler

    If Slot < 1 Or Slot > UserList(UserIndex).CurrentInventorySlots Then Exit Sub
    
    With UserList(UserIndex).Invent.Object(Slot)

        If .Amount <= Cantidad And .Equipped = 1 Then
            Call Desequipar(UserIndex, Slot)

        End If
        
        'Quita un objeto
        .Amount = .Amount - Cantidad

        'Quedan mas?
        If .Amount <= 0 Then
            UserList(UserIndex).Invent.NroItems = UserList(UserIndex).Invent.NroItems - 1
            .ObjIndex = 0
            .Amount = 0

        End If

    End With

    Exit Sub

errHandler:
    Call LogError("Error en QuitarUserInvItem. Error " & Err.Number & " : " & Err.description)
    
End Sub

Sub UpdateUserInv(ByVal UpdateAll As Boolean, _
                  ByVal UserIndex As Integer, _
                  ByVal Slot As Byte)
    '***************************************************
    'Author: Unknown
    'Last Modification: -
    '
    '***************************************************

    On Error GoTo errHandler

    Dim NullObj As UserObj

    Dim LoopC   As Long

    With UserList(UserIndex)

        'Actualiza un solo slot
        If Not UpdateAll Then
    
            'Actualiza el inventario
            If .Invent.Object(Slot).ObjIndex > 0 Then
                Call ChangeUserInv(UserIndex, Slot, .Invent.Object(Slot))
            Else
                Call ChangeUserInv(UserIndex, Slot, NullObj)

            End If
    
        Else
    
            'Actualiza todos los slots
            For LoopC = 1 To .CurrentInventorySlots

                'Actualiza el inventario
                If .Invent.Object(LoopC).ObjIndex > 0 Then
                    Call ChangeUserInv(UserIndex, LoopC, .Invent.Object(LoopC))
                Else
                    Call ChangeUserInv(UserIndex, LoopC, NullObj)

                End If

            Next LoopC

        End If
    
        Exit Sub

    End With

errHandler:
    Call LogError("Error en UpdateUserInv. Error " & Err.Number & " : " & Err.description)

End Sub

Sub DropObj(ByVal UserIndex As Integer, _
            ByVal Slot As Byte, _
            ByVal Num As Integer, _
            ByVal Map As Integer, _
            ByVal x As Integer, _
            ByVal y As Integer)
    '***************************************************
    'Author: Unknown
    'Last Modification: 11/5/2010
    '11/5/2010 - ZaMa: Arreglo bug que permitia apilar mas de 10k de items.
    '***************************************************

    Dim DropObj As Obj

    Dim MapObj  As Obj

    With UserList(UserIndex)

        If Num > 0 Then
        
            DropObj.ObjIndex = .Invent.Object(Slot).ObjIndex
        
            If (ItemNewbie(DropObj.ObjIndex) And (.flags.Privilegios And PlayerType.User)) Then
                Call WriteConsoleMsg(UserIndex, "No puedes tirar objetos newbie.", FontTypeNames.FONTTYPE_INFO)
                Exit Sub

            End If
        
            DropObj.Amount = MinimoInt(Num, .Invent.Object(Slot).Amount)

            'Check objeto en el suelo
            MapObj.ObjIndex = MapData(.Pos.Map, x, y).ObjInfo.ObjIndex
            MapObj.Amount = MapData(.Pos.Map, x, y).ObjInfo.Amount
        
            If MapObj.ObjIndex = 0 Or MapObj.ObjIndex = DropObj.ObjIndex Then
        
                If MapObj.Amount = MAX_INVENTORY_OBJS Then
                    Call WriteConsoleMsg(UserIndex, "No hay espacio en el piso.", FontTypeNames.FONTTYPE_INFO)
                    Exit Sub

                End If
            
                If DropObj.Amount + MapObj.Amount > MAX_INVENTORY_OBJS Then
                    DropObj.Amount = MAX_INVENTORY_OBJS - MapObj.Amount

                End If
            
                Call MakeObj(DropObj, Map, x, y)
                Call QuitarUserInvItem(UserIndex, Slot, DropObj.Amount)
                Call UpdateUserInv(False, UserIndex, Slot)
            
                If ObjData(DropObj.ObjIndex).OBJType = eOBJType.otBarcos Then
                    Call WriteConsoleMsg(UserIndex, "ATENCION!! ACABAS DE TIRAR TU BARCA!", FontTypeNames.FONTTYPE_TALK)

                End If
            
                If Not .flags.Privilegios And PlayerType.User Then Call LogGM(.Name, "Tiro cantidad:" & Num & " Objeto:" & ObjData(DropObj.ObjIndex).Name)
            
                'Log de Objetos que se tiran al piso. Pablo (ToxicWaste) 07/09/07
                'Es un Objeto que tenemos que loguear?
                If ObjData(DropObj.ObjIndex).Log = 1 Then
                    Call LogDesarrollo(.Name & " tiro al piso " & DropObj.Amount & " " & ObjData(DropObj.ObjIndex).Name & " Mapa: " & Map & " X: " & x & " Y: " & y)
                ElseIf DropObj.Amount > 5000 Then 'Es mucha cantidad? > Subi a 5000 el minimo porque si no se llenaba el log de cosas al pedo. (NicoNZ)

                    'Si no es de los prohibidos de loguear, lo logueamos.
                    If ObjData(DropObj.ObjIndex).NoLog <> 1 Then
                        Call LogDesarrollo(.Name & " tiro al piso " & DropObj.Amount & " " & ObjData(DropObj.ObjIndex).Name & " Mapa: " & Map & " X: " & x & " Y: " & y)

                    End If

                End If

            Else
                Call WriteConsoleMsg(UserIndex, "No hay espacio en el piso.", FontTypeNames.FONTTYPE_INFO)

            End If

        End If

    End With

End Sub

Sub EraseObj(ByVal Num As Integer, _
             ByVal Map As Integer, _
             ByVal x As Integer, _
             ByVal y As Integer)
    '***************************************************
    'Author: Unknown
    'Last Modification: -
    '
    '***************************************************

    With MapData(Map, x, y)
        .ObjInfo.Amount = .ObjInfo.Amount - Num
    
        If .ObjInfo.Amount <= 0 Then
            .ObjInfo.ObjIndex = 0
            .ObjInfo.Amount = 0
        
            Call modSendData.SendToAreaByPos(Map, x, y, PrepareMessageObjectDelete(x, y))

        End If

    End With

End Sub

Sub MakeObj(ByRef Obj As Obj, _
            ByVal Map As Integer, _
            ByVal x As Integer, _
            ByVal y As Integer)
    '***************************************************
    'Author: Unknown
    'Last Modification: -
    '
    '***************************************************
    
    If Obj.ObjIndex > 0 And Obj.ObjIndex <= UBound(ObjData) Then
    
        With MapData(Map, x, y)

            If .ObjInfo.ObjIndex = Obj.ObjIndex Then
                .ObjInfo.Amount = .ObjInfo.Amount + Obj.Amount
            Else
                .ObjInfo = Obj
                
                Call modSendData.SendToAreaByPos(Map, x, y, PrepareMessageObjectCreate(ObjData(Obj.ObjIndex).GrhIndex, x, y))

            End If
            
            '//Agregamos las pos de los objetos
            If ObjData(Obj.ObjIndex).OBJType <> otFogata And Not EsObjetoFijo(ObjData(Obj.ObjIndex).OBJType) Then

                Dim xPos As WorldPos

                xPos.Map = Map
                xPos.x = x
                xPos.y = y
                AgregarObjetoLimpieza xPos

            End If

        End With

    End If

End Sub

Function MeterItemEnInventario(ByVal UserIndex As Integer, ByRef MiObj As Obj) As Boolean
    '***************************************************
    'Author: Unknown
    'Last Modification: -
    '
    '***************************************************

    On Error GoTo errHandler

    Dim Slot As Byte
    
    With UserList(UserIndex)
        'el user ya tiene un objeto del mismo tipo?
        Slot = 1
        
        Do Until .Invent.Object(Slot).ObjIndex = MiObj.ObjIndex And .Invent.Object(Slot).Amount + MiObj.Amount <= MAX_INVENTORY_OBJS
            Slot = Slot + 1

            If Slot > .CurrentInventorySlots Then
                Exit Do

            End If

        Loop
            
        'Sino busca un slot vacio
        If Slot > .CurrentInventorySlots Then
            Slot = 1

            Do Until .Invent.Object(Slot).ObjIndex = 0
                Slot = Slot + 1

                If Slot > .CurrentInventorySlots Then
                    Call WriteConsoleMsg(UserIndex, "No puedes cargar mas objetos.", FontTypeNames.FONTTYPE_FIGHT)
                    MeterItemEnInventario = False
                    Exit Function

                End If

            Loop
            .Invent.NroItems = .Invent.NroItems + 1

        End If
    
        If Slot > MAX_NORMAL_INVENTORY_SLOTS And Slot <= MAX_INVENTORY_SLOTS Then
            If Not ItemSeCae(MiObj.ObjIndex) Then
                Call WriteConsoleMsg(UserIndex, "No puedes contener objetos especiales en tu " & ObjData(.Invent.MochilaEqpObjIndex).Name & ".", FontTypeNames.FONTTYPE_FIGHT)
                MeterItemEnInventario = False
                Exit Function

            End If

        End If

        'Mete el objeto
        If .Invent.Object(Slot).Amount + MiObj.Amount <= MAX_INVENTORY_OBJS Then
            'Menor que MAX_INV_OBJS
            .Invent.Object(Slot).ObjIndex = MiObj.ObjIndex
            .Invent.Object(Slot).Amount = .Invent.Object(Slot).Amount + MiObj.Amount
        Else
            .Invent.Object(Slot).Amount = MAX_INVENTORY_OBJS

        End If

    End With
    
    MeterItemEnInventario = True
           
    Call UpdateUserInv(False, UserIndex, Slot)
    
    Exit Function
errHandler:
    Call LogError("Error en MeterItemEnInventario. Error " & Err.Number & " : " & Err.description)

End Function

Sub GetObj(ByVal UserIndex As Integer)
    '***************************************************
    'Autor: Unknown (orginal version)
    'Last Modification: 18/12/2009
    '18/12/2009: ZaMa - Oro directo a la billetera.
    '***************************************************

    Dim Obj    As ObjData

    Dim MiObj  As Obj

    Dim ObjPos As String
    
    With UserList(UserIndex)

        'Hay algun obj?
        If MapData(.Pos.Map, .Pos.x, .Pos.y).ObjInfo.ObjIndex > 0 Then

            'Esta permitido agarrar este obj?
            If ObjData(MapData(.Pos.Map, .Pos.x, .Pos.y).ObjInfo.ObjIndex).Agarrable <> 1 Then

                Dim x As Integer

                Dim y As Integer
                
                x = .Pos.x
                y = .Pos.y
                
                Obj = ObjData(MapData(.Pos.Map, .Pos.x, .Pos.y).ObjInfo.ObjIndex)
                MiObj.Amount = MapData(.Pos.Map, x, y).ObjInfo.Amount
                MiObj.ObjIndex = MapData(.Pos.Map, x, y).ObjInfo.ObjIndex
                
                ' Oro directo a la billetera!
                If Obj.OBJType = otGuita Then

                    'Calculamos la diferencia con el maximo de oro permitido el cual es el valor de LONG
                    Dim RemainingAmountToMaximumGold As Long
                    RemainingAmountToMaximumGold = 2147483647 - .Stats.Gld

                    If Not .Stats.Gld > 2147483647 And RemainingAmountToMaximumGold >= MiObj.Amount Then
                        .Stats.Gld = .Stats.Gld + MiObj.Amount
                        'Quitamos el objeto
                        Call EraseObj(MapData(.Pos.Map, x, y).ObjInfo.Amount, .Pos.Map, .Pos.x, .Pos.y)
                            
                        Call WriteUpdateGold(UserIndex)
                    Else
                        Call WriteConsoleMsg(UserIndex, "No puedes juntar este oro por que tendrias mas del maximo disponible (2147483647)", FontTypeNames.FONTTYPE_INFO)
                    End If
                Else

                    If MeterItemEnInventario(UserIndex, MiObj) Then
                    
                        'Quitamos el objeto
                        Call EraseObj(MapData(.Pos.Map, x, y).ObjInfo.Amount, .Pos.Map, .Pos.x, .Pos.y)

                        If Not .flags.Privilegios And PlayerType.User Then Call LogGM(.Name, "Agarro:" & MiObj.Amount & " Objeto:" & ObjData(MiObj.ObjIndex).Name)
        
                        'Log de Objetos que se agarran del piso. Pablo (ToxicWaste) 07/09/07
                        'Es un Objeto que tenemos que loguear?
                        If ObjData(MiObj.ObjIndex).Log = 1 Then
                            ObjPos = " Mapa: " & .Pos.Map & " X: " & .Pos.x & " Y: " & .Pos.y
                            Call LogDesarrollo(.Name & " junto del piso " & MiObj.Amount & " " & ObjData(MiObj.ObjIndex).Name & ObjPos)
                        ElseIf MiObj.Amount > 5000 Then 'Es mucha cantidad?

                            'Si no es de los prohibidos de loguear, lo logueamos.
                            If ObjData(MiObj.ObjIndex).NoLog <> 1 Then
                                ObjPos = " Mapa: " & .Pos.Map & " X: " & .Pos.x & " Y: " & .Pos.y
                                Call LogDesarrollo(.Name & " junto del piso " & MiObj.Amount & " " & ObjData(MiObj.ObjIndex).Name & ObjPos)

                            End If

                        End If

                    End If

                End If

            End If

        Else
            Call WriteConsoleMsg(UserIndex, "No hay nada aqui.", FontTypeNames.FONTTYPE_INFO)

        End If

    End With

End Sub

Public Sub Desequipar(ByVal UserIndex As Integer, ByVal Slot As Byte)
    '***************************************************
    'Author: Unknown
    'Last Modification: -
    '
    '***************************************************

    On Error GoTo errHandler

    'Desequipa el item slot del inventario
    Dim Obj As ObjData
    
    With UserList(UserIndex)
        With .Invent

            If (Slot < LBound(.Object)) Or (Slot > UBound(.Object)) Then
                Exit Sub
            ElseIf .Object(Slot).ObjIndex = 0 Then
                Exit Sub

            End If
            
            Obj = ObjData(.Object(Slot).ObjIndex)

        End With
        
        Select Case Obj.OBJType

            Case eOBJType.otWeapon

                With .Invent
                    .Object(Slot).Equipped = 0
                    .WeaponEqpObjIndex = 0
                    .WeaponEqpSlot = 0

                End With
                
                If Not .flags.Mimetizado = 1 Then

                    With .Char
                        .WeaponAnim = NingunArma
                        Call ChangeUserChar(UserIndex, .body, .Head, .heading, .WeaponAnim, .ShieldAnim, .CascoAnim)

                    End With

                End If
            
            Case eOBJType.otFlechas

                With .Invent
                    .Object(Slot).Equipped = 0
                    .MunicionEqpObjIndex = 0
                    .MunicionEqpSlot = 0

                End With
            
            Case eOBJType.otAnillo

                With .Invent
                    .Object(Slot).Equipped = 0
                    .AnilloEqpObjIndex = 0
                    .AnilloEqpSlot = 0

                End With
            
            Case eOBJType.otarmadura

                With .Invent
                    .Object(Slot).Equipped = 0
                    .ArmourEqpObjIndex = 0
                    .ArmourEqpSlot = 0

                End With
                
                Call DarCuerpoDesnudo(UserIndex, .flags.Mimetizado = 1)

                With .Char
                    Call ChangeUserChar(Userindex, .body, .Head, .heading, .WeaponAnim, .ShieldAnim, .CascoAnim)

                End With
                 
            Case eOBJType.otcasco

                With .Invent
                    .Object(Slot).Equipped = 0
                    .CascoEqpObjIndex = 0
                    .CascoEqpSlot = 0

                End With
                
                If Not .flags.Mimetizado = 1 Then

                    With .Char
                        .CascoAnim = NingunCasco
                        Call ChangeUserChar(Userindex, .body, .Head, .heading, .WeaponAnim, .ShieldAnim, .CascoAnim)

                    End With

                End If
            
            Case eOBJType.otescudo

                With .Invent
                    .Object(Slot).Equipped = 0
                    .EscudoEqpObjIndex = 0
                    .EscudoEqpSlot = 0

                End With
                
                If Not .flags.Mimetizado = 1 Then

                    With .Char
                        .ShieldAnim = NingunEscudo
                        Call ChangeUserChar(Userindex, .body, .Head, .heading, .WeaponAnim, .ShieldAnim, .CascoAnim)

                    End With

                End If
            
            Case eOBJType.otMochilas

                With .Invent
                    .Object(Slot).Equipped = 0
                    .MochilaEqpObjIndex = 0
                    .MochilaEqpSlot = 0

                End With
                
                Call InvUsuario.TirarTodosLosItemsEnMochila(Userindex)
                .CurrentInventorySlots = MAX_NORMAL_INVENTORY_SLOTS

        End Select

    End With
    
    Call WriteUpdateUserStats(Userindex)
    Call UpdateUserInv(False, Userindex, Slot)
    
    Exit Sub

ErrHandler:
    Call LogError("Error en Desquipar. Error " & Err.Number & " : " & Err.description)

End Sub

Function EsUsable(ByVal ObjIndex As Integer)
'*************************************************
'Author: Jopi
'Revisa si el objeto puede ser equipado/usado.
'*************************************************
    Dim obj As ObjData
        obj = ObjData(ObjIndex)
    
    Select Case obj.OBJType
    
        Case eOBJType.otArbolElfico
            EsUsable = False
        
        Case eOBJType.otArboles
            EsUsable = False
        
        Case eOBJType.otCarteles
            EsUsable = False
        
        Case eOBJType.otForos
            EsUsable = False
        
        Case eOBJType.otFragua
            EsUsable = False
        
        Case eOBJType.otMuebles
            EsUsable = False
        
        Case eOBJType.otPuertas
            EsUsable = False
        
        Case eOBJType.otTeleport
            EsUsable = False
        
        Case eOBJType.otYacimiento
            EsUsable = False
        
        Case eOBJType.otYacimientoPez
            EsUsable = False
        
        Case eOBJType.otYunque
            EsUsable = False
        
        Case Else
            EsUsable = True
    
    End Select

End Function

Function SexoPuedeUsarItem(ByVal Userindex As Integer, _
                           ByVal ObjIndex As Integer, _
                           Optional ByRef sMotivo As String) As Boolean
    '***************************************************
    'Author: Unknown
    'Last Modification: 14/01/2010 (ZaMa)
    '14/01/2010: ZaMa - Agrego el motivo por el que no puede equipar/usar el item.
    '***************************************************

    On Error GoTo errHandler
    
    If ObjData(ObjIndex).Mujer = 1 Then
        SexoPuedeUsarItem = UserList(UserIndex).Genero <> eGenero.Hombre
    ElseIf ObjData(ObjIndex).Hombre = 1 Then
        SexoPuedeUsarItem = UserList(UserIndex).Genero <> eGenero.Mujer
    Else
        SexoPuedeUsarItem = True

    End If
    
    If Not SexoPuedeUsarItem Then sMotivo = "Tu genero no puede usar este objeto."
    
    Exit Function
errHandler:
    Call LogError("SexoPuedeUsarItem")

End Function

Function FaccionPuedeUsarItem(ByVal UserIndex As Integer, _
                              ByVal ObjIndex As Integer, _
                              Optional ByRef sMotivo As String) As Boolean
    '***************************************************
    'Author: Unknown
    'Last Modification: 14/01/2010 (ZaMa)
    '14/01/2010: ZaMa - Agrego el motivo por el que no puede equipar/usar el item.
    '***************************************************

    If ObjData(ObjIndex).Real = 1 Then
        If Not criminal(Userindex) Then
            FaccionPuedeUsarItem = esArmada(Userindex)
        Else
            FaccionPuedeUsarItem = False

        End If

    ElseIf ObjData(ObjIndex).Caos = 1 Then

        If criminal(UserIndex) Then
            FaccionPuedeUsarItem = esCaos(UserIndex)
        Else
            FaccionPuedeUsarItem = False

        End If

    Else
        FaccionPuedeUsarItem = True

    End If
    
    If Not FaccionPuedeUsarItem Then sMotivo = "Tu alineacion no puede usar este objeto."

End Function

Sub EquiparInvItem(ByVal UserIndex As Integer, ByVal Slot As Byte)
    '*************************************************
    'Author: Unknown
    'Last modified: 14/01/2010 (ZaMa)
    '01/08/2009: ZaMa - Now it's not sent any sound made by an invisible admin
    '14/01/2010: ZaMa - Agrego el motivo especifico por el que no puede equipar/usar el item.
    '*************************************************

    On Error GoTo errHandler

    'Equipa un item del inventario
    Dim Obj      As ObjData

    Dim ObjIndex As Integer

    Dim sMotivo  As String
    
    With UserList(UserIndex)
        ObjIndex = .Invent.Object(Slot).ObjIndex
        obj = ObjData(ObjIndex)
        
        ' No se pueden usar muebles.
        If Not EsUsable(ObjIndex) Then Exit Sub
        
        If Obj.Newbie = 1 And Not EsNewbie(UserIndex) Then
            Call WriteConsoleMsg(UserIndex, "Solo los newbies pueden usar este objeto.", FontTypeNames.FONTTYPE_INFO)
            Exit Sub

        End If
                
        Select Case Obj.OBJType

            Case eOBJType.otWeapon

                If ClasePuedeUsarItem(UserIndex, ObjIndex, sMotivo) And FaccionPuedeUsarItem(UserIndex, ObjIndex, sMotivo) Then

                    'Si esta equipado lo quita
                    If .Invent.Object(Slot).Equipped Then
                        'Quitamos del inv el item
                        Call Desequipar(UserIndex, Slot)

                        'Animacion por defecto
                        If .flags.Mimetizado = 1 Then
                            .CharMimetizado.WeaponAnim = NingunArma
                        Else
                            .Char.WeaponAnim = NingunArma
                            Call ChangeUserChar(UserIndex, .Char.body, .Char.Head, .Char.heading, .Char.WeaponAnim, .Char.ShieldAnim, .Char.CascoAnim)

                        End If

                        Exit Sub

                    End If
                    
                    'Quitamos el elemento anterior
                    If .Invent.WeaponEqpObjIndex > 0 Then
                        Call Desequipar(UserIndex, .Invent.WeaponEqpSlot)

                    End If
                    
                    .Invent.Object(Slot).Equipped = 1
                    .Invent.WeaponEqpObjIndex = ObjIndex
                    .Invent.WeaponEqpSlot = Slot
                    
                    'El sonido solo se envia si no lo produce un admin invisible
                    If Not (.flags.AdminInvisible = 1) Then Call SendData(SendTarget.ToPCArea, UserIndex, PrepareMessagePlayWave(SND_SACARARMA, .Pos.x, .Pos.y))
                    
                    If .flags.Mimetizado = 1 Then
                        .CharMimetizado.WeaponAnim = GetWeaponAnim(UserIndex, ObjIndex)
                    Else
                        .Char.WeaponAnim = GetWeaponAnim(UserIndex, ObjIndex)
                        Call ChangeUserChar(UserIndex, .Char.body, .Char.Head, .Char.heading, .Char.WeaponAnim, .Char.ShieldAnim, .Char.CascoAnim)

                    End If

                Else
                    Call WriteConsoleMsg(UserIndex, sMotivo, FontTypeNames.FONTTYPE_INFO)

                End If
            
            Case eOBJType.otAnillo

                If ClasePuedeUsarItem(UserIndex, ObjIndex, sMotivo) And FaccionPuedeUsarItem(UserIndex, ObjIndex, sMotivo) Then

                    'Si esta equipado lo quita
                    If .Invent.Object(Slot).Equipped Then
                        'Quitamos del inv el item
                        Call Desequipar(UserIndex, Slot)
                        Exit Sub

                    End If
                        
                    'Quitamos el elemento anterior
                    If .Invent.AnilloEqpObjIndex > 0 Then
                        Call Desequipar(UserIndex, .Invent.AnilloEqpSlot)

                    End If
                
                    .Invent.Object(Slot).Equipped = 1
                    .Invent.AnilloEqpObjIndex = ObjIndex
                    .Invent.AnilloEqpSlot = Slot
                        
                Else
                    Call WriteConsoleMsg(UserIndex, sMotivo, FontTypeNames.FONTTYPE_INFO)

                End If
            
            Case eOBJType.otFlechas

                If ClasePuedeUsarItem(UserIndex, ObjIndex, sMotivo) And FaccionPuedeUsarItem(UserIndex, ObjIndex, sMotivo) Then
                        
                    'Si esta equipado lo quita
                    If .Invent.Object(Slot).Equipped Then
                        'Quitamos del inv el item
                        Call Desequipar(UserIndex, Slot)
                        Exit Sub

                    End If
                        
                    'Quitamos el elemento anterior
                    If .Invent.MunicionEqpObjIndex > 0 Then
                        Call Desequipar(UserIndex, .Invent.MunicionEqpSlot)

                    End If
                
                    .Invent.Object(Slot).Equipped = 1
                    .Invent.MunicionEqpObjIndex = ObjIndex
                    .Invent.MunicionEqpSlot = Slot
                        
                Else
                    Call WriteConsoleMsg(UserIndex, sMotivo, FontTypeNames.FONTTYPE_INFO)

                End If
            
            Case eOBJType.otarmadura

                If .flags.Navegando = 1 Then Exit Sub
                
                'Nos aseguramos que puede usarla
                If ClasePuedeUsarItem(UserIndex, ObjIndex, sMotivo) And SexoPuedeUsarItem(UserIndex, ObjIndex, sMotivo) And CheckRazaUsaRopa(UserIndex, ObjIndex, sMotivo) And FaccionPuedeUsarItem(UserIndex, ObjIndex, sMotivo) Then
                   
                    'Si esta equipado lo quita
                    If .Invent.Object(Slot).Equipped Then
                        Call Desequipar(UserIndex, Slot)
                        Call DarCuerpoDesnudo(UserIndex, .flags.Mimetizado = 1)

                        If Not .flags.Mimetizado = 1 Then
                            Call ChangeUserChar(UserIndex, .Char.body, .Char.Head, .Char.heading, .Char.WeaponAnim, .Char.ShieldAnim, .Char.CascoAnim)

                        End If

                        Exit Sub

                    End If
            
                    'Quita el anterior
                    If .Invent.ArmourEqpObjIndex > 0 Then
                        Call Desequipar(UserIndex, .Invent.ArmourEqpSlot)

                    End If
            
                    'Lo equipa
                    .Invent.Object(Slot).Equipped = 1
                    .Invent.ArmourEqpObjIndex = ObjIndex
                    .Invent.ArmourEqpSlot = Slot
                        
                    If .flags.Mimetizado = 1 Then
                        .CharMimetizado.body = Obj.Ropaje
                    Else
                        .Char.body = Obj.Ropaje
                        Call ChangeUserChar(UserIndex, .Char.body, .Char.Head, .Char.heading, .Char.WeaponAnim, .Char.ShieldAnim, .Char.CascoAnim)

                    End If

                    .flags.Desnudo = 0
                Else
                    Call WriteConsoleMsg(UserIndex, sMotivo, FontTypeNames.FONTTYPE_INFO)

                End If
            
            Case eOBJType.otcasco

                If .flags.Navegando = 1 Then Exit Sub
                If ClasePuedeUsarItem(UserIndex, ObjIndex, sMotivo) Then

                    'Si esta equipado lo quita
                    If .Invent.Object(Slot).Equipped Then
                        Call Desequipar(UserIndex, Slot)

                        If .flags.Mimetizado = 1 Then
                            .CharMimetizado.CascoAnim = NingunCasco
                        Else
                            .Char.CascoAnim = NingunCasco
                            Call ChangeUserChar(UserIndex, .Char.body, .Char.Head, .Char.heading, .Char.WeaponAnim, .Char.ShieldAnim, .Char.CascoAnim)

                        End If

                        Exit Sub

                    End If
            
                    'Quita el anterior
                    If .Invent.CascoEqpObjIndex > 0 Then
                        Call Desequipar(UserIndex, .Invent.CascoEqpSlot)

                    End If
            
                    'Lo equipa
                    
                    .Invent.Object(Slot).Equipped = 1
                    .Invent.CascoEqpObjIndex = ObjIndex
                    .Invent.CascoEqpSlot = Slot

                    If .flags.Mimetizado = 1 Then
                        .CharMimetizado.CascoAnim = Obj.CascoAnim
                    Else
                        .Char.CascoAnim = Obj.CascoAnim
                        Call ChangeUserChar(UserIndex, .Char.body, .Char.Head, .Char.heading, .Char.WeaponAnim, .Char.ShieldAnim, .Char.CascoAnim)

                    End If

                Else
                    Call WriteConsoleMsg(UserIndex, sMotivo, FontTypeNames.FONTTYPE_INFO)

                End If
            
            Case eOBJType.otescudo

                If .flags.Navegando = 1 Then Exit Sub
                
                If ClasePuedeUsarItem(UserIndex, ObjIndex, sMotivo) And FaccionPuedeUsarItem(UserIndex, ObjIndex, sMotivo) Then
        
                    'Si esta equipado lo quita
                    If .Invent.Object(Slot).Equipped Then
                        Call Desequipar(UserIndex, Slot)

                        If .flags.Mimetizado = 1 Then
                            .CharMimetizado.ShieldAnim = NingunEscudo
                        Else
                            .Char.ShieldAnim = NingunEscudo
                            Call ChangeUserChar(UserIndex, .Char.body, .Char.Head, .Char.heading, .Char.WeaponAnim, .Char.ShieldAnim, .Char.CascoAnim)

                        End If

                        Exit Sub

                    End If
             
                    'Quita el anterior
                    If .Invent.EscudoEqpObjIndex > 0 Then
                        Call Desequipar(UserIndex, .Invent.EscudoEqpSlot)

                    End If
             
                    'Lo equipa
                     
                    .Invent.Object(Slot).Equipped = 1
                    .Invent.EscudoEqpObjIndex = ObjIndex
                    .Invent.EscudoEqpSlot = Slot
                     
                    If .flags.Mimetizado = 1 Then
                        .CharMimetizado.ShieldAnim = Obj.ShieldAnim
                    Else
                        .Char.ShieldAnim = Obj.ShieldAnim
                         
                        Call ChangeUserChar(UserIndex, .Char.body, .Char.Head, .Char.heading, .Char.WeaponAnim, .Char.ShieldAnim, .Char.CascoAnim)

                    End If

                Else
                    Call WriteConsoleMsg(UserIndex, sMotivo, FontTypeNames.FONTTYPE_INFO)

                End If
                 
            Case eOBJType.otMochilas

                If .flags.Muerto = 1 Then
                    'Call WriteConsoleMsg(UserIndex, "Estas muerto!! Solo podes usar items cuando estas vivo. ", FontTypeNames.FONTTYPE_INFO)
                    Call WriteMultiMessage(UserIndex, eMessages.UserMuerto)
                    Exit Sub

                End If

                If .Invent.Object(Slot).Equipped Then
                    Call Desequipar(UserIndex, Slot)
                    Exit Sub

                End If

                If .Invent.MochilaEqpObjIndex > 0 Then
                    Call Desequipar(UserIndex, .Invent.MochilaEqpSlot)

                End If

                .Invent.Object(Slot).Equipped = 1
                .Invent.MochilaEqpObjIndex = ObjIndex
                .Invent.MochilaEqpSlot = Slot

        End Select

    End With
    
    'Actualiza
    Call UpdateUserInv(False, UserIndex, Slot)
    
    Exit Sub
    
errHandler:
    Call LogError("EquiparInvItem Slot:" & Slot & " - Error: " & Err.Number & " - Error Description : " & Err.description)

End Sub

Private Function CheckRazaUsaRopa(ByVal UserIndex As Integer, _
                                  ItemIndex As Integer, _
                                  Optional ByRef sMotivo As String) As Boolean
    '***************************************************
    'Author: Unknown
    'Last Modification: 14/01/2010 (ZaMa)
    '14/01/2010: ZaMa - Agrego el motivo por el que no puede equipar/usar el item.
    '***************************************************

    On Error GoTo errHandler

    With UserList(UserIndex)

        'Verifica si la raza puede usar la ropa
        If .raza = eRaza.Humano Or .raza = eRaza.Elfo Or .raza = eRaza.Drow Then
            CheckRazaUsaRopa = (ObjData(ItemIndex).RazaEnana = 0)
        Else
            CheckRazaUsaRopa = (ObjData(ItemIndex).RazaEnana = 1)

        End If
        
        'Solo se habilita la ropa exclusiva para Drows por ahora. Pablo (ToxicWaste)
        If (.raza <> eRaza.Drow) And ObjData(ItemIndex).RazaDrow Then
            CheckRazaUsaRopa = False

        End If

    End With
    
    If Not CheckRazaUsaRopa Then sMotivo = "Tu raza no puede usar este objeto."
    
    Exit Function
    
errHandler:
    Call LogError("Error CheckRazaUsaRopa ItemIndex:" & ItemIndex)

End Function

Sub UseInvItem(ByVal UserIndex As Integer, ByVal Slot As Byte)
    '*************************************************
    'Author: Unknown
    'Last modified: 10/12/2009
    'Handels the usage of items from inventory box.
    '24/01/2007 Pablo (ToxicWaste) - Agrego el Cuerno de la Armada y la Legion.
    '24/01/2007 Pablo (ToxicWaste) - Utilizacion nueva de Barco en lvl 20 por clase Pirata y Pescador.
    '01/08/2009: ZaMa - Now it's not sent any sound made by an invisible admin, except to its own client
    '17/11/2009: ZaMa - Ahora se envia una orientacion de la posicion hacia donde esta el que uso el cuerno.
    '27/11/2009: Budi - Se envia indivualmente cuando se modifica a la Agilidad o la Fuerza del personaje.
    '08/12/2009: ZaMa - Agrego el uso de hacha de madera elfica.
    '10/12/2009: ZaMa - Arreglos y validaciones en todos las herramientas de trabajo.
    '*************************************************

    Dim Obj      As ObjData

    Dim ObjIndex As Integer

    Dim TargObj  As ObjData

    Dim MiObj    As Obj
    
    With UserList(UserIndex)
    
        If .Invent.Object(Slot).Amount = 0 Then Exit Sub
        
        obj = ObjData(.Invent.Object(Slot).ObjIndex)
        
        If obj.Newbie = 1 And Not EsNewbie(Userindex) Then
            Call WriteConsoleMsg(Userindex, "Solo los newbies pueden usar estos objetos.", FontTypeNames.FONTTYPE_INFO)
            Exit Sub

        End If
        
        If Obj.OBJType = eOBJType.otWeapon Then
            If Obj.proyectil = 1 Then
                
                'valido para evitar el flood pero no bloqueo. El bloqueo se hace en WLC con proyectiles.
                If Not IntervaloPermiteUsar(UserIndex, False) Then Exit Sub
            Else

                'dagas
                If Not IntervaloPermiteUsar(UserIndex) Then Exit Sub

            End If

        Else

            If Not IntervaloPermiteUsar(UserIndex) Then Exit Sub

        End If
        
        ObjIndex = .Invent.Object(Slot).ObjIndex
        .flags.TargetObjInvIndex = ObjIndex
        .flags.TargetObjInvSlot = Slot
        
        ' No se pueden usar muebles.
        If Not EsUsable(ObjIndex) Then Exit Sub
        
        Select Case obj.OBJType

            Case eOBJType.otUseOnce

                If .flags.Muerto = 1 Then
                    'Call WriteConsoleMsg(UserIndex, "Estas muerto!! Solo puedes usar items cuando estas vivo.", FontTypeNames.FONTTYPE_INFO)
                    Call WriteMultiMessage(UserIndex, eMessages.UserMuerto)
                    Exit Sub

                End If
        
                'Usa el item
                .Stats.MinHam = .Stats.MinHam + Obj.MinHam

                If .Stats.MinHam > .Stats.MaxHam Then .Stats.MinHam = .Stats.MaxHam
                .flags.Hambre = 0
                Call WriteUpdateHungerAndThirst(UserIndex)
                'Sonido
                
                If ObjIndex = e_ObjetosCriticos.Manzana Or ObjIndex = e_ObjetosCriticos.Manzana2 Or ObjIndex = e_ObjetosCriticos.ManzanaNewbie Then
                    Call ReproducirSonido(SendTarget.ToPCArea, UserIndex, e_SoundIndex.MORFAR_MANZANA)
                Else
                    Call ReproducirSonido(SendTarget.ToPCArea, UserIndex, e_SoundIndex.SOUND_COMIDA)

                End If
                
                'Quitamos del inv el item
                Call QuitarUserInvItem(UserIndex, Slot, 1)
                
                Call UpdateUserInv(False, UserIndex, Slot)
        
            Case eOBJType.otGuita

                If .flags.Muerto = 1 Then
                    'Call WriteConsoleMsg(UserIndex, "Estas muerto!! Solo puedes usar items cuando estas vivo.", FontTypeNames.FONTTYPE_INFO)
                    Call WriteMultiMessage(UserIndex, eMessages.UserMuerto)
                    Exit Sub

                End If
                
                .Stats.Gld = .Stats.Gld + .Invent.Object(Slot).Amount
                .Invent.Object(Slot).Amount = 0
                .Invent.Object(Slot).ObjIndex = 0
                .Invent.NroItems = .Invent.NroItems - 1
                
                Call UpdateUserInv(False, UserIndex, Slot)
                Call WriteUpdateGold(UserIndex)
                
            Case eOBJType.otWeapon

                If .flags.Muerto = 1 Then
                    'Call WriteConsoleMsg(UserIndex, "Estas muerto!! Solo puedes usar items cuando estas vivo.", FontTypeNames.FONTTYPE_INFO)
                    Call WriteMultiMessage(UserIndex, eMessages.UserMuerto)
                    Exit Sub

                End If
                
                If Not .Stats.MinSta > 0 Then
                    Call WriteConsoleMsg(UserIndex, "Estas muy cansad" & IIf(.Genero = eGenero.Hombre, "o", "a") & ".", FontTypeNames.FONTTYPE_INFO)
                    Exit Sub

                End If
                
                If ObjData(ObjIndex).proyectil = 1 Then
                    If .Invent.Object(Slot).Equipped = 0 Then
                        Call WriteConsoleMsg(UserIndex, "Antes de usar la herramienta deberias equipartela.", FontTypeNames.FONTTYPE_INFO)
                        Exit Sub

                    End If

                    Call WriteMultiMessage(UserIndex, eMessages.WorkRequestTarget, eSkill.Proyectiles)  'Call WriteWorkRequestTarget(UserIndex, Proyectiles)
                ElseIf .flags.TargetObj = Lena Then

                    If .Invent.Object(Slot).ObjIndex = DAGA Then
                        If .Invent.Object(Slot).Equipped = 0 Then
                            Call WriteConsoleMsg(UserIndex, "Antes de usar la herramienta deberias equipartela.", FontTypeNames.FONTTYPE_INFO)
                            Exit Sub

                        End If
                            
                        Call TratarDeHacerFogata(.flags.TargetObjMap, .flags.TargetObjX, .flags.TargetObjY, UserIndex)

                    End If

                Else
                    
                    Select Case ObjIndex
                    
                        Case CANA_PESCA, RED_PESCA, CANA_PESCA_NEWBIE
                            
                            ' Lo tiene equipado?
                            If .Invent.WeaponEqpObjIndex = ObjIndex Then
                                Call WriteMultiMessage(UserIndex, eMessages.WorkRequestTarget, eSkill.Pesca)  'Call WriteWorkRequestTarget(UserIndex, eSkill.Pesca)
                            Else
                                Call WriteConsoleMsg(UserIndex, "Debes tener equipada la herramienta para trabajar.", FontTypeNames.FONTTYPE_INFO)

                            End If
                            
                        Case HACHA_LENADOR, HACHA_LENA_ELFICA, HACHA_LENADOR_NEWBIE
                            
                            ' Lo tiene equipado?
                            If .Invent.WeaponEqpObjIndex = ObjIndex Then
                                Call WriteMultiMessage(UserIndex, eMessages.WorkRequestTarget, eSkill.Talar)
                            Else
                                Call WriteConsoleMsg(UserIndex, "Debes tener equipada la herramienta para trabajar.", FontTypeNames.FONTTYPE_INFO)

                            End If
                            
                        Case PIQUETE_MINERO, PIQUETE_MINERO_NEWBIE
                        
                            ' Lo tiene equipado?
                            If .Invent.WeaponEqpObjIndex = ObjIndex Then
                                Call WriteMultiMessage(UserIndex, eMessages.WorkRequestTarget, eSkill.Mineria)
                            Else
                                Call WriteConsoleMsg(UserIndex, "Debes tener equipada la herramienta para trabajar.", FontTypeNames.FONTTYPE_INFO)

                            End If
                            
                        Case MARTILLO_HERRERO, MARTILLO_HERRERO_NEWBIE
                        
                            ' Lo tiene equipado?
                            If .Invent.WeaponEqpObjIndex = ObjIndex Then
                                Call WriteMultiMessage(UserIndex, eMessages.WorkRequestTarget, eSkill.Herreria)
                            Else
                                Call WriteConsoleMsg(UserIndex, "Debes tener equipada la herramienta para trabajar.", FontTypeNames.FONTTYPE_INFO)

                            End If
                            
                        Case SERRUCHO_CARPINTERO, SERRUCHO_CARPINTERO_NEWBIE
                            
                            ' Lo tiene equipado?
                            If .Invent.WeaponEqpObjIndex = ObjIndex Then
                                Call EnivarObjConstruibles(UserIndex)
                                Call WriteShowCarpenterForm(UserIndex)
                            Else
                                Call WriteConsoleMsg(UserIndex, "Debes tener equipada la herramienta para trabajar.", FontTypeNames.FONTTYPE_INFO)

                            End If
                            
                        Case Else ' Las herramientas no se pueden fundir

                            If ObjData(ObjIndex).SkHerreria > 0 Then
                                ' Solo objetos que pueda hacer el herrero
                                Call WriteMultiMessage(UserIndex, eMessages.WorkRequestTarget, FundirMetal) 'Call WriteWorkRequestTarget(UserIndex, FundirMetal)

                            End If

                    End Select

                End If
            
            Case eOBJType.otPociones

                If .flags.Muerto = 1 Then
                    'Call WriteConsoleMsg(UserIndex, "Estas muerto!! Solo puedes usar items cuando estas vivo. ", FontTypeNames.FONTTYPE_INFO)
                    Call WriteMultiMessage(UserIndex, eMessages.UserMuerto)
                    Exit Sub

                End If
                
                If Not IntervaloPermiteGolpeUsar(UserIndex, False) Then
                    Call WriteConsoleMsg(UserIndex, "Debes esperar unos momentos para tomar otra pocion!!", FontTypeNames.FONTTYPE_INFO)
                    Exit Sub

                End If
                
                .flags.TomoPocion = True
                .flags.TipoPocion = Obj.TipoPocion
                        
                Select Case .flags.TipoPocion
                
                    Case 1 'Modif la agilidad
                        .flags.DuracionEfecto = Obj.DuracionEfecto
                
                        'Usa el item
                        .Stats.UserAtributos(eAtributos.Agilidad) = .Stats.UserAtributos(eAtributos.Agilidad) + RandomNumber(Obj.MinModificador, Obj.MaxModificador)

                        If .Stats.UserAtributos(eAtributos.Agilidad) > MAXATRIBUTOS Then .Stats.UserAtributos(eAtributos.Agilidad) = MAXATRIBUTOS

                        If .Stats.UserAtributos(eAtributos.Agilidad) > 2 * .Stats.UserAtributosBackUP(Agilidad) Then .Stats.UserAtributos(eAtributos.Agilidad) = 2 * .Stats.UserAtributosBackUP(Agilidad)
                        
                        'Quitamos del inv el item
                        Call QuitarUserInvItem(UserIndex, Slot, 1)
                        
                        ' Los admin invisibles solo producen sonidos a si mismos
                        If .flags.AdminInvisible = 1 Then
                            Call EnviarDatosASlot(UserIndex, PrepareMessagePlayWave(SND_BEBER, .Pos.x, .Pos.y))
                        Else
                            Call SendData(SendTarget.ToPCArea, UserIndex, PrepareMessagePlayWave(SND_BEBER, .Pos.x, .Pos.y))

                        End If

                        Call WriteUpdateDexterity(UserIndex)
                        
                    Case 2 'Modif la fuerza
                        .flags.DuracionEfecto = Obj.DuracionEfecto
                
                        'Usa el item
                        .Stats.UserAtributos(eAtributos.Fuerza) = .Stats.UserAtributos(eAtributos.Fuerza) + RandomNumber(Obj.MinModificador, Obj.MaxModificador)

                        If .Stats.UserAtributos(eAtributos.Fuerza) > MAXATRIBUTOS Then .Stats.UserAtributos(eAtributos.Fuerza) = MAXATRIBUTOS

                        If .Stats.UserAtributos(eAtributos.Fuerza) > 2 * .Stats.UserAtributosBackUP(Fuerza) Then .Stats.UserAtributos(eAtributos.Fuerza) = 2 * .Stats.UserAtributosBackUP(Fuerza)
                        
                        'Quitamos del inv el item
                        Call QuitarUserInvItem(UserIndex, Slot, 1)
                        
                        ' Los admin invisibles solo producen sonidos a si mismos
                        If .flags.AdminInvisible = 1 Then
                            Call EnviarDatosASlot(UserIndex, PrepareMessagePlayWave(SND_BEBER, .Pos.x, .Pos.y))
                        Else
                            Call SendData(SendTarget.ToPCArea, UserIndex, PrepareMessagePlayWave(SND_BEBER, .Pos.x, .Pos.y))

                        End If

                        Call WriteUpdateStrenght(UserIndex)
                        
                    Case 3 'Pocion roja, restaura HP
                        'Usa el item
                        .Stats.MinHp = .Stats.MinHp + RandomNumber(Obj.MinModificador, Obj.MaxModificador)

                        If .Stats.MinHp > .Stats.MaxHp Then .Stats.MinHp = .Stats.MaxHp
                        
                        'Quitamos del inv el item
                        Call QuitarUserInvItem(UserIndex, Slot, 1)
                        
                        ' Los admin invisibles solo producen sonidos a si mismos
                        If .flags.AdminInvisible = 1 Then
                            Call EnviarDatosASlot(UserIndex, PrepareMessagePlayWave(SND_BEBER, .Pos.x, .Pos.y))
                        Else
                            Call SendData(SendTarget.ToPCArea, UserIndex, PrepareMessagePlayWave(SND_BEBER, .Pos.x, .Pos.y))

                        End If
                    
                    Case 4 'Pocion azul, restaura MANA
                        'Usa el item
                        'nuevo calculo para recargar mana
                        .Stats.MinMAN = .Stats.MinMAN + Porcentaje(.Stats.MaxMAN, 4) + .Stats.ELV \ 2 + 40 / .Stats.ELV

                        If .Stats.MinMAN > .Stats.MaxMAN Then .Stats.MinMAN = .Stats.MaxMAN
                        
                        'Quitamos del inv el item
                        Call QuitarUserInvItem(UserIndex, Slot, 1)
                        
                        ' Los admin invisibles solo producen sonidos a si mismos
                        If .flags.AdminInvisible = 1 Then
                            Call EnviarDatosASlot(UserIndex, PrepareMessagePlayWave(SND_BEBER, .Pos.x, .Pos.y))
                        Else
                            Call SendData(SendTarget.ToPCArea, UserIndex, PrepareMessagePlayWave(SND_BEBER, .Pos.x, .Pos.y))

                        End If
                        
                    Case 5 ' Pocion violeta

                        If .flags.Envenenado = 1 Then
                            .flags.Envenenado = 0
                            Call WriteConsoleMsg(UserIndex, "Te has curado del envenenamiento.", FontTypeNames.FONTTYPE_INFO)

                        End If

                        'Quitamos del inv el item
                        Call QuitarUserInvItem(UserIndex, Slot, 1)
                        
                        ' Los admin invisibles solo producen sonidos a si mismos
                        If .flags.AdminInvisible = 1 Then
                            Call EnviarDatosASlot(UserIndex, PrepareMessagePlayWave(SND_BEBER, .Pos.x, .Pos.y))
                        Else
                            Call SendData(SendTarget.ToPCArea, UserIndex, PrepareMessagePlayWave(SND_BEBER, .Pos.x, .Pos.y))

                        End If
                        
                    Case 6  ' Pocion Negra
                        If .flags.SlotReto > 0 Then Exit Sub
                        
                        If .flags.Privilegios And PlayerType.User Then
                            Call QuitarUserInvItem(UserIndex, Slot, 1)
                            Call UserDie(UserIndex)
                            Call WriteConsoleMsg(UserIndex, "Sientes un gran mareo y pierdes el conocimiento.", FontTypeNames.FONTTYPE_FIGHT)

                        End If

                End Select

                Call WriteUpdateUserStats(UserIndex)
                Call UpdateUserInv(False, UserIndex, Slot)
        
            Case eOBJType.otBebidas

                If .flags.Muerto = 1 Then
                    'Call WriteConsoleMsg(UserIndex, "Estas muerto!! Solo puedes usar items cuando estas vivo.", FontTypeNames.FONTTYPE_INFO)
                    Call WriteMultiMessage(UserIndex, eMessages.UserMuerto)
                    Exit Sub

                End If

                .Stats.MinAGU = .Stats.MinAGU + Obj.MinSed

                If .Stats.MinAGU > .Stats.MaxAGU Then .Stats.MinAGU = .Stats.MaxAGU
                .flags.Sed = 0
                Call WriteUpdateHungerAndThirst(UserIndex)
                
                'Quitamos del inv el item
                Call QuitarUserInvItem(UserIndex, Slot, 1)
                
                ' Los admin invisibles solo producen sonidos a si mismos
                If .flags.AdminInvisible = 1 Then
                    Call EnviarDatosASlot(UserIndex, PrepareMessagePlayWave(SND_BEBER, .Pos.x, .Pos.y))
                Else
                    Call SendData(SendTarget.ToPCArea, UserIndex, PrepareMessagePlayWave(SND_BEBER, .Pos.x, .Pos.y))

                End If
                
                Call UpdateUserInv(False, UserIndex, Slot)
            
            Case eOBJType.otLlaves

                If .flags.Muerto = 1 Then
                    'Call WriteConsoleMsg(UserIndex, "Estas muerto!! Solo puedes usar items cuando estas vivo.", FontTypeNames.FONTTYPE_INFO)
                    Call WriteMultiMessage(UserIndex, eMessages.UserMuerto)
                    Exit Sub

                End If
                
                If .flags.TargetObj = 0 Then Exit Sub
                TargObj = ObjData(.flags.TargetObj)

                'El objeto clickeado es una puerta?
                If TargObj.OBJType = eOBJType.otPuertas Then

                    'Esta cerrada?
                    If TargObj.Cerrada = 1 Then

                        'Cerrada con llave?
                        If TargObj.Llave > 0 Then
                            If TargObj.Clave = Obj.Clave Then
                 
                                MapData(.flags.TargetObjMap, .flags.TargetObjX, .flags.TargetObjY).ObjInfo.ObjIndex = ObjData(MapData(.flags.TargetObjMap, .flags.TargetObjX, .flags.TargetObjY).ObjInfo.ObjIndex).IndexCerrada
                                .flags.TargetObj = MapData(.flags.TargetObjMap, .flags.TargetObjX, .flags.TargetObjY).ObjInfo.ObjIndex
                                Call WriteConsoleMsg(UserIndex, "Has abierto la puerta.", FontTypeNames.FONTTYPE_INFO)
                                Exit Sub
                            Else
                                Call WriteConsoleMsg(UserIndex, "La llave no sirve.", FontTypeNames.FONTTYPE_INFO)
                                Exit Sub

                            End If

                        Else

                            If TargObj.Clave = Obj.Clave Then
                                MapData(.flags.TargetObjMap, .flags.TargetObjX, .flags.TargetObjY).ObjInfo.ObjIndex = ObjData(MapData(.flags.TargetObjMap, .flags.TargetObjX, .flags.TargetObjY).ObjInfo.ObjIndex).IndexCerradaLlave
                                Call WriteConsoleMsg(UserIndex, "Has cerrado con llave la puerta.", FontTypeNames.FONTTYPE_INFO)
                                .flags.TargetObj = MapData(.flags.TargetObjMap, .flags.TargetObjX, .flags.TargetObjY).ObjInfo.ObjIndex
                                Exit Sub
                            Else
                                Call WriteConsoleMsg(UserIndex, "La llave no sirve.", FontTypeNames.FONTTYPE_INFO)
                                Exit Sub

                            End If

                        End If

                    Else
                        Call WriteConsoleMsg(UserIndex, "No esta cerrada.", FontTypeNames.FONTTYPE_INFO)
                        Exit Sub

                    End If

                End If
            
            Case eOBJType.otBotellaVacia

                If .flags.Muerto = 1 Then
                    'Call WriteConsoleMsg(UserIndex, "Estas muerto!! Solo puedes usar items cuando estas vivo.", FontTypeNames.FONTTYPE_INFO)
                    Call WriteMultiMessage(UserIndex, eMessages.UserMuerto)
                    Exit Sub

                End If

                If Not HayAgua(.Pos.Map, .flags.TargetX, .flags.TargetY) Then
                    Call WriteConsoleMsg(UserIndex, "No hay agua alli.", FontTypeNames.FONTTYPE_INFO)
                    Exit Sub

                End If

                MiObj.Amount = 1
                MiObj.ObjIndex = ObjData(.Invent.Object(Slot).ObjIndex).IndexAbierta
                Call QuitarUserInvItem(UserIndex, Slot, 1)

                If Not MeterItemEnInventario(UserIndex, MiObj) Then
                    Call TirarItemAlPiso(.Pos, MiObj)

                End If
                
                Call UpdateUserInv(False, UserIndex, Slot)
            
            Case eOBJType.otBotellaLlena

                If .flags.Muerto = 1 Then
                    'Call WriteConsoleMsg(UserIndex, "Estas muerto!! Solo puedes usar items cuando estas vivo.", FontTypeNames.FONTTYPE_INFO)
                    Call WriteMultiMessage(UserIndex, eMessages.UserMuerto)
                    Exit Sub

                End If

                .Stats.MinAGU = .Stats.MinAGU + Obj.MinSed

                If .Stats.MinAGU > .Stats.MaxAGU Then .Stats.MinAGU = .Stats.MaxAGU
                .flags.Sed = 0
                Call WriteUpdateHungerAndThirst(UserIndex)
                MiObj.Amount = 1
                MiObj.ObjIndex = ObjData(.Invent.Object(Slot).ObjIndex).IndexCerrada
                Call QuitarUserInvItem(UserIndex, Slot, 1)

                If Not MeterItemEnInventario(UserIndex, MiObj) Then
                    Call TirarItemAlPiso(.Pos, MiObj)

                End If
                
                Call UpdateUserInv(False, UserIndex, Slot)
            
            Case eOBJType.otPergaminos

                If .flags.Muerto = 1 Then
                    'Call WriteConsoleMsg(UserIndex, "Estas muerto!! Solo puedes usar items cuando estas vivo.", FontTypeNames.FONTTYPE_INFO)
                    Call WriteMultiMessage(UserIndex, eMessages.UserMuerto)
                    Exit Sub

                End If
                
                If .Stats.MaxMAN > 0 Then
                    If .flags.Hambre = 0 And .flags.Sed = 0 Then
                        Call AgregarHechizo(UserIndex, Slot)
                        Call UpdateUserInv(False, UserIndex, Slot)
                    Else
                        Call WriteConsoleMsg(UserIndex, "Estas demasiado hambriento y sediento.", FontTypeNames.FONTTYPE_INFO)

                    End If

                Else
                    Call WriteConsoleMsg(UserIndex, "No tienes conocimientos de las Artes Arcanas.", FontTypeNames.FONTTYPE_INFO)

                End If

            Case eOBJType.otMinerales

                If .flags.Muerto = 1 Then
                    'Call WriteConsoleMsg(UserIndex, "Estas muerto!! Solo puedes usar items cuando estas vivo.", FontTypeNames.FONTTYPE_INFO)
                    Call WriteMultiMessage(UserIndex, eMessages.UserMuerto)
                    Exit Sub

                End If

                Call WriteMultiMessage(UserIndex, eMessages.WorkRequestTarget, FundirMetal) 'Call WriteWorkRequestTarget(UserIndex, FundirMetal)
               
            Case eOBJType.otInstrumentos

                If .flags.Muerto = 1 Then
                    'Call WriteConsoleMsg(UserIndex, "Estas muerto!! Solo puedes usar items cuando estas vivo.", FontTypeNames.FONTTYPE_INFO)
                    Call WriteMultiMessage(UserIndex, eMessages.UserMuerto)
                    Exit Sub

                End If
                
                If Obj.Real Then 'Es el Cuerno Real?
                    If FaccionPuedeUsarItem(UserIndex, ObjIndex) Then
                        If MapInfo(.Pos.Map).Pk = False Then
                            Call WriteConsoleMsg(UserIndex, "No hay peligro aqui. Es zona segura.", FontTypeNames.FONTTYPE_INFO)
                            Exit Sub

                        End If
                        
                        ' Los admin invisibles solo producen sonidos a si mismos
                        If .flags.AdminInvisible = 1 Then
                            Call EnviarDatosASlot(UserIndex, PrepareMessagePlayWave(Obj.Snd1, .Pos.x, .Pos.y))
                        Else
                            Call AlertarFaccionarios(UserIndex)
                            Call SendData(SendTarget.toMap, .Pos.Map, PrepareMessagePlayWave(Obj.Snd1, .Pos.x, .Pos.y))

                        End If
                        
                        Exit Sub
                    Else
                        Call WriteConsoleMsg(UserIndex, "Solo miembros del ejercito real pueden usar este cuerno.", FontTypeNames.FONTTYPE_INFO)
                        Exit Sub

                    End If

                ElseIf Obj.Caos Then 'Es el Cuerno Legion?

                    If FaccionPuedeUsarItem(UserIndex, ObjIndex) Then
                        If MapInfo(.Pos.Map).Pk = False Then
                            Call WriteConsoleMsg(UserIndex, "No hay peligro aqui. Es zona segura.", FontTypeNames.FONTTYPE_INFO)
                            Exit Sub

                        End If
                        
                        ' Los admin invisibles solo producen sonidos a si mismos
                        If .flags.AdminInvisible = 1 Then
                            Call EnviarDatosASlot(UserIndex, PrepareMessagePlayWave(Obj.Snd1, .Pos.x, .Pos.y))
                        Else
                            Call AlertarFaccionarios(UserIndex)
                            Call SendData(SendTarget.toMap, .Pos.Map, PrepareMessagePlayWave(Obj.Snd1, .Pos.x, .Pos.y))

                        End If
                        
                        Exit Sub
                    Else
                        Call WriteConsoleMsg(UserIndex, "Solo miembros de la legion oscura pueden usar este cuerno.", FontTypeNames.FONTTYPE_INFO)
                        Exit Sub

                    End If

                End If

                'Si llega aca es porque es o Laud o Tambor o Flauta
                ' Los admin invisibles solo producen sonidos a si mismos
                If .flags.AdminInvisible = 1 Then
                    Call EnviarDatosASlot(UserIndex, PrepareMessagePlayWave(Obj.Snd1, .Pos.x, .Pos.y))
                Else
                    Call SendData(SendTarget.ToPCArea, UserIndex, PrepareMessagePlayWave(Obj.Snd1, .Pos.x, .Pos.y))

                End If
               
            Case eOBJType.otBarcos

                'Verifica si esta aproximado al agua antes de permitirle navegar
                If .Stats.ELV < 25 Then

                    ' Solo pirata y trabajador pueden navegar antes
                    If .clase <> eClass.Worker And .clase <> eClass.Pirat Then
                        Call WriteConsoleMsg(UserIndex, "Para recorrer los mares debes ser nivel 25 o superior.", FontTypeNames.FONTTYPE_INFO)
                        Exit Sub
                    Else

                        ' Pero a partir de 20
                        If .Stats.ELV < 20 Then
                            
                            If .clase = eClass.Worker And .Stats.UserSkills(eSkill.Pesca) <> 100 Then
                                Call WriteConsoleMsg(UserIndex, "Para recorrer los mares debes ser nivel 20 y ademas tu skill en pesca debe ser 100.", FontTypeNames.FONTTYPE_INFO)
                            Else
                                Call WriteConsoleMsg(UserIndex, "Para recorrer los mares debes ser nivel 20 o superior.", FontTypeNames.FONTTYPE_INFO)

                            End If
                            
                            Exit Sub
                        Else

                            ' Esta entre 20 y 25, si es trabajador necesita tener 100 en pesca
                            If .clase = eClass.Worker Then
                                If .Stats.UserSkills(eSkill.Pesca) <> 100 Then
                                    Call WriteConsoleMsg(UserIndex, "Para recorrer los mares debes ser nivel 20 o superior y ademas tu skill en pesca debe ser 100.", FontTypeNames.FONTTYPE_INFO)
                                    Exit Sub

                                End If

                            End If

                        End If

                    End If

                End If
                
                If ((LegalPos(.Pos.Map, .Pos.x - 1, .Pos.y, True, False) Or LegalPos(.Pos.Map, .Pos.x, .Pos.y - 1, True, False) Or LegalPos(.Pos.Map, .Pos.x + 1, .Pos.y, True, False) Or LegalPos(.Pos.Map, .Pos.x, .Pos.y + 1, True, False)) And .flags.Navegando = 0) Or .flags.Navegando = 1 Then
                    Call DoNavega(UserIndex, Obj, Slot)
                Else
                    Call WriteConsoleMsg(UserIndex, "Debes aproximarte al agua para usar el barco!", FontTypeNames.FONTTYPE_INFO)

                End If
                
            Case eOBJType.otManuales
            
                Select Case ObjIndex
                
                    Case 1127   ' Manual de Liderazgo
                        
                        If .Stats.UserSkills(eSkill.Liderazgo) < 100 Then
                            .Stats.UserSkills(eSkill.Liderazgo) = 100
                            Call QuitarUserInvItem(Userindex, Slot, 1)
                            Call UpdateUserInv(False, Userindex, Slot)
                        End If
                        
                    Case 1128   ' Manual de Supervivencia
                        
                        If .Stats.UserSkills(eSkill.Supervivencia) < 100 Then
                            .Stats.UserSkills(eSkill.Supervivencia) = 100
                            Call QuitarUserInvItem(Userindex, Slot, 1)
                            Call UpdateUserInv(False, Userindex, Slot)
                        End If
                        
                    Case 1129   ' Manual de Navegacion
                        
                        If .Stats.UserSkills(eSkill.Navegacion) < 100 Then
                            .Stats.UserSkills(eSkill.Navegacion) = 100
                            Call QuitarUserInvItem(Userindex, Slot, 1)
                            Call UpdateUserInv(False, Userindex, Slot)
                        End If
                        
                End Select
                
        End Select
    
    End With

End Sub

Sub EnivarArmasConstruibles(ByVal UserIndex As Integer)
    '***************************************************
    'Author: Unknown
    'Last Modification: -
    '
    '***************************************************

    Call WriteBlacksmithWeapons(UserIndex)

End Sub
 
Sub EnivarObjConstruibles(ByVal UserIndex As Integer)
    '***************************************************
    'Author: Unknown
    'Last Modification: -
    '
    '***************************************************

    Call WriteCarpenterObjects(UserIndex)

End Sub

Sub EnivarArmadurasConstruibles(ByVal UserIndex As Integer)
    '***************************************************
    'Author: Unknown
    'Last Modification: -
    '
    '***************************************************

    Call WriteBlacksmithArmors(UserIndex)

End Sub

Sub TirarTodo(ByVal UserIndex As Integer)
    '***************************************************
    'Author: Unknown
    'Last Modification: -
    '
    '***************************************************

    On Error GoTo errHandler

    With UserList(UserIndex)

        If MapData(.Pos.Map, .Pos.x, .Pos.y).trigger = 6 Then Exit Sub
        
        Call TirarTodosLosItems(UserIndex)
        
        Dim Cantidad As Long: Cantidad = .Stats.Gld - CLng(.Stats.ELV) * 10000
       
        ' Si estas en zona segura tampoco se tira el oro.
        If MapInfo(.Pos.Map).Pk Then
            
            If Cantidad > 0 Then
                Call TirarOro(Cantidad, UserIndex)
            End If
            
        End If
        
    End With

    Exit Sub

errHandler:
    Call LogError("Error en TirarTodo. Error: " & Err.Number & " - " & Err.description)

End Sub

Public Function ItemSeCae(ByVal index As Integer) As Boolean
    '***************************************************
    'Author: Unknown
    'Last Modification: -
    '
    '***************************************************

    With ObjData(index)
        ItemSeCae = (.Real <> 1 Or .NoSeCae = 0) And (.Caos <> 1 Or .NoSeCae = 0) And .OBJType <> eOBJType.otLlaves And .OBJType <> eOBJType.otBarcos And .NoSeCae = 0

    End With

End Function

Sub TirarTodosLosItems(ByVal UserIndex As Integer)

    '***************************************************
    'Author: Unknown
    'Last Modification: 12/01/2010 (ZaMa)
    '12/01/2010: ZaMa - Ahora los piratas no explotan items solo si estan entre 20 y 25
    '***************************************************
    On Error GoTo errHandler

    Dim i         As Byte

    Dim NuevaPos  As WorldPos

    Dim MiObj     As Obj

    Dim ItemIndex As Integer

    Dim DropAgua  As Boolean
    
    With UserList(UserIndex)

        For i = 1 To .CurrentInventorySlots
            ItemIndex = .Invent.Object(i).ObjIndex

            If ItemIndex > 0 Then
                If ItemSeCae(ItemIndex) Then
                    NuevaPos.x = 0
                    NuevaPos.y = 0
                    
                    'Creo el Obj
                    MiObj.Amount = .Invent.Object(i).Amount
                    MiObj.ObjIndex = ItemIndex

                    DropAgua = True

                    ' Es pirata?
                    If .clase = eClass.Pirat Then

                        ' Si tiene galeon equipado
                        If .Invent.BarcoObjIndex = 476 Then

                            ' Limitacion por nivel, despues dropea normalmente
                            If .Stats.ELV = 20 Then
                                ' No dropea en agua
                                DropAgua = False

                            End If

                        End If

                    End If
                    
                    Call Tilelibre(.Pos, NuevaPos, MiObj, DropAgua, True)
                    
                    If NuevaPos.x <> 0 And NuevaPos.y <> 0 Then
                        Call DropObj(UserIndex, i, MAX_INVENTORY_OBJS, NuevaPos.Map, NuevaPos.x, NuevaPos.y)

                    End If

                End If

            End If

        Next i

    End With
    
    Exit Sub
    
errHandler:
    Call LogError("Error en TirarTodosLosItems. Error: " & Err.Number & " - " & Err.description)

End Sub

Function ItemNewbie(ByVal ItemIndex As Integer) As Boolean
    '***************************************************
    'Author: Unknown
    'Last Modification: -
    '
    '***************************************************

    If ItemIndex < 1 Or ItemIndex > UBound(ObjData) Then Exit Function
    
    ItemNewbie = ObjData(ItemIndex).Newbie = 1

End Function

Sub TirarTodosLosItemsNoNewbies(ByVal UserIndex As Integer)

    '***************************************************
    'Author: Unknown
    'Last Modification: 23/11/2009
    '07/11/09: Pato - Fix bug #2819911
    '23/11/2009: ZaMa - Optimizacion de codigo.
    '***************************************************
    Dim i         As Byte

    Dim NuevaPos  As WorldPos

    Dim MiObj     As Obj

    Dim ItemIndex As Integer
    
    With UserList(UserIndex)

        If MapData(.Pos.Map, .Pos.x, .Pos.y).trigger = 6 Then Exit Sub
        
        For i = 1 To UserList(UserIndex).CurrentInventorySlots
            ItemIndex = .Invent.Object(i).ObjIndex

            If ItemIndex > 0 Then
                If ItemSeCae(ItemIndex) And Not ItemNewbie(ItemIndex) Then
                    NuevaPos.x = 0
                    NuevaPos.y = 0
                    
                    'Creo MiObj
                    MiObj.Amount = .Invent.Object(i).Amount
                    MiObj.ObjIndex = ItemIndex
                    'Pablo (ToxicWaste) 24/01/2007
                    'Tira los Items no newbies en todos lados.
                    Tilelibre .Pos, NuevaPos, MiObj, True, True

                    If NuevaPos.x <> 0 And NuevaPos.y <> 0 Then
                        Call DropObj(UserIndex, i, MAX_INVENTORY_OBJS, NuevaPos.Map, NuevaPos.x, NuevaPos.y)

                    End If

                End If

            End If

        Next i

    End With

End Sub

Sub TirarTodosLosItemsEnMochila(ByVal UserIndex As Integer)

    '***************************************************
    'Author: Unknown
    'Last Modification: 12/01/09 (Budi)
    '***************************************************
    Dim i         As Byte

    Dim NuevaPos  As WorldPos

    Dim MiObj     As Obj

    Dim ItemIndex As Integer
    
    With UserList(UserIndex)

        If MapData(.Pos.Map, .Pos.x, .Pos.y).trigger = 6 Then Exit Sub
        
        For i = MAX_NORMAL_INVENTORY_SLOTS + 1 To .CurrentInventorySlots
            ItemIndex = .Invent.Object(i).ObjIndex

            If ItemIndex > 0 Then
                If ItemSeCae(ItemIndex) Then
                    NuevaPos.x = 0
                    NuevaPos.y = 0
                    
                    'Creo MiObj
                    MiObj.Amount = .Invent.Object(i).Amount
                    MiObj.ObjIndex = ItemIndex
                    Tilelibre .Pos, NuevaPos, MiObj, True, True

                    If NuevaPos.x <> 0 And NuevaPos.y <> 0 Then
                        Call DropObj(UserIndex, i, MAX_INVENTORY_OBJS, NuevaPos.Map, NuevaPos.x, NuevaPos.y)

                    End If

                End If

            End If

        Next i

    End With

End Sub

Public Function getObjType(ByVal ObjIndex As Integer) As eOBJType
    '***************************************************
    'Author: Unknown
    'Last Modification: -
    '
    '***************************************************

    If ObjIndex > 0 Then
        getObjType = ObjData(ObjIndex).OBJType

    End If
    
End Function

Public Sub moveItem(ByVal UserIndex As Integer, _
                    ByVal originalSlot As Integer, _
                    ByVal newSlot As Integer)

    Dim tmpObj      As UserObj

    Dim newObjIndex As Integer, originalObjIndex As Integer

    If (originalSlot <= 0) Or (newSlot <= 0) Then Exit Sub

    With UserList(UserIndex)

        If (originalSlot > .CurrentInventorySlots) Or (newSlot > .CurrentInventorySlots) Then Exit Sub
    
        tmpObj = .Invent.Object(originalSlot)
        .Invent.Object(originalSlot) = .Invent.Object(newSlot)
        .Invent.Object(newSlot) = tmpObj
    
        'Viva VB6 y sus putas deficiencias.
        If .Invent.AnilloEqpSlot = originalSlot Then
            .Invent.AnilloEqpSlot = newSlot
        ElseIf .Invent.AnilloEqpSlot = newSlot Then
            .Invent.AnilloEqpSlot = originalSlot

        End If
    
        If .Invent.ArmourEqpSlot = originalSlot Then
            .Invent.ArmourEqpSlot = newSlot
        ElseIf .Invent.ArmourEqpSlot = newSlot Then
            .Invent.ArmourEqpSlot = originalSlot

        End If
    
        If .Invent.BarcoSlot = originalSlot Then
            .Invent.BarcoSlot = newSlot
        ElseIf .Invent.BarcoSlot = newSlot Then
            .Invent.BarcoSlot = originalSlot

        End If
    
        If .Invent.CascoEqpSlot = originalSlot Then
            .Invent.CascoEqpSlot = newSlot
        ElseIf .Invent.CascoEqpSlot = newSlot Then
            .Invent.CascoEqpSlot = originalSlot

        End If
    
        If .Invent.EscudoEqpSlot = originalSlot Then
            .Invent.EscudoEqpSlot = newSlot
        ElseIf .Invent.EscudoEqpSlot = newSlot Then
            .Invent.EscudoEqpSlot = originalSlot

        End If
    
        If .Invent.MochilaEqpSlot = originalSlot Then
            .Invent.MochilaEqpSlot = newSlot
        ElseIf .Invent.MochilaEqpSlot = newSlot Then
            .Invent.MochilaEqpSlot = originalSlot

        End If
    
        If .Invent.MunicionEqpSlot = originalSlot Then
            .Invent.MunicionEqpSlot = newSlot
        ElseIf .Invent.MunicionEqpSlot = newSlot Then
            .Invent.MunicionEqpSlot = originalSlot

        End If
    
        If .Invent.WeaponEqpSlot = originalSlot Then
            .Invent.WeaponEqpSlot = newSlot
        ElseIf .Invent.WeaponEqpSlot = newSlot Then
            .Invent.WeaponEqpSlot = originalSlot

        End If

        Call UpdateUserInv(False, UserIndex, originalSlot)
        Call UpdateUserInv(False, UserIndex, newSlot)

    End With

End Sub
