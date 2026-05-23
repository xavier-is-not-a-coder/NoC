library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO_Buffer is
    generic (
        ADDR_WIDTH : natural := 2;
        DATA_WIDTH : natural := 12
    );
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        wr     : in  std_logic;
        rd     : in  std_logic;
        fifo_data_in : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        fifo_data_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
        full   : out std_logic;
        empty  : out std_logic
    );
end FIFO_Buffer;

architecture behavioral of FIFO_Buffer is
    constant DEPTH : integer := 2**ADDR_WIDTH;
    
    type memory_type is array (0 to DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal memory : memory_type;
    
    signal wr_ptr, rd_ptr : unsigned(ADDR_WIDTH-1 downto 0) := (others => '0');
    signal count : integer range 0 to DEPTH := 0;
    
    signal full_s, empty_s : std_logic := '0';
begin
    fifo_data_out <= memory(to_integer(rd_ptr)) when empty_s = '0' else (others => '0');
    full <= full_s;
    empty <= empty_s;

    process (clk, reset)
        variable next_count : integer range 0 to DEPTH;
    begin
        if reset = '1' then
            wr_ptr <= (others => '0');
            rd_ptr <= (others => '0');
            count <= 0;
            full_s <= '0';
            empty_s <= '1';
            for i in 0 to DEPTH-1 loop
                memory(i) <= (others => '0');
            end loop;
            
        elsif rising_edge(clk) then
            next_count := count;
            
            if wr = '1' and full_s = '0' then
                memory(to_integer(wr_ptr)) <= fifo_data_in;
                if wr_ptr = DEPTH-1 then
                    wr_ptr <= (others => '0');
                else
                    wr_ptr <= wr_ptr + 1;
                end if;
                if not (rd = '1' and empty_s = '0') then
                    next_count := count + 1;
                end if;
            end if;
            
            if rd = '1' and empty_s = '0' then
                if rd_ptr = DEPTH-1 then
                    rd_ptr <= (others => '0');
                else
                    rd_ptr <= rd_ptr + 1;
                end if;
                if not (wr = '1' and full_s = '0') then
                    next_count := count - 1;
                end if;
            end if;
            
            count <= next_count;
            
            if next_count = DEPTH then
                full_s <= '1';
            else
                full_s <= '0';
            end if;
            
            if next_count = 0 then
                empty_s <= '1';
            else
                empty_s <= '0';
            end if;
        end if;
    end process;
end architecture behavioral;
