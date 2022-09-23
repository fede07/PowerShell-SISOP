# =========================== Encabezado ========================

# Nombre del Script: ej5.ps1
# Número de APL: 2
# Número de Ejercicio: 5
# Número de Entrega: Entrega

# ===============================================================

# ------------------------ Integrantes ------------------------ #
#
#        Nombre      |        Apellido          |      DNI
#        Gianluca    |        Espíndola         |   38.585.140
#        Juan        |        Diaz              |   38.958.153
#        Micaela     |        Dato Firpo        |   39.830.964
#        Melina      |        Sanson            |   42.362.352
#        Federico    |        Rossendy          |   37.804.899
#
# ------------------------------------------------------------- #

# ----------------------------- Ayuda ------------------------- #

<#
.SYNOPSIS
    A short description of your script.
.DESCRIPTION
    A longer description of your script.
.PARAMETER <-silent>
    First parameter is -silent. It will do Collection Bootstrap silently.  
.PARAMETER <action>
    Second parameter is action. Action could be either bootstrap or join
.EXAMPLE
    Example
#>

Param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({
        if( -Not (Test-Path -Path $_) ){
            throw "Error: La ruta '$_' no existe."
        }
        return $true
    })]
    [String] $rutaNotas,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({
        if( -Not (Test-Path -Path $_) ){
            throw "Error: La ruta '$_' no existe."
        }
        return $true
    })]
    [String] $rutaMaterias
)

class Nota {
    [int]$DNIAlum
    [int]$IDMatAlum
    [int]$Parcial1
    [int]$Parcial2
    [int]$Recu
    [int]$Final

    Nota() {}

    Nota([String]$DNIAlum_ ,[String]$IDMatAlum_, [String]$Parcial1_, [String]$Parcial2_, [String]$Recu_, [String]$final_){

        $this.DNIAlum = [int]$DNIAlum_
        $this.IDMatAlum =[int]$IDMatAlum_
        $this.Parcial1 = [int]$Parcial1_
        $this.Parcial2 = [int]$Parcial2_
        $this.Recu = [int]$Recu_
        $this.Final = [int]$final_
    }

    [string]printNota(){
        $DNIAlum_ = $this.DNIAlum
        $IDMatAlum_ = $this.IDMatAlum
        $Parcial1_ = $this.Parcial1
        $Parcial2_ = $this.Parcial2
        $Recu_ = $this.Recu
        $Final_ = $this.Final

        return "$DNIAlum_ | $IDMatAlum_ | $Parcial1_ | $Parcial2_ | $Recu_ | $Final_"
    }

}

class Materia{
    [int]$IDMateria
    [String]$DescMateria
    [int]$DepartamentoMat

    Materia([int]$IDMateria_, [string]$DescMateria_, [int]$DepartamentoMat){
        $this.IDMateria = $IDMateria_
        $this.DescMateria = $DescMateria_
        $this.DepartamentoMat = $DepartamentoMat
    }

    [string]printMateria(){
        return "$($this.IDMateria) | $($this.DescMateria) | $($this.DepartamentoMat)"
    }

}

class MateriaStats{
    [int]$IDMateria
    [string]$nombreMat
    [int]$FINALES
    [int]$RECURSAN
    [int]$ABANDONAN
    [int]$PROMOCIONAN

    MateriaStats([int]$IDMateria_, [string]$nombreMat_, [int]$FINALES_, [int]$RECURSAN_, [int]$ABANDONAN_, [int]$PROMOCIONAN_){
        $this.IDMateria = $IDMateria_
        $this.nombreMat = $nombreMat_
        $this.FINALES = $FINALES_
        $this.RECURSAN = $RECURSAN_
        $this.ABANDONAN = $ABANDONAN_
        $this.PROMOCIONAN = $PROMOCIONAN_
    }

}   



Write-Host "Iniciando"

$rutaNotas = Resolve-Path $rutaNotas
$rutaMaterias = Resolve-Path $rutaMaterias

$lineasNotas = Get-Content $rutaNotas | Select-Object -Skip 1 
$lineasMaterias = Get-Content $rutaMaterias | Select-Object -Skip 1 

$materias =@{}
$CONTENIDODEPARTAMENTOSARCH=""

foreach ($lineaM in $lineasMaterias ) {
    if($lineaM){
        $IDMateria = ($lineaM -Split {$_ -eq "|"})[0]
        $DescMateria = ($lineaM -Split {$_ -eq "|"})[1]
        $DepartamentoMat = ($lineaM -Split {$_ -eq "|"})[2]
        

        if(($IDMateria -match "^\d+$") -And ($DepartamentoMat -match "^\d+$")){
            if(!$materias.ContainsKey($IDMateria)){
                $DatosMateria = [Materia]::new($IDMateria, $DescMateria, $DepartamentoMat)
                $materias.Add($IDMateria, $DatosMateria)
                
                # Write-Host "Materia con ID $IDMateria agregada"
                # Write-Host "Materia: $IDMateria; Datos: $($DatosMateria.printMateria())"
            }
        }
    }
}

if($materias.Count -eq 0){
    Write-Host "El archivo $rutaMaterias no contiene datos válidos."
}else{
    #Get-Content $CONTENIDODEPARTAMENTOSARCH | Sort-Object
    $notasAlumTemp = @()
    Write-Host "Entro al if"
    foreach ($lineaN in $lineasNotas) {
        $DNIAlum = ($lineaN -split {$_ -eq "|"})[0]
        $IDMatAlum = ($lineaN -split {$_ -eq "|"})[1]
        if($materias.Contains($IDMatAlum)){
            $Parcial1 = ($lineaN -split {$_ -eq "|"})[2]
            $Parcial2 = ($lineaN -split {$_ -eq "|"})[3]
            $Recu = ($lineaN -split {$_ -eq "|"})[4]
            $Final = ($lineaN -split {$_ -eq "|"})[5]
            
            $nota = [Nota]::new($DNIAlum, $IDMatAlum, $Parcial1, $Parcial2, $Recu, $Final)
            $notasAlumTemp+= $nota
        }
    } 

    $notasAlumTemp = $notasAlumTemp | Sort-Object -Property IDMatAlum

    # foreach ($notaA in $notasAlumTemp) {
    #     $notaA.printNota()
    #     Write-Output "SEPARADOR"
    # }

    $FINALES = 0
    $RECURSAN = 0
    $ABANDONAN = 0
    $PROMOCIONAN = 0

    $materiaAnterior = $notasAlumTemp[0].IDMatAlum

    $materiasStats =@{}

    foreach ($temp in $notasAlumTemp) {
        # Write-Output "Materia anterior: $materiaAnterior, Materia Actual: $($temp.IDMateria)"
        if($materiaAnterior -ne $temp.IDMatAlum){ #Cambio de ID, reseteo materia
            # Write-Output "Materia a agregar al mapa: $materiaAnterior"
            $materia = [MateriaStats]::new($temp.IDMatAlum, $materias.($temp.IDMatAlum).$DescMateria, $FINALES, $RECURSAN, $ABANDONAN, $PROMOCIONAN) 
            $materiasStats.Add($materia.IDMateria, $materia)
            $FINALES = 0
            $RECURSAN = 0
            $ABANDONAN = 0
            $PROMOCIONAN = 0
            $materiaAnterior = $temp.IDMatAlum
        }

        $nota1 = 0
        $nota2 = 0

        if($temp.Parcial1 -gt 0){
            $nota = $temp.Parcial1
        }
        if($temp.Parcial2 -gt 0){
            $nota = $temp.Parcial2
        }
        if($temp.Recu -gt 0){
            if($nota1 -gt $nota2){
                $nota2 = $temp.Recu
            }else{
                $nota1 = $temp.Recu
            }
        }

        if( (($nota1 -eq 0) -or ($nota2 -eq 0)) -and $temp.Final -eq 0){

        }elseif ( (($nota1 -lt 7) -or ($nota2 -lt 7)) -and (($nota1 -gt 3) -and ($nota2 -gt 3))) {
            if($temp.Final -ne 0){
                $FINALES++
            }else{
                if($temp.Final -lt 3){
                    $RECURSAN++
                }
            }
        }elseif(($nota1 -gt 6) -and ($nota2 -gt 6)){
            $PROMOCIONAN++
        }elseif(($nota1 -eq 0) -or ($nota2 -eq 0)){
            $ABANDONAN++
        }else{
            $RECURSAN++
        }
    }
    
    $materia = [MateriaStats]::new($materiaAnterior, $materias.($materiaAnterior).$DescMateria, $FINALES, $RECURSAN, $ABANDONAN, $PROMOCIONAN) 
    $materiasStats.Add($materia.IDMateria, $materia)

    if($materiasStats.Count -eq 0){
        Write-Output "El archivo $rutaNotas no contiene datos válidos"
    }

}
    


