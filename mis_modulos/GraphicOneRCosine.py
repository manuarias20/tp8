import math
import numpy as np
import matplotlib.pyplot as plt
from tool._fixedInt import *

## Esta libreria contiene funciones para calcular y graficar para UN SOLO beta (roll-off).

def rcosine(beta, Tbaud, oversampling, Nbauds, intWidth=0, fractWidth=0, roundMode='', full_resolution=True, Norm=False):
    """ Respuesta al impulso del pulso de caida cosenoidal """
    t_vect = np.arange(-0.5*Nbauds*Tbaud, 0.5*Nbauds*Tbaud, 
                       float(Tbaud)/oversampling)

    y_vect = []
    for t in t_vect:
    	a = 0
    	if(full_resolution):
    		a = np.sinc(t/Tbaud)*(np.cos(np.pi*beta*t/Tbaud)
    					/(1-(4.0*beta*beta*t*t
    						/(Tbaud*Tbaud))))
    		y_vect.append(a)
    	else:
	    	a = DeFixedInt(intWidth,fractWidth,'S',roundMode,saturateMode='saturate')
	    	a.value = np.sinc(t/Tbaud)*(np.cos(np.pi*beta*t
	    				/Tbaud)/(1-(4.0*beta*beta*t*t
	    					/(Tbaud*Tbaud))))
	    	y_vect.append(a.fValue)

        

    y_vect = np.array(y_vect)

    if(Norm):  	
        return (t_vect, y_vect/np.sqrt(np.sum(y_vect**2)))
        #return (t_vect, y_vect/y_vect.sum())
    else:
        return (t_vect,y_vect)


def sub_graficar_rta_impulso(t, rc, os, Nbauds, name, show=False):
	### Generacion de las graficas
	#plt.figure(figsize=[14,7])
	#plt.plot(t,rc0,'ro-',linewidth=2.0,label=r'$\beta=0.0$')
	plt.subplot(4,4,(3,8))
	plt.plot(t,rc,'gs-',linewidth=2.0,label=r'$\beta=0.5$')
	#plt.plot(t,rc2,'k^-',linewidth=2.0,label=r'$\beta=1.0$')
	plt.legend()
	plt.grid(True)
	#plt.xlim(0,len(rc0)-1)
	plt.xlabel('Muestras')
	plt.ylabel('Magnitud')
	plt.title(name)

	if show:
		plt.show()


def graficar_conv_impulso(t, rc, os, Nbauds, name, show=False):
	symb00    = np.zeros(int(os)*3+1);symb00[os:len(symb00)-1:int(os)] = 1.0
	rcSymb00 = np.convolve(rc,symb00);

	offsetPot = os*((Nbauds//2)-1) + int(os/2)*(Nbauds%2) + 0.5*(os%2 and Nbauds%2)

	plt.figure(figsize=[14,7])
	#plt.subplot(3,1,1)
	plt.plot(np.arange(0,len(rc)),rc,'r.-',linewidth=2.0,label=r'$\beta=0.5$')
	plt.plot(np.arange(os,len(rc)+os),rc,'k.-',linewidth=2.0,label=r'$\beta=0.5$')
	plt.stem(np.arange(offsetPot,len(symb00)+offsetPot),symb00,label='Bits',use_line_collection=True)
	plt.plot(rcSymb00[os::],'--',linewidth=3.0,label='Convolution')
	plt.legend()
	plt.grid(True)
	#plt.xlim(0,35)
	#plt.ylim(-0.2,1.4)
	plt.xlabel('Muestras')
	plt.ylabel('Magnitud')
	plt.title(f'Rcosine - OS: {int(os)} - ' + name)

	if show:
		plt.show()


def resp_freq(filt, Ts, Nfreqs):
    """Computo de la respuesta en frecuencia de cualquier filtro FIR"""
    H = [] # Lista de salida de la magnitud
    A = [] # Lista de salida de la fase
    filt_len = len(filt)

    #### Genero el vector de frecuencias
    freqs = np.matrix(np.linspace(0,1.0/(2.0*Ts),Nfreqs))
    #### Calculo cuantas muestras necesito para 20 ciclo de
    #### la mas baja frec diferente de cero
    Lseq = 20.0/(freqs[0,1]*Ts)

    #### Genero el vector tiempo
    t = np.matrix(np.arange(0,Lseq))*Ts

    #### Genero la matriz de 2pifTn
    Omega = 2.0j*np.pi*(t.transpose()*freqs)

    #### Valuacion de la exponencial compleja en todo el
    #### rango de frecuencias
    fin = np.exp(Omega)

    #### Suma de convolucion con cada una de las exponenciales complejas
    for i in range(0,np.size(fin,1)):
        fout = np.convolve(np.squeeze(np.array(fin[:,i].transpose())),filt)
        mfout = abs(fout[filt_len:len(fout)-filt_len])
        afout = np.angle(fout[filt_len:len(fout)-filt_len])
        H.append(mfout.sum()/len(mfout))
        A.append(afout.sum()/len(afout))

    return [H,A,list(np.squeeze(np.array(freqs)))]


def sub_graficar_rta_frecuencia(rc, Ts, Nfreqs, T, show=False):
	### Calculo respuesta en frec para los tres pulsos
	[H0,A0,F0] = resp_freq(rc, Ts, Nfreqs)

	### Generacion de los graficos
	# plt.figure(figsize=[14,6])
	plt.subplot(4,4,(9,14))
	plt.semilogx(F0, 20*np.log10(H0),'r', linewidth=2.0, label=r'$\beta=0.5$')

	plt.axvline(x=(1./Ts)/2.,color='k',linewidth=2.0)
	plt.axvline(x=(1./T)/2.,color='k',linewidth=2.0)
	plt.axhline(y=20*np.log10(0.5),color='k',linewidth=2.0)
	plt.legend(loc=3)
	plt.grid(True)
	plt.xlim(F0[1],F0[len(F0)-1])
	plt.xlabel('Frequencia [Hz]')
	plt.ylabel('Magnitud [dB]')
	# plt.title(name)

	if show:
		plt.show()


def graficar_distribucion(Nsymb, symbolsI, symbolsQ):
	label = 'Simbolos: %d' % Nsymb
	plt.figure(figsize=[14,6])
	plt.subplot(1,2,1)
	plt.hist(symbolsI,label=label)
	plt.legend()
	plt.xlabel('Simbolos')
	plt.ylabel('Repeticiones')
	plt.subplot(1,2,2)
	plt.hist(symbolsQ,label=label)
	plt.legend()
	plt.xlabel('Simbolos')
	plt.ylabel('Repeticiones')

	plt.show()


def sub_graficar_simbolos(Nsymb, zsymbI, zsymbQ, name, show=False):

	# plt.figure(figsize=[10,6])
	plt.subplot(4,4,(1,2))
	plt.title(name)
	plt.plot(zsymbI,'o')
	plt.xlim(0,20)
	plt.grid(True)
	plt.subplot(4,4,(5,6))
	plt.plot(zsymbQ,'o')
	plt.xlim(0,20)
	plt.grid(True)
	
	if show:
		plt.show()


def calculo_convolucion(rc, zsymbI, zsymbQ):
	## Convolucion
	symb_outI = np.convolve(rc,zsymbI,'full') ; symb_outQ = np.convolve(rc,zsymbQ,'full')


	return symb_outI,symb_outQ


def sub_graficar_convolucion(beta, symb_outI, symb_outQ, show=False):

	# plt.figure(figsize=[10,6])
	plt.subplot(4,4,(11,12))
	# plt.title(name)
	plt.plot(symb_outI,'r-',linewidth=2.0,label=r'$\beta=%2.2f$'%beta)
	# plt.plot(symb_out1I,'g-',linewidth=2.0,label=r'$\beta=%2.2f$'%beta[1])
	# plt.plot(symb_out2I,'k-',linewidth=2.0,label=r'$\beta=%2.2f$'%beta[2])
	plt.xlim(1000,1250)
	plt.grid(True)
	plt.legend()
	# plt.xlabel('Muestras')
	# plt.ylabel('Magnitud')

	plt.subplot(4,4,(15,16))
	plt.plot(symb_outQ,'r-',linewidth=2.0,label=r'$\beta=%2.2f$'%beta)
	# plt.plot(symb_out1Q,'g-',linewidth=2.0,label=r'$\beta=%2.2f$'%beta[1])
	# plt.plot(symb_out2Q,'k-',linewidth=2.0,label=r'$\beta=%2.2f$'%beta[2])
	plt.xlim(1000,1250)
	plt.grid(True)
	plt.legend()
	plt.xlabel('Muestras')
	# plt.ylabel('Magnitud')

	

	#plt.figure(figsize=[10,6])
	#plt.plot(np.correlate(symbolsI,2*(symb_out0I[3:len(symb_out0I):int(os)]>0.0)-1,'same'))

	if show:
		plt.show()


def calculo_correlacion(symbI, symbQ, Rx_symbI, Rx_symbQ):
	## Convolucion
	correlate_I = np.correlate(symbI,Rx_symbI,'full') ; correlate_Q = np.correlate(symbQ,Rx_symbQ,'full')

	return correlate_I,correlate_Q


def sub_graficar_correlacion(correlate_I, correlate_Q, name, show=False):

	# plt.figure(figsize=[10,6])
	plt.subplot(4,4,(3,4))
	plt.title(name)
	plt.plot(correlate_I,'r-',linewidth=2.0,label='Correlacion I')
	# plt.plot(symb_out1I,'g-',linewidth=2.0,label=r'$\beta=%2.2f$'%beta[1])
	# plt.plot(symb_out2I,'k-',linewidth=2.0,label=r'$\beta=%2.2f$'%beta[2])
	#plt.xlim(1000,1250)
	plt.grid(True)
	plt.legend()
	plt.xlabel('Muestras')
	plt.ylabel('Magnitud')

	plt.subplot(4,4,(7,8))
	plt.plot(correlate_Q,'r-',linewidth=2.0,label='Correlacion Q')
	# plt.plot(symb_out1Q,'g-',linewidth=2.0,label=r'$\beta=%2.2f$'%beta[1])
	# plt.plot(symb_out2Q,'k-',linewidth=2.0,label=r'$\beta=%2.2f$'%beta[2])
	#plt.xlim(1000,1250)
	plt.grid(True)
	plt.legend()
	# plt.xlabel('Muestras')
	plt.ylabel('Magnitud')

	

	#plt.figure(figsize=[10,6])
	#plt.plot(np.correlate(symbolsI,2*(symb_out0I[3:len(symb_out0I):int(os)]>0.0)-1,'same'))

	if show:
		plt.show()


def eyediagram(data, n, offset, period,name):
    span     = 2*n
    segments = int(len(data)/span)
    xmax     = (n-1)*period
    xmin     = -(n-1)*period
    x        = list(np.arange(-n,n,)*period)
    xoff     = offset

    
    #plt.figure()
    
    for i in range(0,segments-1):
    	plt.plot(x, data[(i*span+xoff):((i+1)*span+xoff)],'b')
    plt.grid(True)
    plt.xlim(xmin, xmax)
    #plt.show()


def sub_graficar_diagrama_ojo(os, offset, Nbauds, symb_outI, symb_outQ, name, show=False):

	# plt.figure()
	plt.subplot(4,4,(1,5))
	plt.title(name + ' - I')
	eyediagram(symb_outI[100:len(symb_outI)-100],os,offset,Nbauds,name)
	plt.subplot(4,4,(2,6))
	plt.title(name + ' - Q')
	eyediagram(symb_outQ[100:len(symb_outQ)-100],os,offset,Nbauds,name)
	
	if show:
		plt.show()

	#plt.show(block=False)
	#raw_input("Press Enter")
	#plt.close()


def graficar_constelacion(os, offset, Nbauds, symb_outI, symb_outQ, name, show=False):
	plt.subplot(4,4,(9+offset,13+offset))
	# plt.title(name)
	plt.plot(symb_outI[100+offset:len(symb_outI)-(100-offset):int(os)],
	         symb_outQ[100+offset:len(symb_outQ)-(100-offset):int(os)],
	             '.',linewidth=2.0)
	plt.xlim((-2, 2))
	plt.ylim((-2, 2))
	plt.grid(True)
	plt.xlabel(f'Real (Offset={offset})')
	if offset==0:
		plt.ylabel('Imag')

	if show:
		plt.show()


def sub_grafico_fases_constelacion(os, Nbauds, symb_outI, symb_outQ, name, show=False):
	## Grafico todas las constelaciones
	# Full resolution
	for i in range(os):
		if i < (os - 1):
			graficar_constelacion(os, i, Nbauds, symb_outI, symb_outQ,
								  name+". Constelacion fase "+str(i+1)+" (offset = "+str(i)+")", show=False)
		else:
			graficar_constelacion(os, i, Nbauds, symb_outI, symb_outQ,
								  name+". Constelacion fase "+str(i+1)+" (offset = "+str(i)+")", show)
