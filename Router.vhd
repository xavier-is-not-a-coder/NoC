library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Router is
    generic (
        DATA_WIDTH : natural := 12;
        X_local    : natural := 1;
        Y_local    : natural := 1
    );
    port(
        clk   : in  std_logic;
        reset : in  std_logic;

        -- INPUT CHANNELS
        west_in_data  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        west_in_wr    : in  std_logic;
        west_out_full : out std_logic;

        north_in_data : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        north_in_wr   : in  std_logic;
        north_out_full : out std_logic;

        east_in_data  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        east_in_wr    : in  std_logic;
        east_out_full : out std_logic;

        south_in_data : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        south_in_wr   : in  std_logic;
        south_out_full : out std_logic;

        local_in_data : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        local_in_wr   : in  std_logic;
        local_out_full : out std_logic;

        -- CREDITS FROM DOWNSTREAM
        west_in_credit  : in std_logic;
        north_in_credit : in std_logic;
        east_in_credit  : in std_logic;
        south_in_credit : in std_logic;

        -- OUTPUT CHANNELS
        west_out_data  : out std_logic_vector(DATA_WIDTH-1 downto 0);
        west_out_wr    : out std_logic;

        north_out_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
        north_out_wr   : out std_logic;

        east_out_data  : out std_logic_vector(DATA_WIDTH-1 downto 0);
        east_out_wr    : out std_logic;

        south_out_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
        south_out_wr   : out std_logic;

        local_out_data : out std_logic_vector(DATA_WIDTH-1 downto 0);

        -- DEBUG PORTS (for testbench visibility)
        fifo_data_w, fifo_data_n, fifo_data_e, fifo_data_s, fifo_data_l : out std_logic_vector(DATA_WIDTH-1 downto 0);
        fifo_empty_w, fifo_empty_n, fifo_empty_e, fifo_empty_s, fifo_empty_l : out std_logic;
        routing_dir_w, routing_dir_n, routing_dir_e, routing_dir_s, routing_dir_l : out std_logic_vector(2 downto 0);
        arb_fifo_rd : out std_logic_vector(4 downto 0)
    );
end entity Router;

architecture struct of Router is

    -- Internal signals
    signal fifo_data_w_int, fifo_data_n_int, fifo_data_e_int, fifo_data_s_int, fifo_data_l_int : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal fifo_empty_w_int, fifo_empty_n_int, fifo_empty_e_int, fifo_empty_s_int, fifo_empty_l_int : std_logic;

    signal routing_dir_w_int, routing_dir_n_int, routing_dir_e_int, routing_dir_s_int, routing_dir_l_int : std_logic_vector(2 downto 0);

    signal credit_vec : std_logic_vector(3 downto 0);

    signal fifo_rd_int : std_logic_vector(4 downto 0);
    signal write_req_int : std_logic_vector(3 downto 0);

    signal sel0_int, sel1_int, sel2_int, sel3_int, sel4_int : std_logic_vector(2 downto 0);

    signal xbar_out0, xbar_out1, xbar_out2, xbar_out3, xbar_out4 : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

    -- Pack credits
    credit_vec(0) <= west_in_credit;
    credit_vec(1) <= north_in_credit;
    credit_vec(2) <= east_in_credit;
    credit_vec(3) <= south_in_credit;

    -- FIFOs
    fifo_w: entity work.FIFO_Buffer
        generic map (DATA_WIDTH => DATA_WIDTH, ADDR_WIDTH => 2)
        port map (
            clk => clk, reset => reset,
            fifo_data_in => west_in_data, wr => west_in_wr, rd => fifo_rd_int(0),
            fifo_data_out => fifo_data_w_int, full => west_out_full, empty => fifo_empty_w_int
        );

    fifo_n: entity work.FIFO_Buffer
        generic map (DATA_WIDTH => DATA_WIDTH, ADDR_WIDTH => 2)
        port map (
            clk => clk, reset => reset,
            fifo_data_in => north_in_data, wr => north_in_wr, rd => fifo_rd_int(1),
            fifo_data_out => fifo_data_n_int, full => north_out_full, empty => fifo_empty_n_int
        );

    fifo_e: entity work.FIFO_Buffer
        generic map (DATA_WIDTH => DATA_WIDTH, ADDR_WIDTH => 2)
        port map (
            clk => clk, reset => reset,
            fifo_data_in => east_in_data, wr => east_in_wr, rd => fifo_rd_int(2),
            fifo_data_out => fifo_data_e_int, full => east_out_full, empty => fifo_empty_e_int
        );

    fifo_s: entity work.FIFO_Buffer
        generic map (DATA_WIDTH => DATA_WIDTH, ADDR_WIDTH => 2)
        port map (
            clk => clk, reset => reset,
            fifo_data_in => south_in_data, wr => south_in_wr, rd => fifo_rd_int(3),
            fifo_data_out => fifo_data_s_int, full => south_out_full, empty => fifo_empty_s_int
        );

    fifo_l: entity work.FIFO_Buffer
        generic map (DATA_WIDTH => DATA_WIDTH, ADDR_WIDTH => 2)
        port map (
            clk => clk, reset => reset,
            fifo_data_in => local_in_data, wr => local_in_wr, rd => fifo_rd_int(4),
            fifo_data_out => fifo_data_l_int, full => local_out_full, empty => fifo_empty_l_int
        );

    -- Routing units
-- Change from:
-- port map (des_addr => fifo_data_w_int(3 downto 0), outX => routing_dir_w_int);

-- To:
ru_w: entity work.Routing_unit generic map (X_local => X_local, Y_local => Y_local)
    port map (des_addr => fifo_data_w_int(7 downto 4), outX => routing_dir_w_int);

ru_n: entity work.Routing_unit generic map (X_local => X_local, Y_local => Y_local)
    port map (des_addr => fifo_data_n_int(7 downto 4), outX => routing_dir_n_int);

ru_e: entity work.Routing_unit generic map (X_local => X_local, Y_local => Y_local)
    port map (des_addr => fifo_data_e_int(7 downto 4), outX => routing_dir_e_int);

ru_s: entity work.Routing_unit generic map (X_local => X_local, Y_local => Y_local)
    port map (des_addr => fifo_data_s_int(7 downto 4), outX => routing_dir_s_int);

ru_l: entity work.Routing_unit generic map (X_local => X_local, Y_local => Y_local)
    port map (des_addr => fifo_data_l_int(7 downto 4), outX => routing_dir_l_int);

    -- Arbiter (fixed-priority)
    arb: entity work.Arbiter
        port map (
            clk => clk, reset => reset,
            routing_dir0 => routing_dir_w_int,
            routing_dir1 => routing_dir_n_int,
            routing_dir2 => routing_dir_e_int,
            routing_dir3 => routing_dir_s_int,
            routing_dir4 => routing_dir_l_int,
            fifo_empty0 => fifo_empty_w_int,
            fifo_empty1 => fifo_empty_n_int,
            fifo_empty2 => fifo_empty_e_int,
            fifo_empty3 => fifo_empty_s_int,
            fifo_empty4 => fifo_empty_l_int,
            credit_in => credit_vec,
            fifo_rd => fifo_rd_int,
            write_request => write_req_int,
            sel0 => sel0_int, sel1 => sel1_int, sel2 => sel2_int, sel3 => sel3_int, sel4 => sel4_int
        );

    -- Full Crossbar
    xbar: entity work.Crossbar_switch
        generic map (DATA_WIDTH => DATA_WIDTH)
        port map (
            in0 => fifo_data_w_int, in1 => fifo_data_n_int, in2 => fifo_data_e_int,
            in3 => fifo_data_s_int, in4 => fifo_data_l_int,
            sel0 => sel0_int, sel1 => sel1_int, sel2 => sel2_int, sel3 => sel3_int, sel4 => sel4_int,
            out0 => xbar_out0, out1 => xbar_out1, out2 => xbar_out2, out3 => xbar_out3, out4 => xbar_out4
        );

    -- Output mapping
    north_out_data <= xbar_out0;
    north_out_wr   <= write_req_int(0);

    east_out_data  <= xbar_out1;
    east_out_wr    <= write_req_int(1);

    south_out_data <= xbar_out2;
    south_out_wr   <= write_req_int(2);

    west_out_data  <= xbar_out3;
    west_out_wr    <= write_req_int(3);

    local_out_data <= xbar_out4;

    -- DEBUG OUTPUTS
    fifo_data_w <= fifo_data_w_int;
    fifo_data_n <= fifo_data_n_int;
    fifo_data_e <= fifo_data_e_int;
    fifo_data_s <= fifo_data_s_int;
    fifo_data_l <= fifo_data_l_int;

    fifo_empty_w <= fifo_empty_w_int;
    fifo_empty_n <= fifo_empty_n_int;
    fifo_empty_e <= fifo_empty_e_int;
    fifo_empty_s <= fifo_empty_s_int;
    fifo_empty_l <= fifo_empty_l_int;

    routing_dir_w <= routing_dir_w_int;
    routing_dir_n <= routing_dir_n_int;
    routing_dir_e <= routing_dir_e_int;
    routing_dir_s <= routing_dir_s_int;
    routing_dir_l <= routing_dir_l_int;

    arb_fifo_rd <= fifo_rd_int;

end architecture struct;
