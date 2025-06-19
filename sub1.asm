.data
    msg_n:        .asciz "Ingrese la cantidad de temperaturas 'n': "
    msg_k:        .asciz "Ingrese el tamaño del bloque 'k': "
    msg_array:    .asciz "Ingrese las temperaturas como [num1, num2,...]: "
    msg_blocks:   .asciz "Bloques crecientes: "
    msg_trend:    .asciz "Tendencia detectada desde indice "
    msg_no_trend: .asciz "Sin tendencias detectadas"
    plus:         .asciz " -> "
    newline:      .asciz "\n"
    error_msg:    .asciz "Error: Formato de entrada inválido\n"
    
    buffer:       .space 256   # Para almacenar la cadena de entrada
    temp_str:     .space 12    # Para almacenar cada número temporal
    n:            .word 0
    k:            .word 0
    temperatures: .space 400   # Máximo 100 valores (4 bytes cada uno)
    sums:         .space 400   # Sumas móviles

.text
main:
    # Leer n
    li a7, 4
    la a0, msg_n
    ecall
    li a7, 5
    ecall
    sw a0, n, t0

    # Leer k
    li a7, 4
    la a0, msg_k
    ecall
    li a7, 5
    ecall
    sw a0, k, t0

    # Leer array como cadena
    li a7, 4
    la a0, msg_array
    ecall
    li a7, 8
    la a0, buffer
    li a1, 256
    ecall

    # Procesar cadena para extraer números
    la s0, buffer     # Puntero a la cadena
    la s1, temperatures
    li s2, 0          # Contador de números leídos
    lw s3, n          # Total de números a leer

process_loop:
    lbu t0, 0(s0)     # Cargar carácter actual
    beqz t0, check_count  # Fin si es NULL
    
    # Ignorar caracteres no numéricos
    li t1, '['
    beq t0, t1, skip_char
    li t1, ']'
    beq t0, t1, skip_char
    li t1, ','
    beq t0, t1, skip_char
    li t1, ' '
    beq t0, t1, skip_char
    
    # Verificar si es dígito
    li t1, '0'
    blt t0, t1, invalid_input
    li t1, '9'
    bgt t0, t1, invalid_input
    
    # Si es dígito, extraer el número completo
    la s4, temp_str
    li s5, 0          # Longitud del número actual

extract_number:
    sb t0, 0(s4)      # Guardar dígito
    addi s4, s4, 1
    addi s5, s5, 1
    addi s0, s0, 1
    lbu t0, 0(s0)
    
    # Verificar si el siguiente es dígito
    li t1, '0'
    blt t0, t1, end_extract
    li t1, '9'
    bgt t0, t1, end_extract
    j extract_number

end_extract:
    sb zero, 0(s4)    # Terminar cadena del número
    # Convertir a entero
    la a0, temp_str
    jal atoi
    sw a0, 0(s1)      # Guardar en temperatures
    addi s1, s1, 4
    addi s2, s2, 1
    beq s2, s3, process_done  # Si ya leímos n números, terminar
    j process_loop

skip_char:
    addi s0, s0, 1
    j process_loop

check_count:
    bne s2, s3, invalid_input  # Verificar que leímos exactamente n números

process_done:
    # Calcular sumas móviles
    jal calc_sums
    
    # Detectar tendencia
    jal detect_trend
    
    # Imprimir resultados
    jal print_results
    
    # Salir
    li a7, 10
    ecall

invalid_input:
    li a7, 4
    la a0, error_msg
    ecall
    li a7, 10
    ecall

# Función para convertir cadena a entero (atoi)
atoi:
    li t0, 0         # Resultado
    li t1, 0         # Signo (0=positivo)
    lbu t2, 0(a0)
    li t3, '-'
    bne t2, t3, convert_loop
    li t1, 1         # Negativo
    addi a0, a0, 1

convert_loop:
    lbu t2, 0(a0)
    beqz t2, end_convert
    li t3, 10
    mul t0, t0, t3
    addi t2, t2, -48  # ASCII a dígito
    add t0, t0, t2
    addi a0, a0, 1
    j convert_loop

end_convert:
    beqz t1, return_atoi
    neg t0, t0
return_atoi:
    mv a0, t0
    jr ra

# Función para calcular sumas móviles
calc_sums:
    la t0, temperatures
    la t1, sums
    lw t2, n
    lw t3, k
    sub t4, t2, t3
    addi t4, t4, 1
    li t5, 0

block_loop:
    li a3, 0
    li a4, 0
    la a5, temperatures
    slli a6, t5, 2
    add a5, a5, a6

sum_loop:
    lw a7, 0(a5)
    add a3, a3, a7
    addi a5, a5, 4
    addi a4, a4, 1
    blt a4, t3, sum_loop

    sw a3, 0(t1)
    addi t1, t1, 4
    addi t5, t5, 1
    blt t5, t4, block_loop
    jr ra

# Función para detectar tendencia
detect_trend:
    la t0, sums
    lw t1, n
    lw t2, k
    sub t3, t1, t2
    addi t3, t3, -1
    li t4, 0
    li t5, -1

trend_loop:
    lw a0, 0(t0)
    lw a1, 4(t0)
    lw a2, 8(t0)
    bge a0, a1, next_iter
    bge a1, a2, next_iter
    mv t5, t4
    j end_detect

next_iter:
    addi t0, t0, 4
    addi t4, t4, 1
    blt t4, t3, trend_loop

end_detect:
    jr ra

# Función para imprimir resultados
print_results:
    li a7, 4
    la a0, msg_blocks
    ecall
    
    la t0, sums
    lw t1, n
    lw t2, k
    sub t3, t1, t2
    addi t3, t3, 1
    li t4, 0

print_loop:
    lw a0, 0(t0)
    li a7, 1
    ecall
    
    addi t0, t0, 4
    addi t4, t4, 1
    beq t4, t3, end_print
    
    li a7, 4
    la a0, plus
    ecall
    j print_loop

end_print:
    li a7, 4
    la a0, newline
    ecall
    
    bltz t5, no_trend
    li a7, 4
    la a0, msg_trend
    ecall
    li a7, 1
    mv a0, t5
    ecall
    j exit_print

no_trend:
    li a7, 4
    la a0, msg_no_trend
    ecall

exit_print:
    li a7, 4
    la a0, newline
    ecall
    jr ra
