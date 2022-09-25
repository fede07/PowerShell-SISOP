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

    Nota([int]$DNIAlum_ ,[int]$IDMatAlum_, [int]$Parcial1_, [int]$Parcial2_, [int]$Recu_, [int]$final_){

        $this.DNIAlum = $DNIAlum_
        $this.IDMatAlum =$IDMatAlum_
        $this.Parcial1 = $Parcial1_
        $this.Parcial2 = $Parcial2_
        $this.Recu = $Recu_
        $this.Final = $final_
    }

    [string]printNota(){
        return "DNI: $($this.DNIAlum) | Materia: $($this.IDMatAlum) | P1: $($this.Parcial1) | P2: $($this.Parcial2)| R: $($this.Recu) | F: $($this.Final)"
    }

}
#
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

    [int]getDesc(){
        return $this.DescMateria
    }

}

class MateriaStats{
    [int]$IDMateria
    [string]$nombreMat
    [int]$IDDep
    [int]$FINALES
    [int]$RECURSAN
    [int]$ABANDONAN
    [int]$PROMOCIONAN

    MateriaStats([int]$IDMateria_, [string]$nombreMat_,[int]$IDDep_, [int]$FINALES_, [int]$RECURSAN_, [int]$ABANDONAN_, [int]$PROMOCIONAN_){
        $this.IDMateria = $IDMateria_
        $this.nombreMat = $nombreMat_
        $this.IDDep = $IDDep_
        $this.FINALES = $FINALES_
        $this.RECURSAN = $RECURSAN_
        $this.ABANDONAN = $ABANDONAN_
        $this.PROMOCIONAN = $PROMOCIONAN_
    }

    [string]printDatos(){
        return "
        IDMateria: $($this.IDMateria)
        Descripcion: $($this.nombreMat)
        Departamento: $($this.IDDep)
        Finales: $($this.FINALES)
        Recursan: $($this.RECURSAN)
        Abandonan: $($this.ABANDONAN)
        Promocionan: $($this.PROMOCIONAN)
        "
    }

}   

Write-Host "Iniciando"

$rutaNotas = Resolve-Path $rutaNotas
$rutaMaterias = Resolve-Path $rutaMaterias

#obtengo los datos del archivo notas, skipeo la primera linea
$archivoNotas = Get-Content $rutaNotas | Select-Object -Skip 1 
#obtengo los datos del archivo materias, skipeo la primera linea
$archivoMaterias = Get-Content $rutaMaterias | Select-Object -Skip 1

$listaMaterias =@()
$auxMaterias =@{}
#$CONTENIDODEPARTAMENTOSARCH=""

#Recupero los datos de las materias:
#Por cada linea en el archivo Materias:

Write-Output "
Obteniendo datos materias
"
foreach ($lineaM in $archivoMaterias) {
    if($lineaM){ #si no esta vacia:
        $IDMateria = ($lineaM -Split {$_ -eq "|"})[0] #Obtengo el contenido de la columna ID
        $DescMateria = ($lineaM -Split {$_ -eq "|"})[1] #Obtengo el contenido de la columna DESCRIPCION
        $DepartamentoMat = ($lineaM -Split {$_ -eq "|"})[2] #Obtengo el contenido de la columna DEPARTAMENTO
        
        if(($IDMateria -match "^\d+$") -And ($DepartamentoMat -match "^\d+$")){ #Si las columnas ID y Departamento son validos:
            #Si no esta en el hash table de todas las materias:
            #if(!$listaMaterias.Contains($IDMateria)){ 
            if(!$auxMaterias.Contains($IDMateria)){
                # Creo un hash table con los datos de la materia, es usada como un objeto "materia"
                $materiaDatos = @{
                    ID = $IDMateria; 
                    Descripcion = $DescMateria; 
                    Departamento = $DepartamentoMat
                }

                $materia = [Materia]::new($IDMateria, $DescMateria, $DepartamentoMat)

                #La agrego a la hash table de materias con la key ID
                #$materias.Add($IDMateria, $materiaDatos)

                $listaMaterias += $materia
                $auxMaterias.Add($IDMateria, $materiaDatos)
            }
        }
    }
}

$listaMaterias = $listaMaterias | Sort-Object -Property DepartamentoMat

foreach ($currentItemName in $listaMaterias) {
    $currentItemName.printMateria()
}

Write-Output "
Tabla de materias:
"
$auxMaterias.GetEnumerator() | Sort-Object -Property Key

if($listaMaterias.Count -eq 0){ #Si la tabla de materias esta vacia, el archivo es invalido
    Write-Host "El archivo $rutaMaterias no contiene datos válidos."
}else{
   
    #Get-Content $CONTENIDODEPARTAMENTOSARCH | Sort-Object
    $listaNotas = @() #creo la lista de notas de alumnos

    Write-Output "
    Obteniendo datos de archivo notas
    "

    #por cada linea en el archivo Notas
    foreach ($lineaN in $archivoNotas) { 
        $DNIAlum = ($lineaN -split {$_ -eq "|"})[0] 
        $IDMatAlum = ($lineaN -split {$_ -eq "|"})[1]
        #veo si en la tabla de materias existe la materia del alumno actual.
        if($auxMaterias.ContainsKey($IDMatAlum)){
            $Parcial1 = ($lineaN -split {$_ -eq "|"})[2]
            $Parcial2 = ($lineaN -split {$_ -eq "|"})[3]
            $Recu = ($lineaN -split {$_ -eq "|"})[4]
            $Final = ($lineaN -split {$_ -eq "|"})[5]
            
            #"$listaNotas" contiene cada linea del archivo notas convertida en un objeto "nota"
            $nota = [Nota]::new($DNIAlum, $IDMatAlum, $Parcial1, $Parcial2, $Recu, $Final)
            $listaNotas+= $nota

            #si llega aca los numeros son validos, pero podrian no tener sentido
		    #ej: nota final sin notas de parciales

        }
    } 

    $listaNotas = $listaNotas | Sort-Object -Property IDMatAlum #ordeno la lista de notas segun el ID de materia

    foreach ($notaA in $listaNotas) {
        $notaA.printNota()
    }
    
    #contadores para los resultados de cada materia
    $FINALES = 0
    $RECURSAN = 0
    $ABANDONAN = 0
    $PROMOCIONAN = 0

    #variable para corte control
    #levanto el idMat del primer registro
    $materiaAnterior = $listaNotas[0].IDMatAlum

    Write-Output "
    Materia Inicial a procesar: $materiaAnterior
    "

    #mapa que contiene los resultados de cada materia
    $mapaAlumnos =@()

    $aux


    foreach ($temp in $listaNotas) {
        #$help = $temp.IDMatAlum
        #Write-Output "Materia anterior: $materiaAnterior, Materia Actual: $help"
        if($materiaAnterior -ne $temp.IDMatAlum){ #Cambio de ID, reseteo materia
            # Write-Output "Materia a agregar al "mapa": $materiaAnterior"

            $aux = [string]$materiaAnterior
            $idMat = [string]$auxMaterias[$aux]['ID']
            $desc = [string]$auxMaterias[$aux]['Descripcion']
            $depto = [string]$auxMaterias[$aux]['Departamento']

            $materiaProcesada = [MateriaStats]::new($idMat, $desc, $depto, $FINALES, $RECURSAN, $ABANDONAN, $PROMOCIONAN)
            $materiaProcesada.printDatos()
            $mapaAlumnos += $materiaProcesada

            # $aux = "$FINALES $RECURSAN $ABANDONAN $PROMOCIONAN"
            # $mapaAlumnos[$materiaAnterior] = [string]$aux

            # $aux = [string]$temp.IDMatAlum
            # $idMat = [string]$materias[$aux]['ID']
            # $desc = [string]$materias[$aux]['Descripcion']
            # $depto = [string]$materias[$aux]['Departamento']
            # $materiaNotas = @{
            #     id_materia = $idMat; 
            #     descripcion = $desc;
            #     departamento = $depto;
            #     final = $FINALES;
            #     recursan = $RECURSAN;
            #     abandonan = $ABANDONAN;
            #     promocionan = $PROMOCIONAN
            # }
            #$mapaAlumnos.Add($idMat, $materiaNotas)

            $FINALES = 0
            $RECURSAN = 0
            $ABANDONAN = 0
            $PROMOCIONAN = 0
            $materiaAnterior = $temp.IDMatAlum
        }

        Write-Output "
        Nota Actual:"
        $temp.printNota()
        Write-Output ""

        $nota1 = 0 #1 o 2 da igual, no se refiere a que parcial hace referencia, el recuperatorio pisa la que corresponda
        $nota2 = 0

        if($temp.Parcial1 -gt 0){
            $nota1 = $temp.Parcial1
        }
        if($temp.Parcial2 -gt 0){
            $nota2 = $temp.Parcial2
        }
        if($temp.Recu -gt 0){
            if($nota1 -gt $nota2){
                $nota2 = $temp.Recu
            }else{
                $nota1 = $temp.Recu
            }
        }

        Write-Output "Nota1: $nota1 | Nota2: $nota2"

        if( (($nota1 -eq 0) -or ($nota2 -eq 0)) -and ($temp.Final -ne 0)){
            Write-Output "Alumno erroneo"
            #es un error de los indicados en la cadena de ifs al procesar ARCHIVO
        }elseif ( (($nota1 -lt 7) -or ($nota2 -lt 7)) -and (($nota1 -gt 3) -and ($nota2 -gt 3))) {
            #si esta en condicion de rendir final (haya rendido o no)
            if($temp.Final -eq 0){
                #si no hay nota de final
                $FINALES++
                Write-Output "A final con nota: $($temp.Final)"
            }else{
                if($temp.Final -lt 3){
                    $RECURSAN++
                    Write-Output "Recursa"
                }
                #else aprueba el final
            }
        }elseif(($nota1 -gt 6) -and ($nota2 -gt 6)){
            $PROMOCIONAN++
            Write-Output "Promocionado"
        }elseif(($nota1 -eq 0) -or ($nota2 -eq 0)){
            $ABANDONAN++
            Write-Output "Abandono"
        }else{
            $RECURSAN++
            Write-Output "Recursa"
        }

        $aux = [string]$temp.IDMatAlum
    }

    if(($FINALES -ne 0) -or ($RECURSAN -ne 0) -or ($ABANDONAN -ne 0) -or ($PROMOCIONAN -ne 0)){

        $idMat = [string]$auxMaterias[$aux]['ID']
        $desc = [string]$auxMaterias[$aux]['Descripcion']
        $depto = [string]$auxMaterias[$aux]['Departamento']

        $materiaProcesada = [MateriaStats]::new($idMat, $desc, $depto, $FINALES, $RECURSAN, $ABANDONAN, $PROMOCIONAN)
        $materiaProcesada.printDatos()
        $mapaAlumnos += $materiaProcesada

        # $aux = "$FINALES $RECURSAN $ABANDONAN $PROMOCIONAN"
        # $mapaAlumnos[$materiaAnterior] = [string]$aux

    }


    Write-Output "DEBUG1"

    if($mapaAlumnos.Count -eq 0){
        Write-Output "El archivo $rutaNotas no contiene datos válidos"
    }else{

        $listaMaterias = $listaMaterias | Sort-Object -Property IDMateria
        $mapaAlumnos = $mapaAlumnos | Sort-Object -Property IDDep

        $departamentoAnt = -1
        $json="{         
    `"departamentos"": ["
        
        $primeraVez=1
        $cont=0
        foreach ($datosMateria in $listaMaterias) {

            $idDep=$datosMateria.IDMateria
            Write-Output "$idDep"

            
            while ($mapaAlumnos[$cont].IDDep -lt $idDep) {
                $cont++
            }
            
            if($mapaAlumnos[$cont].IDDep -lt $idDep)

            if($primeraVez -eq 0){
                if($idDep -ne $departamentoAnt){
                    $json+="
                }"
                }else{
                    $json+="
                },"
                }
            }
            if($idDep -ne $departamentoAnt){
                if($primeraVez -eq 0){
                    $json+="            
            ]
        },"
                }
                $primeraVez=0
                $json+="        
        {
            `"id`": $idDep,
            `"notas`": ["
            }
            $departamentoAnt = $idDep
            if($idDep -eq $departamentoAnt){

                $idMat=$datosMateria.IDMateria
                $descr=$datosMateria.nombreMat
                $final=$datosMateria.FINALES
                $rec=$datosMateria.RECURSAN
                $ab=$datosMateria.ABANDONAN
                $prom=$datosMateria.PROMOCIONAN

                $json+="
                `"id_materia`": $idMat,
                `"descripcion`": `"$descr`",
                `"final`": `"$final`",
                `"recursan`": `"$rec`",
                `"abandonaron`": `"$ab`",
                `"promocionaron`": `"$prom`""
            }
            
            $aux=$datosMateria
        }

        $json+="
                }       
            ]
        }
    ]
}"
        Write-Output "
        Archivo JSON:
        "
        Write-Output "$json"

        
    }



}
    


