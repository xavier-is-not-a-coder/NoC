library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Routing_unit is
    generic(
        X_local : natural := 1;
        Y_local : natural := 1
    );
    port(
        des_addr : in std_logic_vector(3 downto 0);
        outX : out std_logic_vector(2 downto 0)
    );
end entity Routing_unit;

architecture fixed of Routing_unit is
begin
    process(des_addr)
        variable dest_X, dest_Y : integer;
    begin
        dest_X := to_integer(unsigned(des_addr(3 downto 2)));
        dest_Y := to_integer(unsigned(des_addr(1 downto 0)));
        
        if dest_X < X_local then
            outX <= "000";  -- WEST
        elsif dest_X > X_local then
            outX <= "001";  -- EAST
        elsif dest_Y < Y_local then
            outX <= "010";  -- NORTH
        elsif dest_Y > Y_local then
            outX <= "011";  -- SOUTH
        else
            outX <= "100";  -- LOCAL
        end if;
    end process;
end architecture fixed;
