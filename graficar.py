import matplotlib.pyplot as plt
import numpy as np

# Listas para almacenar los datos leídos
x = []
y = []
filter_I = []
filter_Q = []

#with open('bram.txt', 'w') as archivo_bram:
    # for i in range(2**15-1):
        # dato = np.random.uniform(0,2**8-1)
        # archivo_bram.write(str(i) + ' ' + str(dato) + '\n')

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
with open('bram.txt', 'r') as archivo_bram:
    for linea in archivo_bram:
        sample = int(linea)
        Q_low  = (sample&0xFF)
        I_low  = ((sample>>8)&0xFF)
        Q_high = ((sample>>16)&0xFF)
        I_high = ((sample>>24)&0xFF)

        if Q_low >= 0x80:
            Q_low = -(0xFF-Q_low+1)
        if I_low >= 0x80:
            I_low = -(0xFF-I_low+1)
        if Q_high >= 0x80:
            Q_high = -(0xFF-Q_high+1)
        if I_high >= 0x80:
            I_high = -(0xFF-I_high+1)

        # 0x63 0b01100011 99
        # 0x9D 0b10011101 157

        # 00011100 28

        filter_I.append(I_low)
        filter_I.append(I_high)
        filter_Q.append(Q_low)
        filter_Q.append(Q_high)

        # sample = int(linea[31:24], 2)
        # sample = int(linea[23:16], 2)
        # filter_I.append(sample)
        # filter_Q.append(sample)
        # sample = int(linea[15:8], 2)
        # filter_I.append(sample)
        # sample = int(linea[7:0], 2)
        # filter_Q.append(sample)

# Graficar los datos
plt.figure()
plt.suptitle('Canales I & Q')
plt.subplot(2,1,1)
# plt.title(name)
plt.plot(filter_I,'r-',linewidth=2.0)
# plt.xlim(1000,1250)
plt.grid(True)
plt.legend()

plt.subplot(2,1,2)
plt.plot(filter_Q,'r-',linewidth=2.0)
# plt.xlim(1000,1250)
plt.grid(True)
plt.legend()
plt.xlabel('Muestras')
plt.show()






# plt.plot(x, y, marker='o')
# plt.plot(filter_I, 'r-',linewidth=2.0,)
# plt.plot(filter_I, marker='o')
# plt.plot(filter_Q, 'g-',linewidth=2.0,)
# plt.plot(filter_Q, marker='o')
# plt.xlim(0,250)
# plt.ylim(0,2**32-1)
# plt.xlabel('Muestras')
# plt.title('Salida del filtro')
# plt.grid(True)
# plt.show()