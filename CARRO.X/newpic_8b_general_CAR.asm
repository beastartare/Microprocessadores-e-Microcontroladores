;*******************************************************************************
; UFSC- Universidade Federal de Santa Catarina
; Projeto: Exercicios
; Autor: Beatriz Schuelter Tartare
; Matricula: 24103805
; Exercicio 05 - Carro de transporte
    
;*******************************************************************************   

#include <P16F877A.INC> 
__CONFIG _CP_OFF & _CPD_OFF & _DEBUG_OFF & _LVP_OFF & _WRT_OFF & _BODEN_OFF & _PWRTE_OFF & _WDT_OFF & _XT_OSC
    
;****************** definindo variaveis ****************************************
	cblock 0x20                     ; Endereço inicial: 0x20 
	
		tempo0		
		tempo1			
		tempo2                  ; Variaveis usadas na rotina de delay.
		filtro
		temp			; Variavel temporaria.	
	endc 
    
;****************** variaveis de entrada ***************************************
    #define	    BT_M	PORTB,0	 ; Botao de inicio
    #define	    BT_1	PORTB,1  ; Sensor a
    #define	    BT_2	PORTB,2	 ; Sensor b	
    #define	    BT_3	PORTB,3  ; Sensor p
    
;****************** variaveis de saida ***************************************
    #define	    COMP	PORTD,7	 ; Comporta	
    #define	    ESQ 	PORTD,6	 ; Movimento para a esquerda
    #define	    DIR 	PORTD,5	 ; Movimento para a direita
    
;****************** Vetor de Reset *********************************************
   
    org 0x00                             ; Vetor de reset do uC.
    goto inicio                          ; Desvia para o inicio do programa.

    
;****************** Rotinas e Sub-Rotinas **************************************

    ;rotina de delay
delay_5s:
    movlw   .25           ; 25 ciclos para 5 segundos 
    movwf   tempo2        ; Carrega tempo2

conta:
    movlw   .200
    movwf   tempo1        ; Carrega tempo1
    movlw   .200
    movwf   tempo0        ; Carrega tempo0
    nop                   ; Perde tempo.
    nop                   ; Perde tempo.
    decfsz  tempo0, F     ; Verifica se é o fim do tempo0 (decrementa e ve se é zero)
    goto    $-2           ; se não volta duas instruções

    decfsz  tempo1, F     ; Verifica se é o fim do tempo1 (decrementa e ve se é zero)
    goto    $-6           ; se não volta seis instruções

    decfsz  tempo2, F     ; Verifica se é o fim do tempo2 (decrementa e ve se é zero)
    goto    conta         ; se não volta para o inicio da subrotina e repete o processo

    return

;****************** Inicio do programa *****************************************

inicio:
    clrf	PORTA		; Inicializa os Port's. Coloca todas pinos em 0.
    clrf	PORTB
    clrf	PORTC
    clrf	PORTD
    clrf	PORTE
    
    banksel	TRISA	        ; Seleciona banco de mem?ria 1
    
	movlw	0x00
	movwf   TRISA		; Configura PortA como saída
	movlw	0x0F
	movwf	TRISB		; Configura PortB como entrada (RB0, RB1, RB2, RB3)
	movlw	0x00
	movwf	TRISC		; Configura PortC como saída		
	movlw	0x00
	movwf	TRISD		; Configura PortD como saída		
	movlw	0x00
	movwf	TRISE		; Configura PortE como saída		
	movlw	0x00
	movwf	OPTION_REG      ; Configura Opcoes:
	                        ; Pull-Up habilitados.
				; Interrupcao na borda de subida do sinal no pino B0.
				; Timer0 incrementado pelo oscilador interno.
				; Prescaler WDT 1:1.
				; Prescaler Timer0 1:2.
	
	movlw	0x00
	movwf	INTCON		; Desabilita interrupcao RB0.

	movlw	0x00
	movwf	PIE1		; Desabilita interrupcoes perifericas.

	movlw	0x00
	movwf	PIE2		; Desabilita interrupcoes perifericas.

	movlw	0x07
	movwf	ADCON0		; Desliga conversor A/D, PortA e PortE com I/O digital.

	movlw	0x07
	movwf	CMCON		; Desliga comparadores internos.

	movlw	0x00
	movwf	CVRCON		; Desliga modulo de referencia interna de tens?o.

	banksel PORTA		; Seleciona banco de memoria 0.

	
loop:
    bcf ESQ                     ; Limpa a saída que representa a esquerda para quando a rotina voltar
    btfsc BT_M                  ; Verifica se o botão M (inicio) foi acionado
    goto loop                   ; Se não volta duas instruções
    btfsc BT_1                  ; Verifica se o botão 1 (Carro a esquerda) foi acionado
    goto $-3                    ; Se não volta duas instruções
    bsf DIR                     ; Se sim seta a saida que representa a direita 
    bcf ESQ                     ; Limpa a saída que representa a esquerda
    btfsc BT_2                  ; Verifica se o botão 2 (Chegou a direita) foi acionado
    goto $-3                    ; Se não volta tres instruções
    bsf COMP                    ; Se sim seta a saida que representa a comporta 
    bcf DIR                     ; Limpa a saída que representa a direita
    btfsc BT_3                  ; Verifica se o botão 3 (peso atingido) foi acionado
    goto $-3                    ; Se não volta tres instruções
    call delay_5s               ; Se sim chama o delay de 5 s
    bcf COMP                    ; Limpa a saída que representa a comporta
    bsf ESQ                     ; Seta a saída que representa a esquerda
    btfsc BT_1                  ; Verifica se o botão 1 (Chegou a direita) foi acionado
    goto $-3                    ; Se não volta tres instruções
    goto loop                   ; Se sim reinicia o loop
    end 