# Proyecto final -- Filtros de imagen con ArquiSim
# Arquitectura y Organización de Computadores, 2026-3
# Grupo: Camilo Lagos Baez, Juan Guillermo Esteban Ramírez, Juan Esteban Benjumea Salazar
#
# El programa lee los botones UNA vez al empezar (palabra 0x600) y dibuja la imagen
# de .data con los filtros elegidos:
#
#   botón 0   filtro 1: negativo                  botón 7 = 0  pantalla de 16 colores:
#   botón 1   filtro 2: escala de grises                       original (x 0-15) | filtrada (x 16-31)
#   botón 2   filtro 3: espejo horizontal         botón 7 = 1  pantalla RGB 32 x 32:
#   botón 3   (con el 2) + espejo vertical = giro de 180°        filtrada, cada píxel en 2 x 2
#   botón 4   (con el 2) + transponer      = giro de 90°
#
# Funciones (argumento en $a0, resultado en $v0):
#   FILTRAR   aplica los filtros de color 1 y 2      INDICE    filtro 3 (de dónde se lee)
#   GRIS      escala de grises (la usa FILTRAR)      A16COLOR  RGB332 -> color 0..15
#   A_RGB     RGB332 -> 0x00RRGGBB
#
# Cómo probarlo:
#   (copie este archivo a la carpeta programas/ de su simulador)
#   ./sim -n 100000 programas/proyecto.asm
#   mem[0x600] = 0x81      activa los botones 0 y 7 (o use bt 0 y bt 7)
#   c                      ejecuta hasta el final;  p  cambia de pantalla
#   0                      reinicia: los botones se conservan para probar otra vez
#
# La imagen ocupa 0x200-0x2FF (16 x 16 bytes, RGB332 = RRRGGGBB). Para cambiarla,
# reemplace el bloque de abajo por la salida de img_a_arquisim (vea la sección
# "Preparar la imagen" del enunciado). El programa NO debe modificar la imagen.
#
# >>> IMAGEN # Imagen generada con img_a_arquisim a partir de 'mine.bmp' (16 x 16)
# 16 x 16 píxeles, 1 byte por píxel en formato RGB332 (RRRGGGBB) = 256 bytes
# El píxel (x, y) está en la dirección IMAGEN + 16*y + x
.data
IMAGEN:
        .byte 0x92, 0x96, 0x55, 0x55, 0x75, 0x76, 0x96, 0x96, 0x79, 0x59, 0x59, 0x79, 0x96, 0x96, 0x31, 0x31    # fila 0
        .byte 0x96, 0x96, 0x55, 0x55, 0x75, 0x76, 0x96, 0x96, 0x79, 0x79, 0x79, 0x79, 0x96, 0x96, 0x51, 0x31    # fila 1
        .byte 0x51, 0x51, 0x51, 0x51, 0x30, 0x30, 0x55, 0x55, 0x4D, 0x4D, 0x79, 0x79, 0x2C, 0x2C, 0x96, 0xB6    # fila 2
        .byte 0x31, 0x31, 0x4D, 0x4D, 0x2C, 0x2C, 0x55, 0x55, 0x4D, 0x4D, 0x55, 0x55, 0x0C, 0x0C, 0xB6, 0xB6    # fila 3
        .byte 0x55, 0x55, 0x24, 0x24, 0x24, 0x24, 0x96, 0x96, 0x39, 0x35, 0x28, 0x24, 0x24, 0x24, 0xB6, 0xD6    # fila 4
        .byte 0x55, 0x55, 0x24, 0x24, 0x24, 0x24, 0x96, 0x96, 0x39, 0x35, 0x24, 0x20, 0x24, 0x24, 0xB6, 0xBA    # fila 5
        .byte 0x34, 0x30, 0x24, 0x24, 0x24, 0x24, 0x31, 0x31, 0x2C, 0x2C, 0x24, 0x24, 0x24, 0x24, 0x55, 0x59    # fila 6
        .byte 0x14, 0x14, 0x24, 0x24, 0x24, 0x24, 0x31, 0x11, 0x2C, 0x2C, 0x24, 0x24, 0x24, 0x24, 0x55, 0x59    # fila 7
        .byte 0x55, 0x59, 0x55, 0x55, 0x55, 0x55, 0x24, 0x24, 0x24, 0x24, 0x96, 0xB6, 0x55, 0x55, 0x55, 0x55    # fila 8
        .byte 0x55, 0x59, 0x55, 0x55, 0x79, 0x55, 0x24, 0x24, 0x24, 0x24, 0xB6, 0xB6, 0x59, 0x59, 0x55, 0x55    # fila 9
        .byte 0x75, 0x76, 0x31, 0x31, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x6D, 0x71, 0x96, 0x96    # fila 10
        .byte 0x96, 0x96, 0x31, 0x31, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x6D, 0x71, 0x96, 0xB6    # fila 11
        .byte 0xB6, 0xBA, 0x51, 0x51, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x55, 0x59, 0x31, 0x31    # fila 12
        .byte 0xB6, 0xBA, 0x71, 0x51, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x55, 0x59, 0x31, 0x31    # fila 13
        .byte 0x31, 0x31, 0x96, 0x96, 0x24, 0x24, 0x75, 0x75, 0x96, 0x96, 0x24, 0x24, 0x55, 0x55, 0x55, 0x75    # fila 14
        .byte 0x31, 0x31, 0x96, 0x96, 0x24, 0x24, 0x75, 0x7A, 0xBA, 0xBA, 0x24, 0x24, 0x55, 0x55, 0x75, 0x79    # fila 15
# <<< IMAGEN

.text
# =====================================================================================
# Registros del programa principal (se conservan entre llamadas a funciones):
#   $s0 = botones (palabra 0x600, leída una sola vez)
#   $s1 = contador del ciclo (índice del píxel)
#   $s2 = desplazamiento del píxel en la pantalla de 16 colores (32y + x)
# Las funciones solo usan $a0, $v0, $t0-$t2 y la pila.
# =====================================================================================
MAIN:   lw   $s0, 0x600($zero)          # leer los botones UNA vez
        andi $t0, $s0, 0x80             # botón 7: ¿pantalla RGB?
        bne  $t0, $zero, RGB

# ---------------- Pantalla de 16 colores: original | filtrada ----------------
# i = 16y + x recorre la imagen. En la pantalla, 32y + x = i + (i AND 0xF0),
# porque i AND 0xF0 = 16y.
        add  $s1, $zero, $zero          # i = 0
CIC16:  andi $t0, $s1, 0xF0             # 16y
        add  $s2, $s1, $t0              # 32y + x
        lbu  $a0, IMAGEN($s1)           # píxel original (sin signo)
        jal  A16COLOR
        sb   $v0, 0x400($s2)            # mitad izquierda: original
        add  $a0, $s1, $zero
        jal  INDICE                     # filtro 3: ¿de qué píxel se lee?
        lbu  $a0, IMAGEN($v0)
        jal  FILTRAR
        add  $a0, $v0, $zero
        jal  A16COLOR
        sb   $v0, 0x410($s2)            # mitad derecha: x + 16
        addi $s1, $s1, 1
        slti $t0, $s1, 256
        bne  $t0, $zero, CIC16
        j    SALIR

# ---------------- Pantalla RGB 32 x 32: filtrada y ampliada 2 x 2 ----------------
# k = 32Y + X recorre la pantalla. El píxel de la imagen es (X/2, Y/2):
#   índice = 16*(Y/2) + X/2 = ((k >> 6) << 4) + ((k AND 31) >> 1)
RGB:    sw   $zero, 0x604($zero)        # posición inicial (0, 0)
        add  $s1, $zero, $zero          # k = 0
CICRGB: srl  $t0, $s1, 6                # Y/2
        sll  $t0, $t0, 4                # 16 * (Y/2)
        andi $t1, $s1, 31               # X
        srl  $t1, $t1, 1                # X/2
        add  $a0, $t0, $t1
        jal  INDICE                     # filtro 3: ¿de qué píxel se lee?
        lbu  $a0, IMAGEN($v0)
        jal  FILTRAR
        add  $a0, $v0, $zero
        jal  A_RGB
        sw   $v0, 0x608($zero)          # dibuja y avanza x (autoincremento)
        addi $s1, $s1, 1
        slti $t0, $s1, 1024
        bne  $t0, $zero, CICRGB
        j    SALIR

# =====================================================================================
# FILTRAR: $a0 = píxel RGB332  ->  $v0 = píxel filtrado (RGB332)
# Aplica en orden los filtros de color activos según $s0: 1 negativo, 2 grises.
# (El filtro 3 es geométrico: no cambia el color sino de dónde se lee; ver INDICE.)
# Llama a GRIS, así que guarda $ra en la pila.
# =====================================================================================
FILTRAR: addi $sp, $sp, -4
        sw   $ra, 0($sp)
        add  $v0, $a0, $zero            # sin filtros: el mismo píxel
        andi $t0, $s0, 1                # botón 0: negativo
        beq  $t0, $zero, F2
        xori $v0, $v0, 0xFF             # 7-R, 7-G, 3-B en una sola instrucción
F2:     andi $t0, $s0, 2                # botón 1: escala de grises
        beq  $t0, $zero, F3
        add  $a0, $v0, $zero
        jal  GRIS
F3:     lw   $ra, 0($sp)
        addi $sp, $sp, 4
        jr   $ra

# =====================================================================================
# INDICE (filtro 3, geométrico): $a0 = i = 16y + x  ->  $v0 = índice del píxel a leer
# El índice tiene y en el nibble alto y x en el bajo, así que las transformaciones
# son operaciones de bits sobre el índice:
#   botón 2: espejo horizontal   x -> 15 - x  =  i XOR 0x0F
#   botón 3: + espejo vertical   y -> 15 - y  =  i XOR 0xF0   (con el 2: giro de 180°)
#   botón 4: + transponer        intercambia los nibbles x <-> y (con el 2: giro de 90°)
# =====================================================================================
INDICE: add  $v0, $a0, $zero            # filtro 3 apagado: el mismo píxel
        andi $t0, $s0, 4
        beq  $t0, $zero, IFIN
        andi $t0, $s0, 16               # botón 4: transponer
        beq  $t0, $zero, IESP
        srl  $t0, $v0, 4                # y pasa al nibble bajo
        andi $t1, $v0, 15
        sll  $t1, $t1, 4                # x pasa al nibble alto
        or   $v0, $t0, $t1
IESP:   xori $v0, $v0, 0x0F             # espejo horizontal
        andi $t0, $s0, 8                # botón 3: espejo vertical
        beq  $t0, $zero, IFIN
        xori $v0, $v0, 0xF0
IFIN:   jr   $ra

# =====================================================================================
# GRIS: $a0 = píxel RGB332  ->  $v0 = píxel gris
#   Y = (R + 2G + 2B + 2) / 4 ;  R' = Y, G' = Y, B' = Y / 2   (sin mult ni div)
# =====================================================================================
GRIS:   srl  $t0, $a0, 5                # R
        srl  $t1, $a0, 2
        andi $t1, $t1, 7                # G
        andi $t2, $a0, 3                # B
        add  $t1, $t1, $t2              # G + B
        sll  $t1, $t1, 1                # 2G + 2B
        add  $t0, $t0, $t1              # R + 2G + 2B
        addi $t0, $t0, 2                # + 2 (redondeo)
        srl  $t0, $t0, 2                # Y = ... / 4
        sll  $v0, $t0, 5                # R' = Y
        sll  $t1, $t0, 2
        or   $v0, $v0, $t1              # G' = Y
        srl  $t1, $t0, 1
        or   $v0, $v0, $t1              # B' = Y / 2
        jr   $ra

# =====================================================================================
# A16COLOR: $a0 = píxel RGB332  ->  $v0 = color de la paleta (0..15)
#   bit 0 <- bit 7 (R alto)   bit 1 <- bit 4 (G alto)   bit 2 <- bit 1 (B alto)
#   bit 3 <- bit 6 OR bit 3 (brillo)
# =====================================================================================
A16COLOR: srl $v0, $a0, 7               # bit 7 -> bit 0
        srl  $t0, $a0, 3
        andi $t1, $t0, 2                # bit 4 -> bit 1
        or   $v0, $v0, $t1
        or   $t0, $t0, $a0              # bit 6 -> bit 3, OR con bit 3
        andi $t0, $t0, 8
        or   $v0, $v0, $t0
        sll  $t0, $a0, 1
        andi $t0, $t0, 4                # bit 1 -> bit 2
        or   $v0, $v0, $t0
        jr   $ra

# =====================================================================================
# A_RGB: $a0 = píxel RGB332  ->  $v0 = 0x00RRGGBB = (R << 21) | (G << 13) | (B << 6)
# =====================================================================================
A_RGB:  srl  $v0, $a0, 5
        sll  $v0, $v0, 21               # R << 21
        srl  $t0, $a0, 2
        andi $t0, $t0, 7
        sll  $t0, $t0, 13               # G << 13
        or   $v0, $v0, $t0
        andi $t0, $a0, 3
        sll  $t0, $t0, 6                # B << 6
        or   $v0, $v0, $t0
        jr   $ra
SALIR:                                  # fin: el PC llega al final de .text
