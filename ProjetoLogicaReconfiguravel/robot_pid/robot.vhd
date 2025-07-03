-- Bibliotecas padrão do IEEE
library ieee;
use ieee.std_logic_1164.all;

-- A entidade foi simplificada, removendo a entrada dos sensores que não é mais necessária.
entity robot is
    port (
        -- Entradas principais
        clk         : in  std_logic;
        reset       : in  std_logic; -- Pino de reset para inicialização segura

        -- Saídas para a Ponte H L298N (mapeadas para os pinos da Tang Nano)
        -- Motor Esquerdo (conectado em OUT1/OUT2 da Ponte H)
        motor_l_in1 : out std_logic; -- Conectado ao IN1 da Ponte H (Pino 34 da FPGA)
        motor_l_in2 : out std_logic; -- Conectado ao IN2 da Ponte H (Pino 29 da FPGA)

        
        -- Motor Direito (conectado em OUT4/OUT3 da Ponte H)
        motor_r_in1 : out std_logic; -- Conectado ao IN3 da Ponte H (Pino 20 da FPGA)
        motor_r_in2 : out std_logic; -- Conectado ao IN4 da Ponte H (Pino 19 da FPGA)
        
        -- Saída para LED de status (opcional, mas útil)
        led_status  : out std_logic
    );
end entity;

architecture rtl of robot is
begin

    -- Processo Principal SÍNCRONO: A lógica depende do clock e do reset.
    process(clk, reset)
    begin
        -- Se o pino de reset estiver em nível alto ('1'), desliga tudo.
        if reset = '1' then
            -- Estado inicial seguro: motores parados e LED desligado.
            motor_l_in1 <= '0';
            motor_l_in2 <= '0';
            motor_r_in1 <= '0';
            motor_r_in2 <= '0';
            led_status  <= '0';
            
        -- Na borda de subida do clock (e com reset em '0'), executa a lógica principal.
        elsif rising_edge(clk) then
            
            -- Liga o LED de status para indicar que o código está rodando.
            led_status <= '1';

            -- COMANDO FIXO: ANDAR PARA FRENTE
            -- A lógica dos sensores foi removida. Agora o robô sempre tentará andar para frente.
            
            -- Aciona o motor esquerdo para frente
            motor_l_in1 <= '1';
            motor_l_in2 <= '0';
            
            -- Aciona o motor direito para frente
            motor_r_in1 <= '1';
            motor_r_in2 <= '0';
            
        end if;
    end process;

end architecture;