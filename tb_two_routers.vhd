library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity tb_two_routers is
end entity tb_two_routers;
architecture sim of tb_two_routers is
constant DATA_WIDTH : natural := 12;
constant CLK_PERIOD : time := 10 ns;
signal clk   : std_logic := '0';
signal reset : std_logic := '1';
-- Router 5 (1,1)
signal west_in_data5, north_in_data5, east_in_data5, south_in_data5, local_in_data5 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
signal west_in_wr5, north_in_wr5, east_in_wr5, south_in_wr5, local_in_wr5 : std_logic := '0';
signal west_out_full5, north_out_full5, east_out_full5, south_out_full5, local_out_full5 : std_logic;
signal west_in_credit5, north_in_credit5, east_in_credit5, south_in_credit5 : std_logic := '1';
signal west_out_data5, north_out_data5, east_out_data5, south_out_data5, local_out_data5 : std_logic_vector(DATA_WIDTH-1 downto 0);
signal west_out_wr5, north_out_wr5, east_out_wr5, south_out_wr5 : std_logic;
-- Router 6 (2,1)
signal west_in_data6, north_in_data6, east_in_data6, south_in_data6, local_in_data6 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
signal west_in_wr6, north_in_wr6, east_in_wr6, south_in_wr6, local_in_wr6 : std_logic := '0';
signal west_out_full6, north_out_full6, east_out_full6, south_out_full6, local_out_full6 : std_logic;
signal west_in_credit6, north_in_credit6, east_in_credit6, south_in_credit6 : std_logic := '1';
signal west_out_data6, north_out_data6, east_out_data6, south_out_data6, local_out_data6 : std_logic_vector(DATA_WIDTH-1 downto 0);
signal west_out_wr6, north_out_wr6, east_out_wr6, south_out_wr6 : std_logic;
constant ZEROS : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    function to_hex(slv: std_logic_vector) return string is
        variable hex: string(1 to 3);
        variable nibble: std_logic_vector(3 downto 0);
    begin
        hex := "000";

        -- Highest nibble (bits 11:8)
        nibble := slv(11 downto 8);
        case nibble is
            when "0000" => hex(1) := '0';
            when "0001" => hex(1) := '1';
            when "0010" => hex(1) := '2';
            when "0011" => hex(1) := '3';
            when "0100" => hex(1) := '4';
            when "0101" => hex(1) := '5';
            when "0110" => hex(1) := '6';
            when "0111" => hex(1) := '7';
            when "1000" => hex(1) := '8';
            when "1001" => hex(1) := '9';
            when "1010" => hex(1) := 'A';
            when "1011" => hex(1) := 'B';
            when "1100" => hex(1) := 'C';
            when "1101" => hex(1) := 'D';
            when "1110" => hex(1) := 'E';
            when "1111" => hex(1) := 'F';
            when others => hex(1) := 'X';
        end case;

        -- Middle nibble (bits 7:4)
        nibble := slv(7 downto 4);
        case nibble is
            when "0000" => hex(2) := '0';
            when "0001" => hex(2) := '1';
            when "0010" => hex(2) := '2';
            when "0011" => hex(2) := '3';
            when "0100" => hex(2) := '4';
            when "0101" => hex(2) := '5';
            when "0110" => hex(2) := '6';
            when "0111" => hex(2) := '7';
            when "1000" => hex(2) := '8';
            when "1001" => hex(2) := '9';
            when "1010" => hex(2) := 'A';
            when "1011" => hex(2) := 'B';
            when "1100" => hex(2) := 'C';
            when "1101" => hex(2) := 'D';
            when "1110" => hex(2) := 'E';
            when "1111" => hex(2) := 'F';
            when others => hex(2) := 'X';
        end case;

        -- Lowest nibble (bits 3:0)
        nibble := slv(3 downto 0);
        case nibble is
            when "0000" => hex(3) := '0';
            when "0001" => hex(3) := '1';
            when "0010" => hex(3) := '2';
            when "0011" => hex(3) := '3';
            when "0100" => hex(3) := '4';
            when "0101" => hex(3) := '5';
            when "0110" => hex(3) := '6';
            when "0111" => hex(3) := '7';
            when "1000" => hex(3) := '8';
            when "1001" => hex(3) := '9';
            when "1010" => hex(3) := 'A';
            when "1011" => hex(3) := 'B';
            when "1100" => hex(3) := 'C';
            when "1101" => hex(3) := 'D';
            when "1110" => hex(3) := 'E';
            when "1111" => hex(3) := 'F';
            when others => hex(3) := 'X';
        end case;

        return "0x" & hex;
    end function;
begin
clk <= not clk after CLK_PERIOD / 2;
router5: entity work.Router
generic map (DATA_WIDTH => DATA_WIDTH, X_local => 1, Y_local => 1)
port map (
clk => clk, reset => reset,
west_in_data => west_in_data5, west_in_wr => west_in_wr5, west_out_full => west_out_full5,
north_in_data => north_in_data5, north_in_wr => north_in_wr5, north_out_full => north_out_full5,
east_in_data => east_in_data5, east_in_wr => east_in_wr5, east_out_full => east_out_full5,
south_in_data => south_in_data5, south_in_wr => south_in_wr5, south_out_full => south_out_full5,
local_in_data => local_in_data5, local_in_wr => local_in_wr5, local_out_full => local_out_full5,
west_in_credit => west_in_credit5, north_in_credit => north_in_credit5,
east_in_credit => east_in_credit5, south_in_credit => south_in_credit5,
west_out_data => west_out_data5, west_out_wr => west_out_wr5,
north_out_data => north_out_data5, north_out_wr => north_out_wr5,
east_out_data => east_out_data5, east_out_wr => east_out_wr5,
south_out_data => south_out_data5, south_out_wr => south_out_wr5,
local_out_data => local_out_data5
);
router6: entity work.Router
generic map (DATA_WIDTH => DATA_WIDTH, X_local => 2, Y_local => 1)
port map (
clk => clk, reset => reset,
west_in_data => west_in_data6, west_in_wr => west_in_wr6, west_out_full => west_out_full6,
north_in_data => north_in_data6, north_in_wr => north_in_wr6, north_out_full => north_out_full6,
east_in_data => east_in_data6, east_in_wr => east_in_wr6, east_out_full => east_out_full6,
south_in_data => south_in_data6, south_in_wr => south_in_wr6, south_out_full => south_out_full6,
local_in_data => local_in_data6, local_in_wr => local_in_wr6, local_out_full => local_out_full6,
west_in_credit => west_in_credit6, north_in_credit => north_in_credit6,
east_in_credit => east_in_credit6, south_in_credit => south_in_credit6,
west_out_data => west_out_data6, west_out_wr => west_out_wr6,
north_out_data => north_out_data6, north_out_wr => north_out_wr6,
east_out_data => east_out_data6, east_out_wr => east_out_wr6,
south_out_data => south_out_data6, south_out_wr => south_out_wr6,
local_out_data => local_out_data6
);
west_in_data6 <= east_out_data5;
west_in_wr6   <= east_out_wr5;
east_in_credit5 <= not west_out_full6;
east_in_data5 <= west_out_data6;
east_in_wr5   <= west_out_wr6;
west_in_credit6 <= not east_out_full5;
monitor: process(clk)
variable cycle : integer := 0;
begin
if rising_edge(clk) then
cycle := cycle + 1;
if west_out_wr5 = '1' then report "Cycle " & integer'image(cycle) & ": R5 WEST  = " & to_hex(west_out_data5); end if;
if north_out_wr5 = '1' then report "Cycle " & integer'image(cycle) & ": R5 NORTH = " & to_hex(north_out_data5); end if;
if east_out_wr5 = '1' then report "Cycle " & integer'image(cycle) & ": R5 EAST  = " & to_hex(east_out_data5); end if;
if south_out_wr5 = '1' then report "Cycle " & integer'image(cycle) & ": R5 SOUTH = " & to_hex(south_out_data5); end if;
if local_out_data5 /= ZEROS then report "Cycle " & integer'image(cycle) & ": R5 LOCAL = " & to_hex(local_out_data5); end if;
if west_out_wr6 = '1' then report "Cycle " & integer'image(cycle) & ": R6 WEST  = " & to_hex(west_out_data6); end if;
if north_out_wr6 = '1' then report "Cycle " & integer'image(cycle) & ": R6 NORTH = " & to_hex(north_out_data6); end if;
if east_out_wr6 = '1' then report "Cycle " & integer'image(cycle) & ": R6 EAST  = " & to_hex(east_out_data6); end if;
if south_out_wr6 = '1' then report "Cycle " & integer'image(cycle) & ": R6 SOUTH = " & to_hex(south_out_data6); end if;
if local_out_data6 /= ZEROS then report "Cycle " & integer'image(cycle) & ": R6 LOCAL = " & to_hex(local_out_data6); end if;
end if;
end process;
stim: process
variable pass_count, fail_count, test_count : integer := 0;
variable output_detected : boolean;
variable timeout_counter : integer;
variable expected_output : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
reset <= '1';
wait for 20 ns;
reset <= '0';
wait for 20 ns;
west_in_credit5 <= '1'; north_in_credit5 <= '1'; south_in_credit5 <= '1';
east_in_credit6 <= '1'; north_in_credit6 <= '1'; south_in_credit6 <= '1';
-- TEST 1: n5 -> s5
test_count := test_count + 1;
expected_output := "000101100001";
north_in_data5 <= expected_output;
north_in_wr5 <= '1';
wait until rising_edge(clk);
north_in_wr5 <= '0';
output_detected := false; timeout_counter := 0;
while timeout_counter < 50 and not output_detected loop
wait until rising_edge(clk);
timeout_counter := timeout_counter + 1;
if south_out_wr5 = '1' and south_out_data5 = expected_output then
output_detected := true; pass_count := pass_count + 1;
report "TEST 1 PASS: n5 -> s5 (" & to_hex(expected_output) & ")";
end if;
end loop;
if not output_detected then fail_count := fail_count + 1; report "TEST 1 FAIL"; end if;
wait for 10 * CLK_PERIOD;
-- TEST 2: e6 -> w5
test_count := test_count + 1;
expected_output := "001000010010";
east_in_data6 <= expected_output;
east_in_wr6 <= '1';
wait until rising_edge(clk);
east_in_wr6 <= '0';
output_detected := false; timeout_counter := 0;
while timeout_counter < 50 and not output_detected loop
wait until rising_edge(clk);
timeout_counter := timeout_counter + 1;
if west_out_wr5 = '1' and west_out_data5 = expected_output then
output_detected := true; pass_count := pass_count + 1;
report "TEST 2 PASS: e6 -> w5 (" & to_hex(expected_output) & ")";
end if;
end loop;
if not output_detected then fail_count := fail_count + 1; report "TEST 2 FAIL"; end if;
wait for 10 * CLK_PERIOD;
-- TEST 3: s6 -> n5
test_count := test_count + 1;
expected_output := "001101000011";
south_in_data6 <= expected_output;
south_in_wr6 <= '1';
wait until rising_edge(clk);
south_in_wr6 <= '0';
output_detected := false; timeout_counter := 0;
while timeout_counter < 50 and not output_detected loop
wait until rising_edge(clk);
timeout_counter := timeout_counter + 1;
if north_out_wr5 = '1' and north_out_data5 = expected_output then
output_detected := true; pass_count := pass_count + 1;
report "TEST 3 PASS: s6 -> n5 (" & to_hex(expected_output) & ")";
end if;
end loop;
if not output_detected then fail_count := fail_count + 1; report "TEST 3 FAIL"; end if;
wait for 10 * CLK_PERIOD;
-- TEST 4: s5 -> n6
test_count := test_count + 1;
expected_output := "010010000100";
south_in_data5 <= expected_output;
south_in_wr5 <= '1';
wait until rising_edge(clk);
south_in_wr5 <= '0';
output_detected := false; timeout_counter := 0;
while timeout_counter < 50 and not output_detected loop
wait until rising_edge(clk);
timeout_counter := timeout_counter + 1;
if north_out_wr6 = '1' and north_out_data6 = expected_output then
output_detected := true; pass_count := pass_count + 1;
report "TEST 4 PASS: s5 -> n6 (" & to_hex(expected_output) & ")";
end if;
end loop;
if not output_detected then fail_count := fail_count + 1; report "TEST 4 FAIL"; end if;
wait for 10 * CLK_PERIOD;
-- TEST 5: local6 -> n5
test_count := test_count + 1;
expected_output := "010101000101";
local_in_data6 <= expected_output;
local_in_wr6 <= '1';
wait until rising_edge(clk);
local_in_wr6 <= '0';
output_detected := false; timeout_counter := 0;
while timeout_counter < 50 and not output_detected loop
wait until rising_edge(clk);
timeout_counter := timeout_counter + 1;
if north_out_wr5 = '1' and north_out_data5 = expected_output then
output_detected := true; pass_count := pass_count + 1;
report "TEST 5 PASS: local6 -> n5 (" & to_hex(expected_output) & ")";
end if;
end loop;
if not output_detected then fail_count := fail_count + 1; report "TEST 5 FAIL"; end if;
wait for 10 * CLK_PERIOD;
-- TEST 6: e6 -> s5
test_count := test_count + 1;
expected_output := "011001100110";
east_in_data6 <= expected_output;
east_in_wr6 <= '1';
wait until rising_edge(clk);
east_in_wr6 <= '0';
output_detected := false; timeout_counter := 0;
while timeout_counter < 50 and not output_detected loop
wait until rising_edge(clk);
timeout_counter := timeout_counter + 1;
if south_out_wr5 = '1' and south_out_data5 = expected_output then
output_detected := true; pass_count := pass_count + 1;
report "TEST 6 PASS: e6 -> s5 (" & to_hex(expected_output) & ")";
end if;
end loop;
if not output_detected then fail_count := fail_count + 1; report "TEST 6 FAIL"; end if;
wait for 10 * CLK_PERIOD;
-- TEST 7: n5 -> s5 repeat
test_count := test_count + 1;
expected_output := "011101100111";
north_in_data5 <= expected_output;
north_in_wr5 <= '1';
wait until rising_edge(clk);
north_in_wr5 <= '0';
output_detected := false; timeout_counter := 0;
while timeout_counter < 50 and not output_detected loop
wait until rising_edge(clk);
timeout_counter := timeout_counter + 1;
if south_out_wr5 = '1' and south_out_data5 = expected_output then
output_detected := true; pass_count := pass_count + 1;
report "TEST 7 PASS: n5 -> s5 repeat (" & to_hex(expected_output) & ")";
end if;
end loop;
if not output_detected then fail_count := fail_count + 1; report "TEST 7 FAIL"; end if;
wait for 20 * CLK_PERIOD;
report "========================================";
report "FINAL RESULT:";
report "  Tests run    : " & integer'image(test_count);
report "  Passed       : " & integer'image(pass_count);
report "  Failed       : " & integer'image(fail_count);
if fail_count = 0 then
report ">>> ALL TESTS PASSED!!! YOUR NOC ROUTER IS PERFECT!!! <<<";
else
report ">>> SOME TESTS FAILED - CHECK THE MONITOR OUTPUT <<<";
end if;
report "========================================";
wait;
end process;
end architecture sim;
