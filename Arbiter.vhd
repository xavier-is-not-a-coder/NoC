library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Arbiter is
    port(
        clk   : in  std_logic;
        reset : in  std_logic;

        routing_dir0 : in std_logic_vector(2 downto 0);
        routing_dir1 : in std_logic_vector(2 downto 0);
        routing_dir2 : in std_logic_vector(2 downto 0);
        routing_dir3 : in std_logic_vector(2 downto 0);
        routing_dir4 : in std_logic_vector(2 downto 0);

        fifo_empty0  : in std_logic;
        fifo_empty1  : in std_logic;
        fifo_empty2  : in std_logic;
        fifo_empty3  : in std_logic;
        fifo_empty4  : in std_logic;

        credit_in    : in std_logic_vector(3 downto 0);  -- W,N,E,S

        fifo_rd      : out std_logic_vector(4 downto 0);
        write_request : out std_logic_vector(3 downto 0);

        sel0, sel1, sel2, sel3, sel4 : out std_logic_vector(2 downto 0)
    );
end entity Arbiter;

architecture rtl of Arbiter is

    constant DIR_W : std_logic_vector(2 downto 0) := "000";  -- WEST
    constant DIR_E : std_logic_vector(2 downto 0) := "001";  -- EAST
    constant DIR_N : std_logic_vector(2 downto 0) := "010";  -- NORTH
    constant DIR_S : std_logic_vector(2 downto 0) := "011";  -- SOUTH
    constant DIR_L : std_logic_vector(2 downto 0) := "100";  -- LOCAL

    signal rr_ptr : integer range 0 to 4 := 0;

    signal fifo_rd_int   : std_logic_vector(4 downto 0) := (others => '0');
    signal write_req_int : std_logic_vector(3 downto 0) := (others => '0');
    signal sel0_int, sel1_int, sel2_int, sel3_int, sel4_int : std_logic_vector(2 downto 0) := (others => '0');

    type routing_array is array (0 to 4) of std_logic_vector(2 downto 0);
    signal routing_dir : routing_array;

    type empty_array is array (0 to 4) of std_logic;
    signal fifo_empty : empty_array;

begin

    routing_dir(0) <= routing_dir0;
    routing_dir(1) <= routing_dir1;
    routing_dir(2) <= routing_dir2;
    routing_dir(3) <= routing_dir3;
    routing_dir(4) <= routing_dir4;

    fifo_empty(0) <= fifo_empty0;
    fifo_empty(1) <= fifo_empty1;
    fifo_empty(2) <= fifo_empty2;
    fifo_empty(3) <= fifo_empty3;
    fifo_empty(4) <= fifo_empty4;

    -- In Arbiter.vhd, replace the ENTIRE 'comb' process with this:

comb: process(rr_ptr, fifo_empty, routing_dir, credit_in)
    variable granted : boolean := false;
    variable current_idx : integer;
    variable dir : std_logic_vector(2 downto 0);
begin
    -- Reset outputs
    fifo_rd_int <= (others => '0');
    write_req_int <= (others => '0');
    sel0_int <= (others => '0');
    sel1_int <= (others => '0');
    sel2_int <= (others => '0');
    sel3_int <= (others => '0');
    sel4_int <= (others => '0');

    granted := false;
    
    -- Check starting from rr_ptr, wrapping around
    for offset in 0 to 4 loop
        current_idx := (rr_ptr + offset) mod 5;
        
        if not granted and fifo_empty(current_idx) = '0' then
            dir := routing_dir(current_idx);
            
            -- Debug: report what we're trying to route
            -- report "Checking FIFO " & integer'image(current_idx) & 
            --        " dir=" & to_hstring(dir) & 
            --        " credit=" & std_logic'image(credit_in(0)) & std_logic'image(credit_in(1)) & 
            --        std_logic'image(credit_in(2)) & std_logic'image(credit_in(3));
            
            case dir is
                when DIR_W =>  -- WEST
                    if credit_in(0) = '1' then  -- West credit available
                        fifo_rd_int(current_idx) <= '1';
                        write_req_int(3) <= '1';  -- West output is port 3
                        sel3_int <= std_logic_vector(to_unsigned(current_idx, 3));
                        granted := true;
                        exit;  -- Exit loop after granting one
                    end if;
                    
                when DIR_N =>  -- NORTH
                    if credit_in(1) = '1' then  -- North credit available
                        fifo_rd_int(current_idx) <= '1';
                        write_req_int(0) <= '1';  -- North output is port 0
                        sel0_int <= std_logic_vector(to_unsigned(current_idx, 3));
                        granted := true;
                        exit;
                    end if;
                    
                when DIR_E =>  -- EAST
                    if credit_in(2) = '1' then  -- East credit available
                        fifo_rd_int(current_idx) <= '1';
                        write_req_int(1) <= '1';  -- East output is port 1
                        sel1_int <= std_logic_vector(to_unsigned(current_idx, 3));
                        granted := true;
                        exit;
                    end if;
                    
                when DIR_S =>  -- SOUTH
                    if credit_in(3) = '1' then  -- South credit available
                        fifo_rd_int(current_idx) <= '1';
                        write_req_int(2) <= '1';  -- South output is port 2
                        sel2_int <= std_logic_vector(to_unsigned(current_idx, 3));
                        granted := true;
                        exit;
                    end if;
                    
                when DIR_L =>  -- LOCAL
                    fifo_rd_int(current_idx) <= '1';
                    sel4_int <= std_logic_vector(to_unsigned(current_idx, 3));
                    -- LOCAL doesn't need credit or write_req
                    granted := true;
                    exit;
                    
                when others => 
                    null;
            end case;
        end if;
    end loop;
    
    -- DEBUG: If nothing granted but we see SOUTH output, there's a bug
    -- if not granted and write_req_int /= "0000" then
    --     report "ARBITER BUG: write_req should be 0000 but is " & 
    --            to_hstring(write_req_int);
    -- end if;
end process comb;

    seq: process(clk, reset)
    begin
        if reset = '1' then
            rr_ptr <= 0;
        elsif rising_edge(clk) then
            if fifo_rd_int /= "00000" then
                rr_ptr <= (rr_ptr + 1) mod 5;
            end if;
        end if;
    end process seq;

    fifo_rd <= fifo_rd_int;
    write_request <= write_req_int;
    sel0 <= sel0_int;
    sel1 <= sel1_int;
    sel2 <= sel2_int;
    sel3 <= sel3_int;
    sel4 <= sel4_int;

end architecture rtl;
