import time
import serial
import sys

# portUSB = sys.argv[1]
# portUSB = 1

ser = serial.Serial(
    port='/dev/ttyUSB5',  #Configurar con el puerto
    baudrate=115200,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS
)

ser.isOpen()
ser.timeout=None
print(ser.timeout)

sendData = 0x00000000
splitData = ['','','','']

print("Comandos:")
print("\t RESET - Resetea los valores del sistema")
print("\t EN_TX - Habilita la PRBS y el filtro transmisor")
print("\t EN_RX")
print("\t PH_SEL [0-3]")
print("\t RUN_MEM")
print("\t READ_MEM")
print("\t BER_S_I")
print("\t BER_S_Q")
print("\t BER_E_I")
print("\t BER_E_Q")
print("\t BER_H")
print("\t IS_MEM_FULL")
print("\t read")
print("\t <num comando> <data value>")
print("\t exit")
print(COMANDOS)
    
while 1 :
    print('''Comandos:
           RESET       - Resetea los valores del sistema.
           EN_TX       - Habilita la PRBS y el filtro transmisor.
           EN_RX       - Habilita la BER.
           PH_SEL[0-3] - Selecciona la fase para el down sampling.
           RUN_MEM     - Comienza a guardar los datos del filtro Tx en memoria.
           READ_MEM    - Lee la memoria por completo.
           ADDR_MEM    - Lee un dato de una dirección específica de memoria.
           BER_S_I     - Lee los 32 bits menos significativos de la cantidad de muestras de la BER en el canal I.
           BER_S_Q     - Lee los 32 bits menos significativos de la cantidad de muestras de la BER en el canal Q.
           BER_E_I     - Lee los 32 bits menos significativos de la cantidad de errores de la BER en el canal I.
           BER_E_Q     - Lee los 32 bits menos significativos de la cantidad de errores de la BER en el canal Q.
           BER_H       - Lee los 32 bits mas significativos de la cantidad leida anteriormente.
           IS_MEM_FULL - Verifica si la memoria está llena.''')
    inputData = input('''Ingrese el comando que quiere enviar. O escriba "exit" para salir.\r\n<<''')
    if inputData == 'exit':
        ser.close()
        exit()
    elif inputData == 'RESET':
    elif inputData == 'EN_TX':
    elif inputData == 'EN_RX':
    elif inputData == 'PH_SEL[0-3]':
    elif inputData == 'PH_SEL[0-3]':
    elif inputData == 'PH_SEL[0-3]':
    elif inputData == 'PH_SEL[0-3]':
    elif inputData == 'RUN_MEM':
    elif inputData == 'RESET':
    elif inputData == 'RESET':
    elif inputData == 'RESET':
    elif inputData == 'RESET':
    elif inputData == 'RESET':
        if inputData == '0':
            print("Para el LED 0:")
            inputData = input("Desea encender algun color del LED 0? y/n:\r\n<<")
            if inputData == 'y':
                sendData &= 0x00000FF8 
                inputData = input("Desea encender el LED rojo? y/n:\r\n<<")
                if inputData == 'y':
                    sendData |= 0x00000004
                inputData = input("Desea encender el LED verde? y/n:\r\n<<")
                if inputData == 'y':
                    sendData |= 0x00000002
                inputData = input("Desea encender el LED azul? y/n:\r\n<<")
                if inputData == 'y':
                    sendData |= 0x00000001
            elif inputData == 'n':
                inputData = input("Desea apagar el LED 0? y/n:\r\n<<")
                if inputData == 'y':
                    sendData &= 0x00000FF8   
        elif inputData == '1':
            print("Para el LED 1:")
            inputData = input("Desea encender algun color del LED 1? y/n:\r\n<<")
            if inputData == 'y':
                sendData &= 0x00000FC7 
                inputData = input("Desea encender el LED rojo? y/n:\r\n<<")
                if inputData == 'y':
                    sendData |= 0x00000020
                inputData = input("Desea encender el LED verde? y/n:\r\n<<")
                if inputData == 'y':
                    sendData |= 0x00000010
                inputData = input("Desea encender el LED azul? y/n:\r\n<<")
                if inputData == 'y':
                    sendData |= 0x00000008
            elif inputData == 'n':
                inputData = input("Desea apagar el LED 1? y/n:\r\n<<")
                if inputData == 'y':
                    sendData &= 0x00000FC7  
        elif inputData == '2':
            print("Para el LED 2:")
            inputData = input("Desea encender algun color del LED 2? y/n:\r\n<<")
            if inputData == 'y':
                sendData &= 0x00000E3F
                inputData = input("Desea encender el LED rojo? y/n:\r\n<<")
                if inputData == 'y':
                    sendData |= 0x00000100
                inputData = input("Desea encender el LED verde? y/n:\r\n<<")
                if inputData == 'y':
                    sendData |= 0x00000080
                inputData = input("Desea encender el LED azul? y/n:\r\n<<")
                if inputData == 'y':
                    sendData |= 0x00000040
            elif inputData == 'n':
                inputData = input("Desea apagar el LED 2? y/n:\r\n<<")
                if inputData == 'y':
                    sendData &= 0x00000E3F  
        elif inputData == '3':
            print("Para el LED 3:")
            inputData = input("Desea encender algun color del LED 3? y/n:\r\n<<")
            if inputData == 'y':
                sendData &= 0x000001FF 
                inputData = input("Desea encender el LED rojo? y/n:\r\n<<")
                if inputData == 'y':
                    sendData |= 0x00000800
                inputData = input("Desea encender el LED verde? y/n:\r\n<<")
                if inputData == 'y':
                    sendData |= 0x00000400
                inputData = input("Desea encender el LED azul? y/n:\r\n<<")
                if inputData == 'y':
                    sendData |= 0x00000200
            elif inputData == 'n':
                inputData = input("Desea apagar el LED 3? y/n:\r\n<<")
                if inputData == 'y':
                    sendData &= 0x000001FF 

        
        splitData[0] = (sendData&0xFF).to_bytes(1, byteorder = "big")
        splitData[1] = ((sendData>>8)&0xFF).to_bytes(1, byteorder = "big")
        splitData[2] = ((sendData>>16)&0xFF).to_bytes(1, byteorder = "big")
        splitData[3] = ((sendData>>24)&0xFF).to_bytes(1, byteorder = "big")

        # print(splitData[0])
        # print(splitData[1])
        # print(splitData[2])
        # print(splitData[3])
        ser.write(splitData[0])
        ser.write(splitData[1])
        ser.write(splitData[2])
        ser.write(splitData[3])
        time.sleep(1)
        # print(hex(sendData))

    elif inputData == '4':
        print ("Wait Input Data")
        aux = sendData
        sendData |= 0x0A0A0000
        # sendData = 0x0A0A0000
        splitData[0] = (sendData&0xFF).to_bytes(1, byteorder = "big")
        splitData[1] = ((sendData>>8)&0xFF).to_bytes(1, byteorder = "big")
        splitData[2] = ((sendData>>16)&0xFF).to_bytes(1, byteorder = "big")
        splitData[3] = ((sendData>>24)&0xFF).to_bytes(1, byteorder = "big")

        # print(splitData[0])
        # print(splitData[1])
        # print(splitData[2])
        # print(splitData[3])
        ser.write(splitData[0])
        ser.write(splitData[1])
        ser.write(splitData[2])
        ser.write(splitData[3])

        time.sleep(2)
        out = ord(ser.read(1))



        print(ser.inWaiting())
        if out != '':
            print (">>" + str(out))

        sendData = aux


    else:
        print("Comando no valido.")
