library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.types.all;

entity execute is
    port
    (
        RST: in std_logic;
        
        STALL_REQ: out std_logic;

        COMMON: in common_signal_t;
        EX: in ex_signal_t;
        MEM: in mem_signal_t;
        WB: in wb_signal_t;

        COMMON_O: out common_signal_t;
        MEM_O: out mem_signal_t;
        WB_O: out wb_signal_t;

        HI: in word_t;
        LO: in word_t;

        MEM_LOADED_DATA: in word_t;

        -- CP0 interface
        CP0_READ_ADDR: out cp0_addr_t;
        CP0_READ_DATA: in word_t;
        CP0_BITS: in cp0_bits_t;
        IRQ: in std_logic_vector(5 downto 0);

        -- divider interface
        -- data signals
        DIV_DIVIDEND: out word_t;
        DIV_DIV: out word_t;
        
        DIV_QUOTIENT: in word_t;
        DIV_REMAINDER: in word_t;
        
        -- control signals
        DIV_SIGN: out std_logic;
        DIV_EN: out std_logic;
        DIV_DONE: in std_logic
    );
end;

architecture behavioral of execute is
    component alu is
        port
        (
            RST: in std_logic;

            OP: in alu_op_t;
            OPERAND_0: in word_t;
            OPERAND_1: in word_t;

            RESULT: out word_t;

            -- flags
            OVERFLOW: out std_logic;
            ZERO: out std_logic;
            SIGN: out std_logic;
            CARRY: out std_logic
        );
    end component;

    signal alu_result_buff: word_t;
    signal except_type: except_type_t;
begin
    alu_inst: alu
    port map
    (
        RST => RST,
        OP => EX.alu_op,
        OPERAND_0 => EX.operand_0,
        OPERAND_1 => EX.operand_1,

        result => alu_result_buff
    );
    
    CP0_READ_ADDR <= EX.cp0_read_addr;
    
    process(MEM)
    begin
        if MEM.except_type(except_type_bit_eret) = '1' or
           (CP0_BITS.interrupt_enable = '1' and CP0_BITS.in_except_handler = '0') then
            except_type <= MEM.except_type(7 downto 6) & (IRQ and not CP0_BITS.interrupt_mask);
        else
            except_type <= except_none;
        end if;
    end process;

    process(RST, alu_result_buff, COMMON, EX, MEM, WB,
            HI, LO, DIV_DONE, DIV_QUOTIENT, DIV_REMAINDER)
    begin
        if RST = '1' then
            STALL_REQ <= '0';
            COMMON_O.pc <= (others => '0');
            COMMON_O.op <= (others => '0');
            COMMON_O.funct <= (others => '0');
            COMMON_O.is_in_delay_slot <= '0';
            MEM_O.alu_result <= (others => '0');
            MEM_O.mem_en <= '0';
            MEM_O.mem_write_en <= '0';
            MEM_O.write_mem_data <= (others => '0');
            MEM_O.sw_after_load <= '0';
            MEM_O.is_uart_data <= '0';
            MEM_O.is_uart_control <= '0';
            MEM_O.except_type <= except_none;
            WB_O.write_en <= '0';
            WB_O.write_addr <= (others => '0');
            WB_O.write_data <= (others => '0');
            WB_O.hi_write_en <= '0';
            WB_O.hi_write_data <= (others => '0');
            WB_O.lo_write_en <= '0';
            WB_O.lo_write_data <= (others => '0');
            WB_O.t_write_en <= '0';
            WB_O.t_write_data <= '0';
            WB_O.sp_write_en <= '0';
            WB_O.sp_write_data <= (others => '0');
            WB_O.ds_write_en <= '0';
            WB_O.ds_write_data <= (others => '0');
            WB_O.cp0_write_en <= '0';
            WB_O.cp0_write_addr <= (others => '0');
            WB_O.cp0_write_data <= (others => '0');
            DIV_DIVIDEND <= (others => '0');
            DIV_DIV <= (others => '0');
            DIV_SIGN <= '0';
            DIV_EN <= '0';
        else
            STALL_REQ <= '0';
            COMMON_O <= COMMON;
            MEM_O <= MEM;
            MEM_O.alu_result <= alu_result_buff;
            WB_O <= WB;
            WB_O.write_data <= alu_result_buff;
            WB_O.hi_write_en <= '0';
            WB_O.hi_write_data <= (others => 'X');
            WB_O.lo_write_en <= '0';
            WB_O.lo_write_data <= (others => 'X');
            WB_O.t_write_data <= alu_result_buff(0);
            WB_O.sp_write_data <= alu_result_buff;
            WB_O.ds_write_data <= alu_result_buff;
            WB_O.cp0_write_data <= alu_result_buff;
            DIV_DIVIDEND <= (others => 'X');
            DIV_DIV <= (others => 'X');
            DIV_SIGN <= 'X';
            DIV_EN <= '0';
            
            -- FIXME: check zero reg here
            if MEM.sw_after_load = '1' then
                MEM_O.write_mem_data <= MEM_LOADED_DATA;
            end if;
            
            if EX.cp0_read_en = '1' then
                WB_O.write_data <= CP0_READ_DATA;
            end if;
            
            -- to improve timing
            if alu_result_buff = x"BF00" then
                MEM_O.is_uart_data <= '1';
            else
                MEM_O.is_uart_data <= '0';
            end if;
           
            if alu_result_buff = x"BF01" then
                MEM_O.is_uart_control <= '1';
            else
                MEM_O.is_uart_control <= '0';
            end if;
            
            MEM_O.except_type <= except_type;
            -- if an exception occurred, this instruction is cancelled.
            if except_type /= except_none then
                MEM_O.mem_en <= '0';
            end if;
        end if;
    end process;
end;