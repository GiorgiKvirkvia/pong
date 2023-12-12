
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sync_gen is
	Port( 
		PIX_CLK_I		: in  std_logic;
		HSYNC_O			: out std_logic;
		VSYNC_O			: out std_logic;
		PIX_CNT_O		: out std_logic_vector (9 downto 0);
		LINE_CNT_O		: out std_logic_vector (9 downto 0)			 
	);
end sync_gen;

architecture Behavioral of sync_gen is

   -- Sync signals
	signal cTickLine  : std_logic_vector (9 downto 0) := "0000000000"; --10-bit counter for lines
   signal cTickPixel : std_logic_vector (9 downto 0) := "0000000000"; --10-bit counter for pixels
	
	signal syncHInt : std_logic := '0'; -- Internal vsync,so we can check its state
	signal syncVInt : std_logic := '0'; -- Internal hsync," " "
	
	--Sync compare constants
	constant cTickLineChk  : std_logic_vector (9 downto 0) := "1000001101";    --pixel H(525)
	constant cTickPixelChk : std_logic_vector (9 downto 0) := "1100100000";    --pixel W(800)
	constant cTickVsyncPulseChk : std_logic_vector (1 downto 0) := "10";       --vsync pulse width(line clocks)
	constant cTickHsyncPulseChk : std_logic_vector (6 downto 0) := "1100000";  --hsync pulse width(pixel clocks)

begin
	
   process(PIX_CLK_I)
	begin
	   if PIX_CLK_I'Event and PIX_CLK_I = '1' then
		
			-- Run the line counter, start vsync if necessary
			if(cTickLine = cTickLineChk - 1) then
				syncVInt <= '1';
				cTickLine <= "0000000000";
			end if;
			
			-- Run the pixel counter, start hsync if necessary
			if(cTickPixel = cTickPixelChk - 1) then
				syncHInt <= '1';
				cTickPixel <= "0000000000";
				cTickLine <= cTickLine + 1;
			else cTickPixel <= cTickPixel + 1;			
			end if;
			
			--Checks vsync pulse duration
			if(syncVInt = '1') then
				if(cTickLine = cTickVsyncPulseChk) then
					syncVInt <= '0';
				end if;
			end if;	
		
			--Checks hsync pulse duration
			if(syncHInt = '1') then
				if(cTickPixel +1 = cTickHsyncPulseChk) then
					syncHInt <= '0';
				end if;
			end if;
		end if;		
	end process;
	
	LINE_CNT_O <= cTickLine;
	PIX_CNT_O <= cTickPixel;
	HSYNC_O <= syncHInt;
	VSYNC_O <= syncVInt;

end Behavioral;
