import matplotlib.pyplot as plt
import numpy as np

# Listas para almacenar los datos leídos
x = []
y = []
filter_I = []
filter_Q = []

with open('datos.txt', 'w') as archivo_bram:
    for i in range(2**15-1):
        dato = np.random.uniform(0,2**8-1)
        archivo_bram.write(str(i) + ' ' + str(dato) + '\n')

# Leer los datos del archivo
# with open('datos.txt', 'r') as archivo_bram:
#     for linea in archivo_bram:
#         datos = linea.split(' ')
#         x.append(int(datos[0]))
#         y.append(float(datos[1])/(2**8))

# Formato archivo
# I Q I Q   (32 bits)
# I Q I Q
# ....
with open('datos.txt', 'r') as archivo_bram:
    for linea in archivo_bram:
        sample = int(linea[31:24], 2)
        filter_I.append(sample)
        sample = int(linea[23:16], 2)
        filter_Q.append(sample)
        sample = int(linea[15:8], 2)
        filter_I.append(sample)
        sample = int(linea[7:0], 2)
        filter_Q.append(sample)

# Graficar los datos
# plt.plot(x, y, marker='o')
plt.plot(filter_I, marker='o')
plt.plot(filter_Q, marker='o')
# plt.xlim(0,2**15-1)
# plt.ylim(0,2**32-1)
plt.xlabel('Muestras')
plt.title('Salida del filtro')
plt.grid(True)
plt.show()