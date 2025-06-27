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
    # Solicita la entrada del código
    li a7, 4
    la a0, msg_code
    ecall
    
    # Lee la cadena de entrada
    li a7, 8
    la a0, buffer
    li a1, 64
    ecall
    
    # Elimina una newline si existe
    jal eliminar_salto_de_linea
    
    # Valida el cdigo
    jal validar_codigo
    beqz a0, codigo_invalido  
    
codigo_valido:
    # Encripta y muestra el resultado primero
    jal encriptar_e_imprimir
    
    li a7, 4
    la a0, msg_valid
    ecall
    
    j salir
    
codigo_invalido:
    # Muestra que el código es inválido
    li a7, 4
    la a0, msg_invalid
    ecall

salir:
    li a7, 10
    ecall

# Función para eliminar el salto de línea final en la cadena ingresada
eliminar_salto_de_linea:
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

# Función para validar el código ingresado
# Osea valida que la cantidad de letras mayúsculas sea par y de dígitos sea impar

validar_codigo:
    la t0, buffer
    li t1, 0       
    li t2, 0       

bucle_validacion:
    lbu t3, 0(t0)
    beqz t3, fin_validacion
    li t4, 10
    beq t3, t4, fin_validacion
    
    li t4, 'A'
    blt t3, t4, no_mayuscula
    li t4, 'Z'
    bgt t3, t4, no_mayuscula
    addi t1, t1, 1
    j siguiente_caracter

no_mayuscula:
    
    li t4, '0'
    blt t3, t4, siguiente_caracter
    li t4, '9'
    bgt t3, t4, siguiente_caracter
    addi t2, t2, 1

siguiente_caracter:
    addi t0, t0, 1
    j bucle_validacion

fin_validacion:
    andi t5, t1, 1
    bnez t5, invalido
    andi t5, t2, 1
    beqz t5, invalido
    li a0, 1
    jr ra

invalido:
    li a0, 0
    jr ra

# Función para encriptar el código con XOR y mostrarlo en formato hexadecimal
encriptar_e_imprimir:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)

    li a7, 4
    la a0, msg_encrypted
    ecall

    la s0, buffer
    li s1, 0x5A      
    li t5, 0         

bucle_encriptar:
    lbu t4, 0(s0)
    beqz t4, fin_encriptar
    li t6, 10
    beq t4, t6, fin_encriptar

    xor t4, t4, s1

    beqz t5, sin_coma
    li a7, 4
    la a0, comma
    ecall

sin_coma:
    li t5, 1

    li a7, 11
    li a0, '0'
    ecall
    li a0, 'x'
    ecall

    mv a0, t4
    jal imprimir_byte_hexadecimal

    addi s0, s0, 1
    j bucle_encriptar

fin_encriptar:
    li a7, 4
    la a0, close_bracket
    ecall

    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    jr ra

# Función para imprimir un byte en formato hexadecimal (0x??)

imprimir_byte_hexadecimal:
    mv t0, a0

    srli t1, t0, 4
    andi t1, t1, 0x0F
    la t2, hex_chars
    add t2, t2, t1
    lbu a0, 0(t2)
    li a7, 11
    ecall

    andi t1, t0, 0x0F
    la t2, hex_chars
    add t2, t2, t1
    lbu a0, 0(t2)
    li a7, 11
    ecall

    jr ra