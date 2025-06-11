.data
   #
    msg_n:        .asciz "Ingrese n: "
    msg_k:        .asciz "Ingrese k: "
    msg_temps:    .asciz "Ingrese temperaturas:\n"
    msg_blocks:   .asciz "Bloques crecientes: "
    msg_trend:    .asciz "Tendencia detectada desde indice "
    msg_no_trend: .asciz "Sin tendencias detectadas"
    plus:         .asciz " + "
    newline:      .asciz "\n"
    
    n:          .word 0
    k:          .word 0
    temperatures: .space 400
    sums:        .space 400

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

    # Leer temperaturas
    li a7, 4
    la a0, msg_temps
    ecall
    la t0, temperatures
    lw t1, n
    li t2, 0
read_loop:
    li a7, 5
    ecall
    sw a0, 0(t0)
    addi t0, t0, 4
    addi t2, t2, 1
    blt t2, t1, read_loop

    # Calcular sumas
    jal calc_sums
    
    # Detectar tendencia
    jal detect_trend
    
    # Imprimir resultados
    jal print_results
    
    # Salir
    li a7, 10
    ecall

calc_sums:
    la t0, temperatures
    la t1, sums
    lw t2, n
    lw t3, k
    sub t4, t2, t3
    addi t4, t4, 1
    li t5, 0

block_loop:
    li a3, 0              # Suma
    li a4, 0              # j
    la a5, temperatures   # Base
    slli a6, t5, 2        # Offset
    add a5, a5, a6        # Dirección inicio

sum_loop:
    lw a7, 0(a5)          # Cargar temp
    add a3, a3, a7        # Acumular
    addi a5, a5, 4
    addi a4, a4, 1
    blt a4, t3, sum_loop

    sw a3, 0(t1)
    addi t1, t1, 4
    addi t5, t5, 1
    blt t5, t4, block_loop
    jr ra

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
    j print_results

next_iter:
    addi t0, t0, 4
    addi t4, t4, 1
    blt t4, t3, trend_loop
    li t5, -1
    jr ra

print_results:
    # Imprimir sumas
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