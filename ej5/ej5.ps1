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

Write-Host "Iniciando"

$rutaNotas = Resolve-Path $rutaNotas
$rutaMaterias = Resolve-Path $rutaMaterias

$lineasNotas = Get-Content $rutaNotas 
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
            }
        }
    }
}

if($materias.Count -eq 0){
    Write-Host "El archivo $rutaMaterias no contiene datos válidos."
}else{
    
}
    


