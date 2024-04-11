import time
import serial
import sys

# portUSB = sys.argv[1]
# portUSB = 1

def enviar_puerto_serie(data_to_send):
    # Envio de datos por puerto serie
    splitData = ['','','','']
    splitData[0] = (data_to_send&0xFF).to_bytes(1, byteorder = "big")
    splitData[1] = ((data_to_send>>8)&0xFF).to_bytes(1, byteorder = "big")
    splitData[2] = ((data_to_send>>16)&0xFF).to_bytes(1, byteorder = "big")
    splitData[3] = ((data_to_send>>24)&0xFF).to_bytes(1, byteorder = "big")
    print('splitData')
    print(splitData[0])
    print(splitData[1])
    print(splitData[2])
    print(splitData[3])

    ser.write(splitData[0])
    ser.write(splitData[1])
    ser.write(splitData[2])
    ser.write(splitData[3])
    # time.sleep(1)


def recibir_puerto_serie():
    # Recepcion de datos por puerto serie
    print ("Esperando dato del puerto serie...")

    out = [0,0,0,0]
    i = 0
    timeout = 1000000
    while ser.inWaiting() == 0:
        i += 1
        if i == timeout:
            break

    while ser.inWaiting() > 0:
        # out += ser.read(1).decode()
        out[i] = ord(ser.read(1))
        i += 1
    
    # print(f'i:{i}')

    x = (out[3]&0xFF)<<24 | (out[2]&0xFF)<<16 | (out[1]&0xFF)<<8 | (out[0]&0xFF)
    # print (f"Dato recibido en hex:{hex(x)}")
    print (f">>{x} ({hex(x)})")
    return x
        

ser = serial.Serial(
    port='/dev/ttyUSB1',  #Configurar con el puerto
    baudrate=115200,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS
)

ser.isOpen()
ser.timeout=None
print(ser.timeout)
# splitData = ['','','','']
mem_full = 0

archivo_bram = open('bram.txt', 'w')

ber_s_i = 0x0000000000000000 # 64 bits
ber_s_q = 0x0000000000000000 # 64 bits
ber_e_i = 0x0000000000000000 # 64 bits
ber_e_q = 0x0000000000000000 # 64 bits

while 1 :
    sendData = 0x00000000 # sendData = {frame_command,frame_enable,frame_data}
    frame_command = 0x00  # sendData[31:24]
                          # sendData[23]. Es siempre 0, el uBlaze lo pone en 1.
    frame_data = 0x000000 # sendData[22:0]
    
    inputData = input('''Ingrese el comando que quiere enviar. O escriba "exit" para salir.
          comandos:
            RESET [0-1] - Resetea los valores del sistema.
            EN_TX [0-1] - Habilita la PRBS y el filtro transmisor.
            EN_RX [0-1] - Habilita la BER.
            PH_SEL[0-3] - Selecciona la fase para el down sampling.
            RUN_MEM     - Comienza a guardar los datos del filtro Tx en memoria.
            READ_MEM    - Lee la memoria por completo.
            ADDR_MEM    - Lee un dato de una dirección específica de memoria.
            BER_S_I     - Lee la cantidad de muestras de la BER en el canal I.
            BER_S_Q     - Lee la cantidad de muestras de la BER en el canal Q.
            BER_E_I     - Lee la cantidad de errores de la BER en el canal I.
            BER_E_Q     - Lee la cantidad de errores de la BER en el canal Q.
            IS_MEM_FULL - Verifica si la memoria esta llena.
          
          <comando> <valor del dato>
          valor del dato por defecto : 0.
          cmd<<''')
    inputData = inputData.upper()
    inputData = inputData.split(' ')
    print(inputData)
    command_str = inputData[0]
    if len(inputData) > 1: frame_data = int(inputData[1])
    if command_str == 'exit':
        ser.close()
        exit()
    elif command_str == 'RESET':
        if(frame_data == 0 or frame_data == 1):
            frame_command = 0x00
        else:
            print('El valor del RESET debe ser 0 o 1')
            continue

    elif command_str == 'EN_TX':
        frame_command = 0x01
        
    elif command_str == 'EN_RX':
        frame_command = 0x02

    elif command_str == 'PH_SEL':
        if(0 <= frame_data <= 3):
            frame_command = 0x03
        else:
            print('La fase esta fuera del rango seleccionable')
            continue

    elif command_str == 'RUN_MEM':
        frame_command = 0x04

    elif command_str == 'READ_MEM':
        if mem_full == 1:
            frame_command = 0x05
            for addr in range(2**15):
                sendData = (frame_command << 24) | addr
                enviar_puerto_serie(sendData)
                value_mem = recibir_puerto_serie()  # Recibo 32 bits del RF
                # archivo_bram.write(str(addr) + ' ' + str(value_mem) + '\n')
                archivo_bram.write(str(value_mem) + '\n')
            continue
        else:
            print('La memoria no esta llena')
            continue

    elif command_str == 'ADDR_MEM':
        if(0 <= frame_data < 2**15):
            frame_command = 0x05
        else:
            print('La direccion de memoria esta fuera del rango seleccionable')
            continue

    elif command_str == 'BER_S_I':
        # Recibo parte baja de la palabra
        frame_command = 0x07
        sendData = (frame_command << 24) | frame_data
        ber_s_i = recibir_puerto_serie()&0xFFFFFFFF
        # Recibo parte alta de la palabra
        frame_command = 0x0B    # BER_H
        sendData = (frame_command << 24) | frame_data
        enviar_puerto_serie(sendData)
        ber_s_i |= (recibir_puerto_serie()&0xFFFFFFFF) << 32

    elif command_str == 'BER_S_Q':
        frame_command = 0x08 
        # Recibo parte baja de la palabra
        sendData = (frame_command << 24) | frame_data
        ber_s_q = recibir_puerto_serie()&0xFFFFFFFF
        # Recibo parte alta de la palabra
        frame_command = 0x0B    # BER_H
        sendData = (frame_command << 24) | frame_data
        enviar_puerto_serie(sendData)
        ber_s_q |= (recibir_puerto_serie()&0xFFFFFFFF) << 32

    elif command_str == 'BER_E_I':
        # Recibo parte baja de la palabra
        frame_command = 0x09
        sendData = (frame_command << 24) | frame_data
        ber_e_i = recibir_puerto_serie()&0xFFFFFFFF
        # Recibo parte alta de la palabra
        frame_command = 0x0B    # BER_H
        sendData = (frame_command << 24) | frame_data
        enviar_puerto_serie(sendData)
        ber_e_i |= (recibir_puerto_serie()&0xFFFFFFFF) << 32
        

    elif command_str == 'BER_E_Q':
        # Recibo parte baja de la palabra
        frame_command = 0x0A
        sendData = (frame_command << 24) | frame_data
        ber_e_q = recibir_puerto_serie()&0xFFFFFFFF
        # Recibo parte alta de la palabra
        frame_command = 0x0B    # BER_H
        sendData = (frame_command << 24) | frame_data
        enviar_puerto_serie(sendData)
        ber_e_q |= (recibir_puerto_serie()&0xFFFFFFFF) << 32

    elif command_str == 'IS_MEM_FULL':
        frame_command = 0x0C
        sendData = (frame_command << 24) | frame_data
        enviar_puerto_serie(sendData)
        mem_full = recibir_puerto_serie()
        continue
    elif command_str == 'EXIT': 
        break
    else:
        print("commando no valido.")
        continue

    
    sendData = (frame_command << 24) | frame_data
    enviar_puerto_serie(sendData)
    recibir_puerto_serie()

archivo_bram.close()
    
