library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seguidor_linha is
    port (

        -- configurar as portas no FloorPlanner

        clk         : in  std_logic;
        reset       : in  std_logic;
        btn_start   : in  std_logic;
        ir_esquerdo : in  std_logic;
        ir_direito  : in  std_logic;

        motor_r_in1 : out std_logic;
        motor_r_in2 : out std_logic;
        motor_l_in1 : out std_logic;
        motor_l_in2 : out std_logic;
        
        -- sensores
        ir1_sensor : in std_logic;
        ir2_sensor : in std_logic;
        ir3_sensor : in std_logic;
        
        -- testando o sensor

        led_out : out std_logic


    );
end entity;

architecture rtl of seguidor_linha is
    signal estado        : std_logic := '0'; -- 0 = parado, 1 = em funcionamento
    signal btn_sync_0    : std_logic := '0';
    signal btn_sync_1    : std_logic := '0';
    signal btn_rise_edge : std_logic := '0';

    signal counter       : unsigned(23 downto 0) := (others => '0');
    signal debounce_ok   : std_logic := '0';

begin

    -- Sincronizador de botão
    process(clk)
    begin
        if rising_edge(clk) then
            btn_sync_0 <= btn_start;
            btn_sync_1 <= btn_sync_0;
        end if;
    end process;

    -- Detector de borda de subida (rising edge)
    process(clk)
    begin
        if rising_edge(clk) then
            btn_rise_edge <= btn_sync_0 and not btn_sync_1;
        end if;
    end process;

    -- Debounce: incrementa contador enquanto botão estiver pressionado
    process(clk, reset)
    begin
        if reset = '1' then
            counter      <= (others => '0');
            debounce_ok  <= '0';
        elsif rising_edge(clk) then
            if btn_sync_0 = '1' then
                if counter < x"7FFFFF" then     -- x"7FFFFF" = 24 bits
                    counter <= counter + 1;
                else
                    debounce_ok <= '1';
                end if;
            else
                counter     <= (others => '0');
                debounce_ok <= '0';
            end if;
        end if;
    end process;

    -- Alternância de estado do robô
    process(clk, reset)
    begin
        if reset = '1' then
            estado <= '0';
        elsif rising_edge(clk) then
            if debounce_ok = '1' and btn_rise_edge = '1' then
                estado <= not estado;
            end if;
        end if;
    end process;

    -- Lógica de controle de motor
    process(clk)
    begin
        if rising_edge(clk) then
            if estado = '1' then
                -- PRETO = '1', BRANCO = '0'
                if ir_esquerdo = '0' and ir_direito = '0' then
                    -- Frente
                    motor_l_in1 <= '1'; motor_l_in2 <= '0';
                    motor_r_in1 <= '1'; motor_r_in2 <= '0';
                elsif ir_esquerdo = '1' and ir_direito = '0' then
                    -- Corrigir para esquerda
                    motor_l_in1 <= '0'; motor_l_in2 <= '1';
                    motor_r_in1 <= '1'; motor_r_in2 <= '0';
                elsif ir_esquerdo = '0' and ir_direito = '1' then
                    -- Corrigir para direita
                    motor_l_in1 <= '1'; motor_l_in2 <= '0';
                    motor_r_in1 <= '0'; motor_r_in2 <= '1';
                else
                    -- Ambos no preto (ou ruído) – segue reto
                    motor_l_in1 <= '1'; motor_l_in2 <= '0';
                    motor_r_in1 <= '1'; motor_r_in2 <= '0';
                end if;
            else
                -- Estado parado
                motor_l_in1 <= '0'; motor_l_in2 <= '0';
                motor_r_in1 <= '0'; motor_r_in2 <= '0';
            end if;
       
        end if;
    end process;

   
end architecture;
