.data
    msg_code:      .asciz "Ingrese el codigo de mision: "
    msg_valid:     .asciz "Codigo valido\n"
    msg_invalid:   .asciz "Codigo invalido\n"
    msg_encrypted: .asciz "Codigo encriptado: ["
    hex_chars:     .asciz "0123456789ABCDEF"
    comma:         .asciz ", "
    close_bracket: .asciz "]\n"
    
    buffer:        .space 65   # 64 caracteres + null terminator

.text
main:
    # Solicitar entrada del código
    li a7, 4
    la a0, msg_code
    ecall
    
    # Leer cadena de entrada
    li a7, 8
    la a0, buffer
    li a1, 64
    ecall
    
    # Eliminar newline si existe
    jal remove_newline
    
    # Validar el código
    jal validate
    beqz a0, invalid_code  # Si a0 = 0, código inválido
    
valid_code:
    # Código válido
    li a7, 4
    la a0, msg_valid
    ecall
    
    # Encriptar y mostrar resultado
    jal encrypt_and_print
    j exit
    
invalid_code:
    # Código inválido
    li a7, 4
    la a0, msg_invalid
    ecall

exit:
    li a7, 10
    ecall

# Función para eliminar newline del final del buffer
remove_newline:
    la t0, buffer
rm_loop:
    lbu t1, 0(t0)
    beqz t1, rm_end
    addi t0, t0, 1
    j rm_loop
rm_end:
    addi t0, t0, -1
    lbu t1, 0(t0)
    li t2, '\n'
    bne t1, t2, no_rm
    sb zero, 0(t0)
no_rm:
    jr ra

# Función para validar el código
# Retorna a0 = 1 si es válido, 0 si no
validate:
    la t0, buffer      # Puntero al buffer
    li t1, 0           # Contador de mayúsculas
    li t2, 0           # Contador de dígitos

validate_loop:
    lbu t3, 0(t0)      # Cargar carácter actual
    beqz t3, end_validate  # Fin si es null terminator
    li t4, 10           # ASCII de newline
    beq t3, t4, end_validate
    
    # Verificar si es mayúscula (A-Z)
    li t4, 'A'
    blt t3, t4, not_upper
    li t4, 'Z'
    bgt t3, t4, not_upper
    addi t1, t1, 1     # Incrementar contador mayúsculas
    j next_char
    
not_upper:
    # Verificar si es dígito (0-9)
    li t4, '0'
    blt t3, t4, next_char
    li t4, '9'
    bgt t3, t4, next_char
    addi t2, t2, 1     # Incrementar contador dígitos

next_char:
    addi t0, t0, 1     # Siguiente carácter
    j validate_loop

end_validate:
    # Verificar condiciones: 
    #   mayúsculas par (t1 % 2 == 0)
    #   dígitos impar (t2 % 2 == 1)
    andi t5, t1, 1     # t5 = 1 si t1 es impar, 0 si par
    bnez t5, invalid   # Si mayúsculas es impar, inválido
    
    andi t5, t2, 1     # t5 = 1 si t2 es impar, 0 si par
    beqz t5, invalid   # Si dígitos es par, inválido
    
    li a0, 1           # Válido
    jr ra
    
invalid:
    li a0, 0           # Inválido
    jr ra

# Función para encriptar y mostrar resultado
encrypt_and_print:
    # Guardar registros
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    
    # Imprimir encabezado
    li a7, 4
    la a0, msg_encrypted
    ecall
    
    la s0, buffer      # Puntero al buffer
    li s1, 0x5A        # Clave XOR
    li t5, 0           # Primer elemento flag

encrypt_loop:
    lbu t4, 0(s0)      # Cargar carácter
    beqz t4, end_encrypt  # Fin si null
    li t6, 10
    beq t4, t6, end_encrypt  # Fin si newline
    
    # Aplicar XOR
    xor t4, t4, s1
    
    # Imprimir coma si no es el primer elemento
    beqz t5, no_comma
    li a7, 4
    la a0, comma
    ecall
    
no_comma:
    li t5, 1           # Marcar que ya pasó el primer elemento
    
    # Imprimir "0x"
    li a7, 11
    li a0, '0'
    ecall
    li a0, 'x'
    ecall
    
    # Imprimir byte en hexadecimal
    mv a0, t4
    jal print_hex_byte
    
    # Siguiente carácter
    addi s0, s0, 1
    j encrypt_loop

end_encrypt:
    # Cerrar corchete
    li a7, 4
    la a0, close_bracket
    ecall
    
    # Restaurar registros
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    jr ra

# Función para imprimir un byte en hexadecimal
# a0 = byte a imprimir
print_hex_byte:
    # Guardar byte
    mv t0, a0
    
    # Nibble alto
    srli t1, t0, 4
    andi t1, t1, 0x0F
    la t2, hex_chars
    add t2, t2, t1
    lbu a0, 0(t2)
    li a7, 11
    ecall
    
    # Nibble bajo
    andi t1, t0, 0x0F
    la t2, hex_chars
    add t2, t2, t1
    lbu a0, 0(t2)
    li a7, 11
    ecall
    
    jr ra