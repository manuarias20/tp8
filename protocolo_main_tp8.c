
#include <stdio.h>
#include <string.h>
#include "xparameters.h"
#include "xil_cache.h"
#include "xgpio.h"
#include "platform.h"
#include "xuartlite.h"
#include "microblaze_sleep.h"

#define PORT_IN	 		XPAR_AXI_GPIO_0_DEVICE_ID //XPAR_GPIO_0_DEVICE_ID
#define PORT_OUT 		XPAR_AXI_GPIO_0_DEVICE_ID //XPAR_GPIO_0_DEVICE_ID

//Device_ID Operaciones
#define def_SOFT_RST            0
#define def_ENABLE_MODULES      1
#define def_LOG_RUN             2
#define def_LOG_READ            3

XGpio GpioOutput;
XGpio GpioParameter;
XGpio GpioInput;
u32 GPO_Value;
u32 GPO_Param;
XUartLite uart_module;

//Funcion para recibir 1 byte bloqueante
//XUartLite_RecvByte((&uart_module)->RegBaseAddress)

int main()
{
	init_platform();
	int Status;
	XUartLite_Initialize(&uart_module, 0);

	GPO_Value=0x00000000;
	GPO_Param=0x00000000;
	unsigned char datos_rx[4];
	unsigned char datos_tx[4];

	Status=XGpio_Initialize(&GpioInput, PORT_IN);
	if(Status!=XST_SUCCESS){
        return XST_FAILURE;
    }
	Status=XGpio_Initialize(&GpioOutput, PORT_OUT);
	if(Status!=XST_SUCCESS){
		return XST_FAILURE;
	}
	XGpio_SetDataDirection(&GpioOutput, 1, 0x00000000);
	XGpio_SetDataDirection(&GpioInput, 1, 0xFFFFFFFF);

	u32 value;
	while(1){
		// RECEPCION DE COMANDO DESDE PC
		read(stdin,&datos_rx[0],1);
		read(stdin,&datos_rx[1],1);
		read(stdin,&datos_rx[2],1);
		read(stdin,&datos_rx[3],1);

		value = (u32) 0x00000000;
	    value |= (u32) (0x000000FF&(datos_rx[0]));
	    value |= (u32) (0x000000FF&(datos_rx[1]))<<8;
	    value |= (u32) (0x000000FF&(datos_rx[2]))<<16;
	    value |= (u32) (0x000000FF&(datos_rx[3]))<<24;

		// ENVIO DE COMANDO AL RF
		XGpio_DiscreteWrite(&GpioOutput,1, (u32)  value);
		XGpio_DiscreteWrite(&GpioOutput,1, (u32) (value | 0x00800000)); //Enable = 1
		XGpio_DiscreteWrite(&GpioOutput,1, (u32)  value);

		// LECTURA DE DATOS DEL RF
		value = XGpio_DiscreteRead(&GpioInput, 1);

		datos_tx[0]=(char)( value     &(0x000000FF));
		datos_tx[1]=(char)((value>>8) &(0x000000FF));
		datos_tx[2]=(char)((value>>16)&(0x000000FF));
		datos_tx[3]=(char)((value>>24)&(0x000000FF));

		while(XUartLite_IsSending(&uart_module)){}
		
		XUartLite_Send(&uart_module, &(datos_tx),1);

	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	// ACA es donde se escribe toda la funcionalidad
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		// if ((u32)datos_rx[3] == 0x0A && (u32)datos_rx[2] == 0x0A)
		// {
			// XGpio_DiscreteWrite(&GpioOutput,1, (u32) value&0x00000FFF);
			// // XGpio_DiscreteWrite(&GpioOutput,1, (u32) 0x00000000);
			// value = XGpio_DiscreteRead(&GpioInput, 1);
			// datos_tx=(char)(value&(0x0000000F));
			// while(XUartLite_IsSending(&uart_module)){}
			// XUartLite_Send(&uart_module, &(datos_tx),1);
		// }
		// else
		// {
			// XGpio_DiscreteWrite(&GpioOutput,1, (u32) value&0x00000FFF);
		// }
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// FIN de toda la funcionalidad
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    }
	
	cleanup_platform();
	return 0;
}
