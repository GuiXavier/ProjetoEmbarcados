library ieee;
use ieee.std_logic_1164.all;

entity seguidor_linha_sincrono is
    port (
        -- Entradas principais
        clk            : in  std_logic;
        reset          : in  std_logic; -- Pino de reset (importante para inicialização)
        
        -- Entrada dos 5 sensores de linha
        sensores_linha : in  std_logic_vector(4 downto 0);

        -- Saídas para a Ponte H L298N
        motor_r_in1    : out std_logic;
        motor_r_in2    : out std_logic;
        motor_l_in1    : out std_logic;
        motor_l_in2    : out std_logic;
        
        -- Saída para LED de status
        led_status     : out std_logic
    );
end entity;

architecture rtl of seguidor_linha_sincrono is
begin

    -- Processo Principal SÍNCRONO: A lógica agora depende do clock e do reset.
    process(clk, reset)
    begin
        if reset = '1' then
            -- Estado inicial seguro quando o reset é ativado
            motor_l_in1 <= '0';
            motor_l_in2 <= '0';
            motor_r_in1 <= '0';
            motor_r_in2 <= '0';
            led_status  <= '0';
        elsif rising_edge(clk) then
            -- A lógica de controle só é executada na borda de subida do clock
            led_status <= '1'; -- Liga o LED para indicar funcionamento normal

            case sensores_linha is
                when "00100" => -- Frente
                    motor_l_in1 <= '1'; motor_l_in2 <= '0';
                    motor_r_in1 <= '1'; motor_r_in2 <= '0';
                when "01100" | "01000" => -- Virar Direita Suave
                    motor_l_in1 <= '1'; motor_l_in2 <= '0';
                    motor_r_in1 <= '0'; motor_r_in2 <= '0';
                when "00110" | "00010" => -- Virar Esquerda Suave
                    motor_l_in1 <= '0'; motor_l_in2 <= '0';
                    motor_r_in1 <= '1'; motor_r_in2 <= '0';
                when "11000" | "10000" => -- Virar Direita Brusco
                    motor_l_in1 <= '1'; motor_l_in2 <= '0';
                    motor_r_in1 <= '0'; motor_r_in2 <= '1';
                when "00011" | "00001" => -- Virar Esquerda Brusco
                    motor_l_in1 <= '0'; motor_l_in2 <= '1';
                    motor_r_in1 <= '1'; motor_r_in2 <= '0';
                when others => -- Perdido
                    motor_l_in1 <= '0'; motor_l_in2 <= '0';
                    motor_r_in1 <= '0'; motor_r_in2 <= '0';
            end case;
        end if;
    end process;

end architecture;