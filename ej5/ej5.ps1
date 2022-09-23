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
        $DatosMateria = $DescMateria, $DepartamentoMat

        if(($IDMateria -match "^\d+$") -And ($DepartamentoMat -match "^\d+$")){
            if(!$materias.ContainsKey($IDMateria)){
                $materias.Add($IDMateria, $DatosMateria)
                $CONTENIDODEPARTAMENTOSARCH+="$lineaM" 
                Write-Host "Materia con ID $IDMateria agregada"

                Write-Host "Materia: $IDMateria; Datos: $DatosMateria"
            }
        }
    }
}

if($materias.Count -eq 0){
    Write-Host "El archivo $rutaMaterias no contiene datos válidos."
}else{
    #Get-Content $CONTENIDODEPARTAMENTOSARCH | Sort-Object
    $resTemp = @()
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
            $resTemp+= $nota
        }
    } 

    $resTemp = $resTemp | Sort-Object -Property IDMatAlum

    $FINALES = 0
    $RECURSAN = 0
    $ABANDONAN = 0
    $PROMOCIONAN = 0

    $materiaAnterior = $resTemp[0].IDMatAlum

    # foreach ($temp in $resTemp) {
        
    # }

}
    


