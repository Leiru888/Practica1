#include "MKL46Z4.h"
#include "fsl_gpio.h"
#include "fsl_port.h"
#include "board.h"
#include "pin_mux.h"

/* Eventos registrados por la interrupción */
#define EVENT_SW1 (1U << 0)
#define EVENT_SW3 (1U << 1)

static volatile uint32_t eventos = 0;

/* Estado actual del autómata */
static uint8_t estado = 0;

/*
 * Actualiza los LEDs.
 *
 * Los LEDs de la FRDM-KL46Z son activos en bajo:
 * 0 = encendido
 * 1 = apagado
 */
static void actualizar_leds(void)
{
    uint8_t rojo;
    uint8_t verde;

    switch (estado)
    {
        case 0:
            rojo = 0;
            verde = 1;
            break;

        case 1:
            rojo = 0;
            verde = 0;
            break;

        case 2:
            rojo = 1;
            verde = 0;
            break;

        default:
            rojo = 1;
            verde = 1;
            break;
    }

    GPIO_PinWrite(BOARD_LED_RED_GPIO,
                  BOARD_LED_RED_GPIO_PIN, rojo);

    GPIO_PinWrite(BOARD_LED_GREEN_GPIO,
                  BOARD_LED_GREEN_GPIO_PIN, verde);
}

/*
 * Interrupción compartida por PORTC y PORTD.
 */
void PORTC_PORTD_IRQHandler(void)
{
    uint32_t flags;
    uint32_t mask;

    mask = (1U << BOARD_SW1_GPIO_PIN) |
           (1U << BOARD_SW3_GPIO_PIN);

    flags = GPIO_PortGetInterruptFlags(GPIOC);

    /* Nos quedamos únicamente con las interrupciones de los botones */
    flags &= mask;

    /* Limpiamos las interrupciones atendidas */
    GPIO_PortClearInterruptFlags(GPIOC, flags);

    if (flags & (1U << BOARD_SW1_GPIO_PIN))
    {
        eventos |= EVENT_SW1;
    }

    if (flags & (1U << BOARD_SW3_GPIO_PIN))
    {
        eventos |= EVENT_SW3;
    }
}

int main(void)
{
    uint32_t eventos_locales;

    /* Configuración de los pines */
    BOARD_InitButtons();
    BOARD_InitLEDs();

    /* Configuración de las interrupciones de los botones */
    PORT_SetPinInterruptConfig(
        BOARD_SW1_PORT,
        BOARD_SW1_GPIO_PIN,
        kPORT_InterruptFallingEdge
    );

    PORT_SetPinInterruptConfig(
        BOARD_SW3_PORT,
        BOARD_SW3_GPIO_PIN,
        kPORT_InterruptFallingEdge
    );

    /* Limpiar posibles interrupciones pendientes */
    GPIO_PortClearInterruptFlags(GPIOC,
        (1U << BOARD_SW1_GPIO_PIN) |
        (1U << BOARD_SW3_GPIO_PIN));

    NVIC_ClearPendingIRQ(PORTC_PORTD_IRQn);
    NVIC_EnableIRQ(PORTC_PORTD_IRQn);

    /* Estado inicial */
    estado = 3;
    actualizar_leds();

    while (1)
    {
        /*
         * Sección crítica: recogemos los eventos
         * sin que la ISR pueda modificarlos.
         */
        NVIC_DisableIRQ(PORTC_PORTD_IRQn);

        eventos_locales = eventos;
        eventos = 0;

        NVIC_EnableIRQ(PORTC_PORTD_IRQn);

        /* Avanzar al siguiente estado */
        if (eventos_locales & EVENT_SW1)
        {
            estado = (estado + 1U) % 4U;
        }

        /* Retroceder al estado anterior */
        if (eventos_locales & EVENT_SW3)
        {
            estado = (estado + 3U) % 4U;
        }

        actualizar_leds();
    }

    return 0;
}
