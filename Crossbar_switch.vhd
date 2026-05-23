library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Crossbar_switch is
	generic(
		DATA_WIDTH : natural := 12 
	);
	port(
		in0  : in std_logic_vector(DATA_WIDTH-1 downto 0); -- W
		in1  : in std_logic_vector(DATA_WIDTH-1 downto 0); -- N
		in2  : in std_logic_vector(DATA_WIDTH-1 downto 0); -- E
		in3  : in std_logic_vector(DATA_WIDTH-1 downto 0); -- S
		in4  : in std_logic_vector(DATA_WIDTH-1 downto 0); -- L
		
		sel0 : in std_logic_vector(2 downto 0); -- North output
		sel1 : in std_logic_vector(2 downto 0); -- East
		sel2 : in std_logic_vector(2 downto 0); -- South
		sel3 : in std_logic_vector(2 downto 0); -- West
		sel4 : in std_logic_vector(2 downto 0); -- Local
		
		out0 : out std_logic_vector(DATA_WIDTH-1 downto 0); -- North
		out1 : out std_logic_vector(DATA_WIDTH-1 downto 0); -- East
		out2 : out std_logic_vector(DATA_WIDTH-1 downto 0); -- South
		out3 : out std_logic_vector(DATA_WIDTH-1 downto 0); -- West
		out4 : out std_logic_vector(DATA_WIDTH-1 downto 0)  -- Local
	);
end entity Crossbar_switch;

architecture full of Crossbar_switch is
begin
	process(in0,in1,in2,in3,in4,sel0,sel1,sel2,sel3,sel4)
	begin
		-- Default to '0'
		out0 <= (others => '0');
		out1 <= (others => '0');
		out2 <= (others => '0');
		out3 <= (others => '0');
		out4 <= (others => '0');
		
		-- Full mux for each output
		case sel0 is
			when "000" => out0 <= in0; -- from W
			when "001" => out0 <= in1; -- from N
			when "010" => out0 <= in2; -- from E
			when "011" => out0 <= in3; -- from S
			when "100" => out0 <= in4; -- from L
			when others => null;
		end case;
		
		case sel1 is
			when "000" => out1 <= in0;
			when "001" => out1 <= in1;
			when "010" => out1 <= in2;
			when "011" => out1 <= in3;
			when "100" => out1 <= in4;
			when others => null;
		end case;
		
		case sel2 is
			when "000" => out2 <= in0;
			when "001" => out2 <= in1;
			when "010" => out2 <= in2;
			when "011" => out2 <= in3;
			when "100" => out2 <= in4;
			when others => null;
		end case;
		
		case sel3 is
			when "000" => out3 <= in0;
			when "001" => out3 <= in1;
			when "010" => out3 <= in2;
			when "011" => out3 <= in3;
			when "100" => out3 <= in4;
			when others => null;
		end case;
		
		case sel4 is
			when "000" => out4 <= in0;
			when "001" => out4 <= in1;
			when "010" => out4 <= in2;
			when "011" => out4 <= in3;
			when "100" => out4 <= in4;
			when others => null;
		end case;
		
	end process;
end architecture full;
