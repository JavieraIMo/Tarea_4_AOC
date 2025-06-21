.data
    prompt:         .string "Ingrese el código de misión (max 64): "
    msg_valido:     .string "Código válido\n"
    msg_invalido:   .string "Código inválido\n"
    msg_encriptado: .string "Código encriptado: "
    buffer:         .space 65
    hex_table:      .string "0123456789ABCDEF"
    newline:        .string "\n"
    separador:      .string ", "
    ox:             .string "0x"

.text
.globl main
main:
    # Leer cadena
    la a0, prompt
    li a7, 4
    ecall
    la a0, buffer
    li a1, 65
    li a7, 8
    ecall

    # Contar mayúsculas y dígitos
    la t0, buffer
    li t1, 0      # mayúsculas
    li t2, 0      # dígitos
contar_loop:
    lb t3, 0(t0)
    beqz t3, fin_contar
    # Mayúsculas: 'A' (65) a 'Z' (90)
    li t4, 65
    li t5, 90
    blt t3, t4, check_digit
    bgt t3, t5, check_digit
    addi t1, t1, 1
    j siguiente
check_digit:
    # Dígitos: '0' (48) a '9' (57)
    li t4, 48
    li t5, 57
    blt t3, t4, siguiente
    bgt t3, t5, siguiente
    addi t2, t2, 1
siguiente:
    addi t0, t0, 1
    j contar_loop
fin_contar:

    # Validar paridad
    andi t4, t1, 1   # mayúsculas par? (0 = par)
    andi t5, t2, 1   # dígitos impar? (1 = impar)
    bnez t4, invalido
    beqz t5, invalido

    # Código válido
    la a0, msg_encriptado
    li a7, 4
    ecall

    # Encriptar e imprimir en hex
    la t0, buffer
    li s2, 0         # contador de caracteres (s2)
    # Calcular longitud
    la s3, buffer    # s3 = ptr para contar longitud
len_loop:
    lb t4, 0(s3)
    beqz t4, len_done
    addi s2, s2, 1
    addi s3, s3, 1
    j len_loop
len_done:

    li s3, 0         # índice actual (s3)
encriptar_loop:
    lb t3, 0(t0)
    beqz t3, fin_encriptar
    li t4, 90        # 0x5A
    xor t6, t3, t4
    # Imprimir "0x"
    la a0, ox
    li a7, 4
    ecall
    # Imprimir primer dígito hex
    srli s4, t6, 4
    andi s4, s4, 0xF
    la t5, hex_table
    add s5, t5, s4
    lb a0, 0(s5)
    li a7, 11
    ecall
    # Imprimir segundo dígito hex
    andi s4, t6, 0xF
    la t5, hex_table
    add s5, t5, s4
    lb a0, 0(s5)
    li a7, 11
    ecall
    # Imprimir separador solo si no es el último
    addi s3, s3, 1
    blt s3, s2, print_sep
    j skip_sep
print_sep:
    la a0, separador
    li a7, 4
    ecall
skip_sep:
    addi t0, t0, 1
    j encriptar_loop
fin_encriptar:
    la a0, newline
    li a7, 4
    ecall
    la a0, msg_valido
    li a7, 4
    ecall
    j fin
invalido:
    la a0, msg_invalido
    li a7, 4
    ecall
fin:
    li a7, 10
    ecall
