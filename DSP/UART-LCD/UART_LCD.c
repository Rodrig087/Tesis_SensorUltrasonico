// LCD module connections
sbit LCD_RS at RD0_bit;
sbit LCD_EN at RD1_bit;
sbit LCD_D4 at RD2_bit;
sbit LCD_D5 at RD3_bit;
sbit LCD_D6 at RD4_bit;
sbit LCD_D7 at RD5_bit;

sbit LCD_RS_Direction at TRISD0_bit;
sbit LCD_EN_Direction at TRISD1_bit;
sbit LCD_D4_Direction at TRISD2_bit;
sbit LCD_D5_Direction at TRISD3_bit;
sbit LCD_D6_Direction at TRISD4_bit;
sbit LCD_D7_Direction at TRISD5_bit;
// End LCD module connections

char uart_rd;



void main() {

     Lcd_Init();                        // Initialize LCD
     Lcd_Cmd(_LCD_CLEAR);               // Clear display
     Lcd_Cmd(_LCD_CURSOR_OFF);          // Cursor off
     Lcd_Out(1, 1, "Hello!");
     
     UART1_Init(9600);               // Initialize UART module at 9600 bps
     Delay_ms(100);                  // Wait for UART module to stabilize
     
     while (1){

            if (UART1_Data_Ready()) {     // If data is received,
               uart_rd = UART1_Read();     // read the received data,
               //UART1_Write(uart_rd);       // and send data via UART
               Lcd_Out(1, 1, "TOF: ");
               Lcd_Chr_Cp(uart_rd);
               
            }

     }

}