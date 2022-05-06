-------------------------------------------------------------------------------
-- CRC module for data(7:0)
--   lfsr(31:0)=1+x^1+x^2+x^4+x^5+x^7+x^8+x^10+x^11+x^12+x^16+x^22+x^23+x^26+x^32;
-------------------------------------------------------------------------------

-- http://outputlogic.com/?page_id=321

-- The generator used may not be preprocessing and post-processing data. 
-- If this generator takes a string of zeros and produces a zero crc, then 
-- this is a problem. A string of zeros must not yield zero. 
-- (What it produces depends on the number of zeros.)

-- The processing for Ethernet crc is to invert the data for crc, 
-- then apply the crc algorithm, and then invert crc again. 

-- https://stackoverflow.com/questions/39108820/crc16-with-vhdl-multiple-input-bytes


library ieee; 
use ieee.std_logic_1164.all;

use ieee.numeric_std.all;

entity crc_seq is 
port ( clk: in std_logic;
       data_in: in std_logic_vector(31 downto 0); 
       crc_en:   in  std_logic;   -- ADDED
       rst:      in  std_logic;   -- ADDED
       crc_out: out std_logic_vector(31 downto 0)
      );
end crc_seq;

architecture crc_arch of crc_seq is     

function reverse_vector(v: in std_logic_vector)
return std_logic_vector is
    variable result: std_logic_vector(v'RANGE);
    alias vr: std_logic_vector(v'REVERSE_RANGE) is v;
begin
    for i in vr'RANGE loop
        result(i) := vr(i);
    end loop;

    return result;
end;    

 function crc_bit(crc: in std_logic_vector(31 downto 0); d: std_logic) 
 return std_logic_vector is
  variable msb: std_logic;
  variable lfsr_ct: std_logic_vector(31 downto 0);
 begin
  msb := crc(0);
  --lfsr_ct :=  std_logic_vector(shift_left(unsigned(crc), 1));
  lfsr_ct :=  std_logic_vector(shift_right(unsigned(crc), 1));
  if (msb xor d) = '1' then
  lfsr_ct(0) := lfsr_ct(0) xor '1'; --d xor msb xor msb;
  lfsr_ct(1) := lfsr_ct(1) xor '1';--d xor msb xor crc(0);
  lfsr_ct(2) := lfsr_ct(2) xor '1';--d xor msb xor crc(1);
  lfsr_ct(4) := lfsr_ct(4) xor '1';--d xor msb xor crc(3);
  lfsr_ct(5) := lfsr_ct(5) xor '1';--d xor msb xor crc(4);
  lfsr_ct(7) := lfsr_ct(7) xor '1';--d xor msb xor crc(6);
  lfsr_ct(8) := lfsr_ct(8) xor '1';--d xor msb xor crc(7);
  lfsr_ct(10) := lfsr_ct(10) xor '1';--d xor msb xor crc(9);
  lfsr_ct(11) := lfsr_ct(11) xor '1';--d xor msb xor crc(10);
  lfsr_ct(12) := lfsr_ct(12) xor '1';--d xor msb xor crc(11);
  lfsr_ct(16) := lfsr_ct(16) xor '1';--d xor msb xor crc(15);
  lfsr_ct(22) := lfsr_ct(22) xor '1';--d xor msb xor crc(21);
  lfsr_ct(23) := lfsr_ct(23) xor '1';--d xor msb xor crc(22);
  lfsr_ct(26) := lfsr_ct(26) xor '1';--d xor msb xor crc(26);
  end if;
  report "Value=" & to_hstring(lfsr_ct) & "h";
  return lfsr_ct;
 end;

 function crc_byte(crc: in std_logic_vector(31 downto 0); data: std_logic_vector(7 downto 0))
 return std_logic_vector is
  variable lfsr_c: std_logic_vector(31 downto 0);
 begin
  lfsr_c := crc;
  for i in 1 to 8 loop
	  lfsr_c := crc_bit(lfsr_c, data(i-1));
  end loop;
  return lfsr_c;
 end;

 function crc_word(crc: in std_logic_vector(31 downto 0); data: std_logic_vector(31 downto 0))
 return std_logic_vector is
  variable lfsr_c: std_logic_vector(31 downto 0);
 begin
  lfsr_c := crc;
  for i in 1 to 32 loop
	  lfsr_c := crc_bit(lfsr_c, data(i-1));
  end loop;
  return lfsr_c;
 end;

 function crc32( data_in: in std_logic_vector(31 downto 0);             
                lfsr_q: in std_logic_vector(31 downto 0))
return std_logic_vector is  
    variable lfsr_c: std_logic_vector(31 downto 0);
begin

    lfsr_c(0) := lfsr_q(0) xor lfsr_q(6) xor lfsr_q(9) xor lfsr_q(10) xor lfsr_q(12) xor lfsr_q(16) xor lfsr_q(24) xor lfsr_q(25) xor lfsr_q(26) xor lfsr_q(28) xor lfsr_q(29) xor lfsr_q(30) xor lfsr_q(31) xor data_in(0) xor data_in(6) xor data_in(9) xor data_in(10) xor data_in(12) xor data_in(16) xor data_in(24) xor data_in(25) xor data_in(26) xor data_in(28) xor data_in(29) xor data_in(30) xor data_in(31);
    lfsr_c(1) := lfsr_q(0) xor lfsr_q(1) xor lfsr_q(6) xor lfsr_q(7) xor lfsr_q(9) xor lfsr_q(11) xor lfsr_q(12) xor lfsr_q(13) xor lfsr_q(16) xor lfsr_q(17) xor lfsr_q(24) xor lfsr_q(27) xor lfsr_q(28) xor data_in(0) xor data_in(1) xor data_in(6) xor data_in(7) xor data_in(9) xor data_in(11) xor data_in(12) xor data_in(13) xor data_in(16) xor data_in(17) xor data_in(24) xor data_in(27) xor data_in(28);
    lfsr_c(2) := lfsr_q(0) xor lfsr_q(1) xor lfsr_q(2) xor lfsr_q(6) xor lfsr_q(7) xor lfsr_q(8) xor lfsr_q(9) xor lfsr_q(13) xor lfsr_q(14) xor lfsr_q(16) xor lfsr_q(17) xor lfsr_q(18) xor lfsr_q(24) xor lfsr_q(26) xor lfsr_q(30) xor lfsr_q(31) xor data_in(0) xor data_in(1) xor data_in(2) xor data_in(6) xor data_in(7) xor data_in(8) xor data_in(9) xor data_in(13) xor data_in(14) xor data_in(16) xor data_in(17) xor data_in(18) xor data_in(24) xor data_in(26) xor data_in(30) xor data_in(31);
    lfsr_c(3) := lfsr_q(1) xor lfsr_q(2) xor lfsr_q(3) xor lfsr_q(7) xor lfsr_q(8) xor lfsr_q(9) xor lfsr_q(10) xor lfsr_q(14) xor lfsr_q(15) xor lfsr_q(17) xor lfsr_q(18) xor lfsr_q(19) xor lfsr_q(25) xor lfsr_q(27) xor lfsr_q(31) xor data_in(1) xor data_in(2) xor data_in(3) xor data_in(7) xor data_in(8) xor data_in(9) xor data_in(10) xor data_in(14) xor data_in(15) xor data_in(17) xor data_in(18) xor data_in(19) xor data_in(25) xor data_in(27) xor data_in(31);
    lfsr_c(4) := lfsr_q(0) xor lfsr_q(2) xor lfsr_q(3) xor lfsr_q(4) xor lfsr_q(6) xor lfsr_q(8) xor lfsr_q(11) xor lfsr_q(12) xor lfsr_q(15) xor lfsr_q(18) xor lfsr_q(19) xor lfsr_q(20) xor lfsr_q(24) xor lfsr_q(25) xor lfsr_q(29) xor lfsr_q(30) xor lfsr_q(31) xor data_in(0) xor data_in(2) xor data_in(3) xor data_in(4) xor data_in(6) xor data_in(8) xor data_in(11) xor data_in(12) xor data_in(15) xor data_in(18) xor data_in(19) xor data_in(20) xor data_in(24) xor data_in(25) xor data_in(29) xor data_in(30) xor data_in(31);
    lfsr_c(5) := lfsr_q(0) xor lfsr_q(1) xor lfsr_q(3) xor lfsr_q(4) xor lfsr_q(5) xor lfsr_q(6) xor lfsr_q(7) xor lfsr_q(10) xor lfsr_q(13) xor lfsr_q(19) xor lfsr_q(20) xor lfsr_q(21) xor lfsr_q(24) xor lfsr_q(28) xor lfsr_q(29) xor data_in(0) xor data_in(1) xor data_in(3) xor data_in(4) xor data_in(5) xor data_in(6) xor data_in(7) xor data_in(10) xor data_in(13) xor data_in(19) xor data_in(20) xor data_in(21) xor data_in(24) xor data_in(28) xor data_in(29);
    lfsr_c(6) := lfsr_q(1) xor lfsr_q(2) xor lfsr_q(4) xor lfsr_q(5) xor lfsr_q(6) xor lfsr_q(7) xor lfsr_q(8) xor lfsr_q(11) xor lfsr_q(14) xor lfsr_q(20) xor lfsr_q(21) xor lfsr_q(22) xor lfsr_q(25) xor lfsr_q(29) xor lfsr_q(30) xor data_in(1) xor data_in(2) xor data_in(4) xor data_in(5) xor data_in(6) xor data_in(7) xor data_in(8) xor data_in(11) xor data_in(14) xor data_in(20) xor data_in(21) xor data_in(22) xor data_in(25) xor data_in(29) xor data_in(30);
    lfsr_c(7) := lfsr_q(0) xor lfsr_q(2) xor lfsr_q(3) xor lfsr_q(5) xor lfsr_q(7) xor lfsr_q(8) xor lfsr_q(10) xor lfsr_q(15) xor lfsr_q(16) xor lfsr_q(21) xor lfsr_q(22) xor lfsr_q(23) xor lfsr_q(24) xor lfsr_q(25) xor lfsr_q(28) xor lfsr_q(29) xor data_in(0) xor data_in(2) xor data_in(3) xor data_in(5) xor data_in(7) xor data_in(8) xor data_in(10) xor data_in(15) xor data_in(16) xor data_in(21) xor data_in(22) xor data_in(23) xor data_in(24) xor data_in(25) xor data_in(28) xor data_in(29);
    lfsr_c(8) := lfsr_q(0) xor lfsr_q(1) xor lfsr_q(3) xor lfsr_q(4) xor lfsr_q(8) xor lfsr_q(10) xor lfsr_q(11) xor lfsr_q(12) xor lfsr_q(17) xor lfsr_q(22) xor lfsr_q(23) xor lfsr_q(28) xor lfsr_q(31) xor data_in(0) xor data_in(1) xor data_in(3) xor data_in(4) xor data_in(8) xor data_in(10) xor data_in(11) xor data_in(12) xor data_in(17) xor data_in(22) xor data_in(23) xor data_in(28) xor data_in(31);
    lfsr_c(9) := lfsr_q(1) xor lfsr_q(2) xor lfsr_q(4) xor lfsr_q(5) xor lfsr_q(9) xor lfsr_q(11) xor lfsr_q(12) xor lfsr_q(13) xor lfsr_q(18) xor lfsr_q(23) xor lfsr_q(24) xor lfsr_q(29) xor data_in(1) xor data_in(2) xor data_in(4) xor data_in(5) xor data_in(9) xor data_in(11) xor data_in(12) xor data_in(13) xor data_in(18) xor data_in(23) xor data_in(24) xor data_in(29);
    lfsr_c(10) := lfsr_q(0) xor lfsr_q(2) xor lfsr_q(3) xor lfsr_q(5) xor lfsr_q(9) xor lfsr_q(13) xor lfsr_q(14) xor lfsr_q(16) xor lfsr_q(19) xor lfsr_q(26) xor lfsr_q(28) xor lfsr_q(29) xor lfsr_q(31) xor data_in(0) xor data_in(2) xor data_in(3) xor data_in(5) xor data_in(9) xor data_in(13) xor data_in(14) xor data_in(16) xor data_in(19) xor data_in(26) xor data_in(28) xor data_in(29) xor data_in(31);
    lfsr_c(11) := lfsr_q(0) xor lfsr_q(1) xor lfsr_q(3) xor lfsr_q(4) xor lfsr_q(9) xor lfsr_q(12) xor lfsr_q(14) xor lfsr_q(15) xor lfsr_q(16) xor lfsr_q(17) xor lfsr_q(20) xor lfsr_q(24) xor lfsr_q(25) xor lfsr_q(26) xor lfsr_q(27) xor lfsr_q(28) xor lfsr_q(31) xor data_in(0) xor data_in(1) xor data_in(3) xor data_in(4) xor data_in(9) xor data_in(12) xor data_in(14) xor data_in(15) xor data_in(16) xor data_in(17) xor data_in(20) xor data_in(24) xor data_in(25) xor data_in(26) xor data_in(27) xor data_in(28) xor data_in(31);
    lfsr_c(12) := lfsr_q(0) xor lfsr_q(1) xor lfsr_q(2) xor lfsr_q(4) xor lfsr_q(5) xor lfsr_q(6) xor lfsr_q(9) xor lfsr_q(12) xor lfsr_q(13) xor lfsr_q(15) xor lfsr_q(17) xor lfsr_q(18) xor lfsr_q(21) xor lfsr_q(24) xor lfsr_q(27) xor lfsr_q(30) xor lfsr_q(31) xor data_in(0) xor data_in(1) xor data_in(2) xor data_in(4) xor data_in(5) xor data_in(6) xor data_in(9) xor data_in(12) xor data_in(13) xor data_in(15) xor data_in(17) xor data_in(18) xor data_in(21) xor data_in(24) xor data_in(27) xor data_in(30) xor data_in(31);
    lfsr_c(13) := lfsr_q(1) xor lfsr_q(2) xor lfsr_q(3) xor lfsr_q(5) xor lfsr_q(6) xor lfsr_q(7) xor lfsr_q(10) xor lfsr_q(13) xor lfsr_q(14) xor lfsr_q(16) xor lfsr_q(18) xor lfsr_q(19) xor lfsr_q(22) xor lfsr_q(25) xor lfsr_q(28) xor lfsr_q(31) xor data_in(1) xor data_in(2) xor data_in(3) xor data_in(5) xor data_in(6) xor data_in(7) xor data_in(10) xor data_in(13) xor data_in(14) xor data_in(16) xor data_in(18) xor data_in(19) xor data_in(22) xor data_in(25) xor data_in(28) xor data_in(31);
    lfsr_c(14) := lfsr_q(2) xor lfsr_q(3) xor lfsr_q(4) xor lfsr_q(6) xor lfsr_q(7) xor lfsr_q(8) xor lfsr_q(11) xor lfsr_q(14) xor lfsr_q(15) xor lfsr_q(17) xor lfsr_q(19) xor lfsr_q(20) xor lfsr_q(23) xor lfsr_q(26) xor lfsr_q(29) xor data_in(2) xor data_in(3) xor data_in(4) xor data_in(6) xor data_in(7) xor data_in(8) xor data_in(11) xor data_in(14) xor data_in(15) xor data_in(17) xor data_in(19) xor data_in(20) xor data_in(23) xor data_in(26) xor data_in(29);
    lfsr_c(15) := lfsr_q(3) xor lfsr_q(4) xor lfsr_q(5) xor lfsr_q(7) xor lfsr_q(8) xor lfsr_q(9) xor lfsr_q(12) xor lfsr_q(15) xor lfsr_q(16) xor lfsr_q(18) xor lfsr_q(20) xor lfsr_q(21) xor lfsr_q(24) xor lfsr_q(27) xor lfsr_q(30) xor data_in(3) xor data_in(4) xor data_in(5) xor data_in(7) xor data_in(8) xor data_in(9) xor data_in(12) xor data_in(15) xor data_in(16) xor data_in(18) xor data_in(20) xor data_in(21) xor data_in(24) xor data_in(27) xor data_in(30);
    lfsr_c(16) := lfsr_q(0) xor lfsr_q(4) xor lfsr_q(5) xor lfsr_q(8) xor lfsr_q(12) xor lfsr_q(13) xor lfsr_q(17) xor lfsr_q(19) xor lfsr_q(21) xor lfsr_q(22) xor lfsr_q(24) xor lfsr_q(26) xor lfsr_q(29) xor lfsr_q(30) xor data_in(0) xor data_in(4) xor data_in(5) xor data_in(8) xor data_in(12) xor data_in(13) xor data_in(17) xor data_in(19) xor data_in(21) xor data_in(22) xor data_in(24) xor data_in(26) xor data_in(29) xor data_in(30);
    lfsr_c(17) := lfsr_q(1) xor lfsr_q(5) xor lfsr_q(6) xor lfsr_q(9) xor lfsr_q(13) xor lfsr_q(14) xor lfsr_q(18) xor lfsr_q(20) xor lfsr_q(22) xor lfsr_q(23) xor lfsr_q(25) xor lfsr_q(27) xor lfsr_q(30) xor lfsr_q(31) xor data_in(1) xor data_in(5) xor data_in(6) xor data_in(9) xor data_in(13) xor data_in(14) xor data_in(18) xor data_in(20) xor data_in(22) xor data_in(23) xor data_in(25) xor data_in(27) xor data_in(30) xor data_in(31);
    lfsr_c(18) := lfsr_q(2) xor lfsr_q(6) xor lfsr_q(7) xor lfsr_q(10) xor lfsr_q(14) xor lfsr_q(15) xor lfsr_q(19) xor lfsr_q(21) xor lfsr_q(23) xor lfsr_q(24) xor lfsr_q(26) xor lfsr_q(28) xor lfsr_q(31) xor data_in(2) xor data_in(6) xor data_in(7) xor data_in(10) xor data_in(14) xor data_in(15) xor data_in(19) xor data_in(21) xor data_in(23) xor data_in(24) xor data_in(26) xor data_in(28) xor data_in(31);
    lfsr_c(19) := lfsr_q(3) xor lfsr_q(7) xor lfsr_q(8) xor lfsr_q(11) xor lfsr_q(15) xor lfsr_q(16) xor lfsr_q(20) xor lfsr_q(22) xor lfsr_q(24) xor lfsr_q(25) xor lfsr_q(27) xor lfsr_q(29) xor data_in(3) xor data_in(7) xor data_in(8) xor data_in(11) xor data_in(15) xor data_in(16) xor data_in(20) xor data_in(22) xor data_in(24) xor data_in(25) xor data_in(27) xor data_in(29);
    lfsr_c(20) := lfsr_q(4) xor lfsr_q(8) xor lfsr_q(9) xor lfsr_q(12) xor lfsr_q(16) xor lfsr_q(17) xor lfsr_q(21) xor lfsr_q(23) xor lfsr_q(25) xor lfsr_q(26) xor lfsr_q(28) xor lfsr_q(30) xor data_in(4) xor data_in(8) xor data_in(9) xor data_in(12) xor data_in(16) xor data_in(17) xor data_in(21) xor data_in(23) xor data_in(25) xor data_in(26) xor data_in(28) xor data_in(30);
    lfsr_c(21) := lfsr_q(5) xor lfsr_q(9) xor lfsr_q(10) xor lfsr_q(13) xor lfsr_q(17) xor lfsr_q(18) xor lfsr_q(22) xor lfsr_q(24) xor lfsr_q(26) xor lfsr_q(27) xor lfsr_q(29) xor lfsr_q(31) xor data_in(5) xor data_in(9) xor data_in(10) xor data_in(13) xor data_in(17) xor data_in(18) xor data_in(22) xor data_in(24) xor data_in(26) xor data_in(27) xor data_in(29) xor data_in(31);
    lfsr_c(22) := lfsr_q(0) xor lfsr_q(9) xor lfsr_q(11) xor lfsr_q(12) xor lfsr_q(14) xor lfsr_q(16) xor lfsr_q(18) xor lfsr_q(19) xor lfsr_q(23) xor lfsr_q(24) xor lfsr_q(26) xor lfsr_q(27) xor lfsr_q(29) xor lfsr_q(31) xor data_in(0) xor data_in(9) xor data_in(11) xor data_in(12) xor data_in(14) xor data_in(16) xor data_in(18) xor data_in(19) xor data_in(23) xor data_in(24) xor data_in(26) xor data_in(27) xor data_in(29) xor data_in(31);
    lfsr_c(23) := lfsr_q(0) xor lfsr_q(1) xor lfsr_q(6) xor lfsr_q(9) xor lfsr_q(13) xor lfsr_q(15) xor lfsr_q(16) xor lfsr_q(17) xor lfsr_q(19) xor lfsr_q(20) xor lfsr_q(26) xor lfsr_q(27) xor lfsr_q(29) xor lfsr_q(31) xor data_in(0) xor data_in(1) xor data_in(6) xor data_in(9) xor data_in(13) xor data_in(15) xor data_in(16) xor data_in(17) xor data_in(19) xor data_in(20) xor data_in(26) xor data_in(27) xor data_in(29) xor data_in(31);
    lfsr_c(24) := lfsr_q(1) xor lfsr_q(2) xor lfsr_q(7) xor lfsr_q(10) xor lfsr_q(14) xor lfsr_q(16) xor lfsr_q(17) xor lfsr_q(18) xor lfsr_q(20) xor lfsr_q(21) xor lfsr_q(27) xor lfsr_q(28) xor lfsr_q(30) xor data_in(1) xor data_in(2) xor data_in(7) xor data_in(10) xor data_in(14) xor data_in(16) xor data_in(17) xor data_in(18) xor data_in(20) xor data_in(21) xor data_in(27) xor data_in(28) xor data_in(30);
    lfsr_c(25) := lfsr_q(2) xor lfsr_q(3) xor lfsr_q(8) xor lfsr_q(11) xor lfsr_q(15) xor lfsr_q(17) xor lfsr_q(18) xor lfsr_q(19) xor lfsr_q(21) xor lfsr_q(22) xor lfsr_q(28) xor lfsr_q(29) xor lfsr_q(31) xor data_in(2) xor data_in(3) xor data_in(8) xor data_in(11) xor data_in(15) xor data_in(17) xor data_in(18) xor data_in(19) xor data_in(21) xor data_in(22) xor data_in(28) xor data_in(29) xor data_in(31);
    lfsr_c(26) := lfsr_q(0) xor lfsr_q(3) xor lfsr_q(4) xor lfsr_q(6) xor lfsr_q(10) xor lfsr_q(18) xor lfsr_q(19) xor lfsr_q(20) xor lfsr_q(22) xor lfsr_q(23) xor lfsr_q(24) xor lfsr_q(25) xor lfsr_q(26) xor lfsr_q(28) xor lfsr_q(31) xor data_in(0) xor data_in(3) xor data_in(4) xor data_in(6) xor data_in(10) xor data_in(18) xor data_in(19) xor data_in(20) xor data_in(22) xor data_in(23) xor data_in(24) xor data_in(25) xor data_in(26) xor data_in(28) xor data_in(31);
    lfsr_c(27) := lfsr_q(1) xor lfsr_q(4) xor lfsr_q(5) xor lfsr_q(7) xor lfsr_q(11) xor lfsr_q(19) xor lfsr_q(20) xor lfsr_q(21) xor lfsr_q(23) xor lfsr_q(24) xor lfsr_q(25) xor lfsr_q(26) xor lfsr_q(27) xor lfsr_q(29) xor data_in(1) xor data_in(4) xor data_in(5) xor data_in(7) xor data_in(11) xor data_in(19) xor data_in(20) xor data_in(21) xor data_in(23) xor data_in(24) xor data_in(25) xor data_in(26) xor data_in(27) xor data_in(29);
    lfsr_c(28) := lfsr_q(2) xor lfsr_q(5) xor lfsr_q(6) xor lfsr_q(8) xor lfsr_q(12) xor lfsr_q(20) xor lfsr_q(21) xor lfsr_q(22) xor lfsr_q(24) xor lfsr_q(25) xor lfsr_q(26) xor lfsr_q(27) xor lfsr_q(28) xor lfsr_q(30) xor data_in(2) xor data_in(5) xor data_in(6) xor data_in(8) xor data_in(12) xor data_in(20) xor data_in(21) xor data_in(22) xor data_in(24) xor data_in(25) xor data_in(26) xor data_in(27) xor data_in(28) xor data_in(30);
    lfsr_c(29) := lfsr_q(3) xor lfsr_q(6) xor lfsr_q(7) xor lfsr_q(9) xor lfsr_q(13) xor lfsr_q(21) xor lfsr_q(22) xor lfsr_q(23) xor lfsr_q(25) xor lfsr_q(26) xor lfsr_q(27) xor lfsr_q(28) xor lfsr_q(29) xor lfsr_q(31) xor data_in(3) xor data_in(6) xor data_in(7) xor data_in(9) xor data_in(13) xor data_in(21) xor data_in(22) xor data_in(23) xor data_in(25) xor data_in(26) xor data_in(27) xor data_in(28) xor data_in(29) xor data_in(31);
    lfsr_c(30) := lfsr_q(4) xor lfsr_q(7) xor lfsr_q(8) xor lfsr_q(10) xor lfsr_q(14) xor lfsr_q(22) xor lfsr_q(23) xor lfsr_q(24) xor lfsr_q(26) xor lfsr_q(27) xor lfsr_q(28) xor lfsr_q(29) xor lfsr_q(30) xor data_in(4) xor data_in(7) xor data_in(8) xor data_in(10) xor data_in(14) xor data_in(22) xor data_in(23) xor data_in(24) xor data_in(26) xor data_in(27) xor data_in(28) xor data_in(29) xor data_in(30);
    lfsr_c(31) := lfsr_q(5) xor lfsr_q(8) xor lfsr_q(9) xor lfsr_q(11) xor lfsr_q(15) xor lfsr_q(23) xor lfsr_q(24) xor lfsr_q(25) xor lfsr_q(27) xor lfsr_q(28) xor lfsr_q(29) xor lfsr_q(30) xor lfsr_q(31) xor data_in(5) xor data_in(8) xor data_in(9) xor data_in(11) xor data_in(15) xor data_in(23) xor data_in(24) xor data_in(25) xor data_in(27) xor data_in(28) xor data_in(29) xor data_in(30) xor data_in(31);
	
	    return lfsr_c;

end;

	signal lfsr_c  :   std_logic_vector (31 downto 0);  -- ADDED register
	signal reg_crc32 :   std_logic_vector (31 downto 0); 
	
	begin 
	
	process (clk)  -- ADDED process
    begin
        if rst = '1' then
            lfsr_c <= x"FFFFFFFF";
        elsif rising_edge(clk) then  
            if crc_en = '1' then
                lfsr_c <= crc_word(lfsr_c, data_in); --crc32(reverse_vector(data_in), lfsr_c);
            end if;
        end if;
    end process;

	reg_crc32 <= lfsr_c;
    crc_out <= not reverse_vector(lfsr_c);  -- ADDED


end architecture crc_arch;
