# Lab_4_AOC

## 👥 Autores

**Paralelo 201**
- Javiera Ibaca Morales  
  Rol: 202273624-0

**Paralelo 200**
- Rodrigo Ariel Cáceres Gaete  
  Rol: 202273616-k

---

## 📝 Descripción

Este laboratorio consiste en la resolución de dos desafíos en lenguaje ensamblador RISC-V utilizando el simulador RARS:

1. **Análisis Térmico Predictivo:**  
   Lee una serie de temperaturas, calcula sumas móviles y detecta tendencias crecientes.

2. **Códigos de Misión con Criptografía XOR:**  
   Valida un código de misión según reglas de paridad y lo encripta usando XOR, mostrando el resultado en hexadecimal.

---

## 🚀 Características

- Entrada y salida por consola.
- Uso de instrucciones y registros válidos para RISC-V en RARS.
- Validación de datos y manejo de cadenas.
- Comentarios explicativos en el código.

---

## 📁 Estructura del Código

```
📁 tarea_4_aoc
│
├── 📄 sub1.asm      # Desafío 1: Análisis térmico predictivo
├── 📄 sub2.asm      # Desafío 2: Código de misión con criptografía XOR
└── 📄 README.md     # Este archivo
```

---

## 🛠️ Requisitos

- [RARS 1.6](https://github.com/TheThirdOne/rars/releases/tag/v1.6) (RISC-V Assembler and Runtime Simulator)
- Sistema operativo compatible (Windows, Linux, MacOS)

---

## ▶️ Instrucciones de uso en RARS 1.6

1. Descargar e instalar RARS 1.6 desde el [repositorio oficial](https://github.com/TheThirdOne/rars/releases/tag/v1.6).
2. Ejecutar RARS:
   ```
   java -jar rars1_6.jar
   ```
3. En RARS, abrir el archivo deseado:
   - Menú `File` → `Open` → Seleccionar `sub1.asm` o `sub2.asm`
4. Ensamblar el código:
   - Click en el botón `Assemble` (icono de engranaje) o presionar `F3`
5. Ejecutar el programa:
   - Click en el botón `Run` (triángulo verde) o presionar `F5`
6. Interactuar con el programa:
   - La entrada y salida se mostrará en el panel `Run I/O` (parte inferior de la ventana)
7. Para detener la ejecución:
   - Click en `Stop` (cuadrado rojo)

---

## ⚠️ Nota importante sobre el PDF de la tarea

En la tabla de cálculos XOR proporcionada en el PDF de la tarea, hay un error de tipeo en el cálculo del carácter '7':

**Tabla del PDF (con error):**
- Dice: ASCII de '7' (55) ⊕ 0x5A (90) = 101 → 0x65

**Cálculo correcto:**
- ASCII de '7' (0x37 / 55) ⊕ 0x5A (90) = 109 → 0x6D

Este error explica la discrepancia entre la tabla y la salida real del programa. La salida correcta para el ejemplo "X7J9Z2K" es:
```
[0x02, 0x6D, 0x10, 0x63, 0x00, 0x68, 0x11]
```

---

## 📚 Notas

- Ambos programas están comentados para facilitar su comprensión.
- Se recomienda probar con diferentes entradas para verificar el correcto funcionamiento.