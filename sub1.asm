.data
    msg_n:        .asciz "Ingrese la cantidad de temperaturas 'n': "
    msg_k:        .asciz "Ingrese el tamaño del bloque 'k': "
    msg_array:    .asciz "Ingrese las temperaturas como num1, num2,...: "
    msg_blocks:   .asciz "Bloques crecientes: "
    msg_trend:    .asciz "Tendencia detectada desde indice "
    msg_no_trend: .asciz "Sin tendencias detectadas"
    plus:         .asciz " -> "
    newline:      .asciz "\n"
    error_msg:    .asciz "Error: Formato de entrada inválido\n"
    
    buffer:       .space 256   # Buffer para almacenar la entrada del usuario
    temp_str:     .space 12    # Espacio temporal para cada número leído como string
    n:            .word 0
    k:            .word 0
    temperatures: .space 400   # Máximo 100 enteros (4 bytes c/u)
    sums:         .space 400   # Sumas móviles (bloques)
    trend_start:   .word -1      # Índice de inicio de la tendencia
    trend_end:     .word -1      # Índice de fin de la tendencia
.text
main:
    # Muestra el mensaje y lee el n (cantidad de temperaturas)
    li a7, 4
    la a0, msg_n
    ecall
    li a7, 5
    ecall
    la t0, n
    sw a0, 0(t0)

    # Muestra el mensaje y lee el k (tamaño del bloque)
    li a7, 4
    la a0, msg_k
    ecall
    li a7, 5
    ecall
    la t0, k
    sw a0, 0(t0)

    # Pide temperaturas como string (con una coma de separación por lo menos)
    li a7, 4
    la a0, msg_array
    ecall
    li a7, 8
    la a0, buffer
    li a1, 256
    ecall

    # Procesar cadena para extraer números individuales
    la s0, buffer     
    la s1, temperatures
    li s2, 0          
    lw s3, n          
#Función para 'limpiar' la cadena y verificarla
procesar_cadena:
    lbu t0, 0(s0)          # Lee el caracter actual
    beqz t0, verificar_cantidad  

    # Ignora caracteres innecesarios
    li t1, '['
    beq t0, t1, ignorar_caracter
    li t1, ']'
    beq t0, t1, ignorar_caracter
    li t1, ','
    beq t0, t1, ignorar_caracter
    li t1, ' '
    beq t0, t1, ignorar_caracter

    # Verifica si es un dígito
    li t1, '0'
    blt t0, t1, entrada_invalida
    li t1, '9'
    bgt t0, t1, entrada_invalida

    # Extrae el número entero desde la cadena
    la s4, temp_str
    li s5, 0

extraer_numero:
    sb t0, 0(s4)
    addi s4, s4, 1
    addi s5, s5, 1
    addi s0, s0, 1
    lbu t0, 0(s0)

    # Seguir mientras sea dígito
    li t1, '0'
    blt t0, t1, terminar_extraccion
    li t1, '9'
    bgt t0, t1, terminar_extraccion
    j extraer_numero

terminar_extraccion:
    sb zero, 0(s4)           
    la a0, temp_str
    jal convertir_cadena_a_entero   
    sw a0, 0(s1)
    addi s1, s1, 4
    addi s2, s2, 1
    beq s2, s3, fin_proceso
    j procesar_cadena

ignorar_caracter:
    addi s0, s0, 1
    j procesar_cadena

verificar_cantidad:
    bne s2, s3, entrada_invalida

fin_proceso:
    # Salta a calcular sumas móviles (bloques de k)
    jal calcular_sumas_moviles
    
    # Salta a detectar si hay tendencia creciente
    jal detectar_tendencia
    
    # Salta a mostrar los resultados
    jal mostrar_resultados

    # Termina el programa
    li a7, 10
    ecall
#Esto por si la entrada es invalida y muestra un mensaje de eso
entrada_invalida:
    li a7, 4
    la a0, error_msg
    ecall
    li a7, 10
    ecall



#Convierte un número desde string (ASCII) a entero
convertir_cadena_a_entero:   
    li t0, 0         
    li t1, 0         
    lbu t2, 0(a0)
    li t3, '-'
    bne t2, t3, ciclo_conversion
    li t1, 1         
    addi a0, a0, 1

ciclo_conversion:
    lbu t2, 0(a0)
    beqz t2, fin_conversion
    li t3, 10
    mul t0, t0, t3
    addi t2, t2, -48
    add t0, t0, t2
    addi a0, a0, 1
    j ciclo_conversion

fin_conversion:
    beqz t1, devolver
    neg t0, t0
devolver:
    mv a0, t0
    jr ra


# Calcula la suma de cada bloque de k temperaturas consecutivas
calcular_sumas_moviles:
    la t0, temperatures
    la t1, sums
    lw t2, n
    lw t3, k
    sub t4, t2, t3
    addi t4, t4, 1
    li t5, 0          

ciclo_bloques:
    li a3, 0         
    li a4, 0          
    la a5, temperatures
    slli a6, t5, 2
    add a5, a5, a6    

suma_bloque:
    lw a7, 0(a5)
    add a3, a3, a7
    addi a5, a5, 4
    addi a4, a4, 1
    blt a4, t3, suma_bloque

    sw a3, 0(t1)
    addi t1, t1, 4
    addi t5, t5, 1
    blt t5, t4, ciclo_bloques
    jr ra


detectar_tendencia:
    addi sp, sp, -16
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    
    la s0, sums             
    lw s1, n                
    lw s2, k                
    sub s3, s1, s2          
    addi s3, s3, 1          
    
    
    li t0, -1
    la t1, trend_start
    sw t0, 0(t1)
    la t1, trend_end
    sw t0, 0(t1)
    
    
    li t0, 3
    blt s3, t0, fin_detectar
    
    li t1, 0                
    li t2, 0                
    li t3, -1               
    li t4, -1               
    
    addi t5, s3, -1         
    
buscar_tendencia:
    bge t1, t5, verificar_secuencia  
    
    
    slli t6, t1, 2
    add t6, s0, t6         
    lw a3, 0(t6)           
    lw a4, 4(t6)           
    
    
    bgt a4, a3, es_creciente
    j no_creciente

es_creciente:
    
    li a5, -1
    beq t3, a5, nuevo_inicio
    
    
    addi t2, t2, 1         
    addi t4, t1, 1         
    j siguiente

nuevo_inicio:
    mv t3, t1              
    mv t4, t1              
    li t2, 1               
    j siguiente

no_creciente:
    
    li a5, 2
    bge t2, a5, guardar_tendencia  
    
    
    li t2, 0
    li t3, -1
    li t4, -1
    j siguiente

siguiente:
    addi t1, t1, 1
    j buscar_tendencia

guardar_tendencia:
    
    la t0, trend_start
    sw t3, 0(t0)
    la t0, trend_end
    sw t4, 0(t0)
    j fin_detectar

verificar_secuencia:
    
    li a5, 2
    bge t2, a5, guardar_tendencia
    j fin_detectar

fin_detectar:
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    addi sp, sp, 16
    jr ra

mostrar_resultados:
    lw t0, trend_start
    bltz t0, sin_tendencia

    
    li a7, 4
    la a0, msg_blocks
    ecall

    
    lw t1, trend_end
    la t2, sums
    slli t3, t0, 2       
    add t2, t2, t3       
    
    
    sub t4, t1, t0
    addi t4, t4, 1

imprimir_tendencia:
    
    lw a0, 0(t2)
    li a7, 1
    ecall
    
    
    addi t4, t4, -1
    beqz t4, fin_tendencia_impresa
    
    
    li a7, 4
    la a0, plus
    ecall
    
    
    addi t2, t2, 4
    j imprimir_tendencia

fin_tendencia_impresa:
    li a7, 4
    la a0, newline
    ecall
    
    
    li a7, 4
    la a0, msg_trend
    ecall
    li a7, 1
    lw a0, trend_start
    ecall
    j fin_impresion

sin_tendencia:
    li a7, 4
    la a0, msg_no_trend
    ecall

fin_impresion:
    li a7, 4
    la a0, newline
    ecall
    jr ra