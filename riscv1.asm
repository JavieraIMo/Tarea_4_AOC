.data
    prompt_n:      .string "Ingrese la cantidad de temperaturas (n): "
    prompt_k:      .string "Ingrese el tamaño del bloque (k): "
    prompt_temp:   .string "Ingrese la temperatura: "
    msg_tendencia: .string "Tendencia encontrada desde índice "
    msg_no_tend:   .string "Sin tendencias detectadas\n"
    msg_bloques:   .string "Bloques crecientes: "
    newline:       .string "\n"
    espacio:       .string " "
    temperaturas:  .space 400      # hasta 100 enteros (4 bytes c/u)
    sumas:         .space 400      # hasta 100 enteros (4 bytes c/u)

.text
.globl main
main:
    # Leer n
    la a0, prompt_n
    li a7, 4
    ecall
    li a7, 5
    ecall
    mv t0, a0      # n en t0

    # Leer k
    la a0, prompt_k
    li a7, 4
    ecall
    li a7, 5
    ecall
    mv t1, a0      # k en t1

    # Leer n temperaturas
    la t2, temperaturas
    li t3, 0    # i = 0
leer_temp:
    bge t3, t0, fin_leer_temp
    la a0, prompt_temp
    li a7, 4
    ecall
    li a7, 5
    ecall
    sw a0, 0(t2)
    addi t2, t2, 4
    addi t3, t3, 1
    j leer_temp
fin_leer_temp:

    # Calcular sumas móviles
    la t2, temperaturas
    la t4, sumas
    sub t5, t0, t1      # límite: n-k
    addi t5, t5, 1
    li t3, 0         # i = 0
sumas_loop:
    bge t3, t5, fin_sumas
    li t6, 0         # suma = 0
    li s2, 0         # j = 0 (usamos s2 en vez de t7)
li s6, 4
sumar_bloque:
    bge s2, t1, fin_bloque
    mul s3, t3, s6    # s3 = t3 * 4
    mul s4, s2, s6    # s4 = s2 * 4
    add a1, s3, s4
    la a0, temperaturas
    add a0, a0, a1
    lw a2, 0(a0)
    add t6, t6, a2
    addi s2, s2, 1
    j sumar_bloque
fin_bloque:
    sw t6, 0(t4)
    addi t4, t4, 4
    addi t3, t3, 1
    j sumas_loop
fin_sumas:

    # Buscar tendencia creciente de al menos 3 bloques
    la t4, sumas
    li t3, 0        # i = 0
    li s5, 0        # contador de tendencia (usamos s5 en vez de t9)
    li s0, 0        # índice inicial de tendencia
    li s1, 0        # flag de tendencia encontrada

    sub t5, t0, t1
    addi t5, t5, -1      # límite para comparar sumas[i] y sumas[i+1]
buscar_tendencia:
    bge t3, t5, fin_buscar
    lw a0, 0(t4)
    lw a1, 4(t4)
    blt a0, a1, creciente
    li s5, 0
    addi t4, t4, 4
    addi t3, t3, 1
    j buscar_tendencia
creciente:
    beqz s5, guardar_indice
    addi s5, s5, 1
    li s7, 2
    bge s5, s7, tendencia_encontrada
    addi t4, t4, 4
    addi t3, t3, 1
    j buscar_tendencia
guardar_indice:
    mv s0, t3
    li s5, 1
    addi t4, t4, 4
    addi t3, t3, 1
    j buscar_tendencia
tendencia_encontrada:
    li s1, 1
    j fin_buscar
fin_buscar:

    # Imprimir resultados
    la a0, msg_bloques
    li a7, 4
    ecall

    la t4, sumas
    sub t5, t0, t1
    addi t5, t5, 1
    li t3, 0
imprimir_sumas:
    bge t3, t5, fin_imprimir_sumas
    lw a0, 0(t4)
    li a7, 1
    ecall
    la a0, espacio
    li a7, 4
    ecall
    addi t4, t4, 4
    addi t3, t3, 1
    j imprimir_sumas
fin_imprimir_sumas:
    la a0, newline
    li a7, 4
    ecall

    beqz s1, sin_tendencia
    # Imprimir mensaje de tendencia encontrada
    la a0, msg_tendencia
    li a7, 4
    ecall
    mv a0, s0
    li a7, 1
    ecall
    la a0, newline
    li a7, 4
    ecall
    j fin
sin_tendencia:
    la a0, msg_no_tend
    li a7, 4
    ecall
fin:
    li a7, 10
    ecall