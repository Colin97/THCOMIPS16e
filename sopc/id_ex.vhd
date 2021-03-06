library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity id_ex_reg is
    port
    (
        CLK: in std_logic;
        RST: in std_logic;

        STALL: in stall_t;
        FLUSH: in std_logic;
        
        ID_COMMON: in common_signal_t;
        ID_EX: in ex_signal_t;
        ID_MEM: in mem_signal_t;
        ID_WB: in wb_signal_t;
        ID_IS_LOAD: in std_logic;
        ID_IS_BRANCH: in std_logic;
        
        EX_COMMON: out common_signal_t;
        EX_EX: out ex_signal_t;
        EX_MEM: out mem_signal_t;
        EX_WB: out wb_signal_t;
        EX_IS_LOAD: out std_logic;
        EX_IS_BRANCH: out std_logic
    );
end;

architecture behavioral of id_ex_reg is
begin
    process(CLK, RST)
    begin
        if RST = '1' then
            EX_COMMON.pc <= (others => '0');
            EX_COMMON.op <= (others => '0');
            EX_COMMON.funct <= (others => '0');
            EX_COMMON.is_in_delay_slot <= '0';
            EX_EX.cp0_read_en <= '0';
            EX_EX.cp0_read_addr <= (others => 'X');
            EX_EX.alu_op <= alu_nop;
            EX_EX.operand_0 <= (others => '0');
            EX_EX.operand_1 <= (others => '0');
            EX_MEM.alu_result <= (others => '0');
            EX_MEM.mem_en <= '0';
            EX_MEM.mem_write_en <= '0';
            EX_MEM.write_mem_data <= (others => '0');
            EX_MEM.is_uart_data <= '0';
            EX_MEM.is_uart_control <= '0';
            EX_MEM.except_type <= except_none;
            EX_WB.write_en <= '0';
            EX_WB.write_addr <= (others => '0');
            EX_WB.write_data <= (others => '0');
            EX_WB.hi_write_en <= '0';
            EX_WB.hi_write_data <= (others => '0');
            EX_WB.lo_write_en <= '0';
            EX_WB.lo_write_data <= (others => '0');
            EX_WB.t_write_en <= '0';
            EX_WB.t_write_data <= '0';
            EX_WB.sp_write_en <= '0';
            EX_WB.sp_write_data <= (others => '0');
            EX_WB.ds_write_en <= '0';
            EX_WB.ds_write_data <= (others => '0');
            EX_WB.cp0_write_en <= '0';
            EX_WB.cp0_write_addr <= (others => '0');
            EX_WB.cp0_write_data <= (others => '0');
            EX_IS_LOAD <= '0';
            EX_IS_BRANCH <= '0';
        elsif rising_edge(CLK) then
            if FLUSH = '1' or STALL(stage_ex downto stage_id) = "01" then
                EX_COMMON.pc <= (others => '0');
                EX_COMMON.op <= (others => '0');
                EX_COMMON.funct <= (others => '0');
                EX_COMMON.is_in_delay_slot <= '0';
                EX_EX.cp0_read_en <= 'X';
                EX_EX.cp0_read_addr <= (others => 'X');
                EX_EX.alu_op <= alu_nop;
                EX_EX.operand_0 <= (others => 'X');
                EX_EX.operand_1 <= (others => 'X');
                EX_MEM.alu_result <= (others => 'X');
                EX_MEM.mem_en <= '0';
                EX_MEM.mem_write_en <= 'X';
                EX_MEM.write_mem_data <= (others => 'X');
                EX_MEM.is_uart_data <= 'X';
                EX_MEM.is_uart_control <= 'X';
                EX_MEM.except_type <= except_none;
                EX_WB.write_en <= '0';
                EX_WB.write_addr <= (others => 'X');
                EX_WB.write_data <= (others => 'X');
                EX_WB.hi_write_en <= '0';
                EX_WB.hi_write_data <= (others => 'X');
                EX_WB.lo_write_en <= '0';
                EX_WB.lo_write_data <= (others => 'X');
                EX_WB.t_write_en <= '0';
                EX_WB.t_write_data <= 'X';
                EX_WB.sp_write_en <= '0';
                EX_WB.sp_write_data <= (others => 'X');
                EX_WB.ds_write_en <= '0';
                EX_WB.ds_write_data <= (others => 'X');
                EX_WB.cp0_write_en <= '0';
                EX_WB.cp0_write_addr <= (others => 'X');
                EX_WB.cp0_write_data <= (others => 'X');
                EX_IS_LOAD <= '0';
                EX_IS_BRANCH <= '0';
            elsif STALL(stage_ex downto stage_id) = "11" then
                -- do nothing
            else
                EX_COMMON <= ID_COMMON;
                EX_EX <= ID_EX;
                EX_MEM <= ID_MEM;
                EX_WB <= ID_WB;
                EX_IS_LOAD <= ID_IS_LOAD;
                EX_IS_BRANCH <= ID_IS_BRANCH;
            end if;
        end if;
    end process;
end;