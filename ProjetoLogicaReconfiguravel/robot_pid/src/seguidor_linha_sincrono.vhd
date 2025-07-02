library ieee;
use ieee.std_logic_1164.all;

entity seguidor_linha_sincrono is
    port (
        -- Entradas principais
        clk            : in  std_logic;
        reset          : in  std_logic; -- Pino de reset (importante para inicialização)
        
  
        --Entrada dos 3 sensores de linha
        sensores_linha : in std_logic_vector(2 downto 0);             -- desabilitar para quando for fazer com apenas 3 sensores

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

            

            case sensores_lina is  -- Nessa condição talvez da para colocar o PID
                    when "010" => 
                        motor_l_in1 <= '1'; motor_l_in2 <= '0';
                        motor_r_in1 <= '1'; motor_r_in2 <= '0';
                    when "100" =>
                        motor_l_in1 <= '1'; motor_l_in2 <= '0';
                       motor_r_in1 <= '0'; motor_r_in2 <= '1';
                    when "001" => 
                        motor_l_in1 <= '0'; motor_l_in2 <= '1';
                        motor_r_in1 <= '1'; motor_r_in2 <= '0';
                    when others => 
                        motor_l_in1 <= '0'; motor_l_in2 <= '0';
                        motor_r_in1 <= '0'; motor_r_in2 <= '0';                     
            end case;

            
        end if;
    end process;

end architecture;