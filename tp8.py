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
while 1 :

    inputData = input('Ingrese el nro de LED que quiere manipular (0,1,2,3). Ingrese 4 si quiere leer el estado de los switch. O escriba "exit" para salir.\r\n<<')
    # inputData = str(inputData)
    if inputData == 'exit':
        ser.close()
        exit()
    elif inputData in ['0','1','2','3']:
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
