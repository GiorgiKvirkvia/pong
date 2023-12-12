library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity anvyl_vga is
   Port(
		SYS_CLK_I 	: in  std_logic;
      VSYNC_O		: out std_logic;
		HSYNC_O		: out std_logic;
		RED_O			: out std_logic_vector(2 downto 0);
		GREEN_O		: out std_logic_vector(2 downto 0);
		BLUE_O		: out std_logic_vector(1 downto 0);
		SEG:out std_logic_vector(7 downto 0);
		AN:out std_logic_vector(2 downto 0);
		BTN0DWN : in std_logic;
		BTN1UP: in std_logic;
		BTN2DWN: in std_logic;
		BTN3UP: in std_logic;
		start_g: in std_logic;
		SP: in std_logic_vector(2 downto 0);
		clk:in std_logic;
		reset_ac:in std_logic;
		Led1:out std_logic
	);
end anvyl_vga;

architecture Behavioral of anvyl_vga is

	component clk_gen
		port(-- Clock in ports
			CLK_IN1           : in     std_logic;
			-- Clock out ports
			CLK_OUT1          : out    std_logic
		);
	end component;

	-- Sychronize Signals Generator
	component sync_gen
      Port( 
			PIX_CLK_I		: in  std_logic;
			HSYNC_O			: out std_logic;
			VSYNC_O			: out std_logic;
			PIX_CNT_O		: out std_logic_vector (9 downto 0);
			LINE_CNT_O		: out std_logic_vector (9 downto 0)			 
		);
   end component;
   signal pix_clk   : STD_LOGIC := '0'; --Divided clock
	signal line_cnt  : STD_LOGIC_VECTOR (9 DOWNTO 0);-- V line
	signal pix_cnt : STD_LOGIC_VECTOR (9 DOWNTO 0);-- H pixel
	signal x1   : integer := 200;
	signal y1   : integer := 250;
	signal x2   : integer := 750;
	signal y2   : integer := 250;
	signal ball_x: integer := 475;
	signal ball_y: integer := 265;
	signal dir_x: integer :=-1;
	signal dir_y: integer :=0;
	signal output: STD_LOGIC := '0';
	signal counter: std_logic_vector(21 downto 0);
	signal led_buffer: std_logic:='1';
	signal player_A :std_logic_vector(3 downto 0) :="0000";
	signal player_B :std_logic_vector(3 downto 0):="0000";	
	signal count_se:std_logic_vector(21 downto 0);
	signal A_buffer:std_logic_vector(7 downto 0):="00000000";
	signal B_buffer:std_logic_vector(7 downto 0):="00000000";
	signal spd : integer :=1;
begin
	clk_25m	:	clk_gen
		port map(-- Clock in ports
		CLK_IN1	=>	SYS_CLK_I,
		-- Clock out ports
		CLK_OUT1	=>	pix_clk
		);

   SYNC_GEN_INST : sync_gen
      port map (
			PIX_CLK_I => pix_clk,
			HSYNC_O => HSYNC_O,
			VSYNC_O => VSYNC_O,
			PIX_CNT_O => pix_cnt,
			LINE_CNT_O => line_cnt
			);
	RGB: process(pix_cnt,line_cnt)
	begin
	
			if pix_cnt >x1 and pix_cnt<(x1+15) and line_cnt>y1 and line_cnt<(y1+60) then 
				RED_O		<="111";
				GREEN_O	<=	"111";
				BLUE_O	<=	"11";
			elsif pix_cnt>x2 and pix_cnt<(x2+15) and line_cnt>y2 and line_cnt<(y2+60) then 
				RED_O		<="111";
				GREEN_O	<=	"111";
				BLUE_O	<=	"11";
			elsif pix_cnt>ball_x and pix_cnt<(ball_x+15) and line_cnt>ball_y and line_cnt<(ball_y+15) then
				RED_O		<="111";
				GREEN_O	<=	"111";
				BLUE_O	<=	"11";
			else
				RED_O		<=	(others=>'0');
				GREEN_O	<=	(others=>'0');
				BLUE_O	<=	(others=>'0');	
			end if;
	end process;
	Movement: process(pix_clk)
	begin
	if rising_edge(pix_clk) then
				counter<=counter+1;	
		if counter>=416667 then
			counter<=(others=>'0');
			if SP(0)='1' then
				spd<=2;
			elsif SP(1)='1' then
				spd<=3;
			elsif SP(2)='1' then
				spd<=4;
			end if;	
			if start_g='1' then
				if BTN0DWN='1' then
					y1<=y1+5;
					if y1>=470 then
						y1<=30; 
					end if;
				end if;
				if BTN1UP='1' then
					y1<=y1-5;
					if y1<=30 then
						y1<=470;
					end if;	
				end if;
				if BTN2DWN='1' then
					y2<=y2+5;
					if y2>=470 then
						y2<=30;
					end if;	
				end if;
				if BTN3UP='1' then
					y2<=y2-5;
					if y2<=30 then
						y2<=470;
					end if;	
				end if;
				ball_x<=ball_x+dir_x*spd;
				ball_y<=ball_y+dir_y*spd;
				if ball_x>=x2 then
					if ball_y>=y2 AND ball_y<=(y2+20) then
						dir_y<=1;
						dir_x<=-1;
					elsif ball_y>=(y2+20) AND ball_y<=(y2+40) then
							dir_y<=0;
							dir_x<=-1;
					elsif ball_y>=(y2+40) AND ball_y<=(y2+60) then
							dir_y<=-1;
							dir_x<=-1;		
					end if;		
				end if;
				if ball_x>=x2+15 then
					player_A<=player_A+1;
					ball_x<=475;
					ball_y<=265;
					dir_x<=-1;
				end if;
				if ball_x<=x1 then
					player_B<=player_B+1;					
					ball_x<=475;
					ball_y<=265;
					dir_x<=1;
				end if;				
					if player_A>9 OR player_B>9 then
						player_A<=(others=>'0');
						player_B<=(others=>'0');
					end if;					
				if ball_x<=x1+15 then
					if ball_y>=y1 AND ball_y<=(y1+20) then
						dir_y<=1;
						dir_x<=1;
					elsif ball_y>=(y1+20) AND ball_y<=(y1+40) then
						dir_y<=0;
						dir_x<=1;
					elsif ball_y>=(y1+40) AND ball_y<=(y1+60) then
						dir_y<=-1;
						dir_x<=1;
						end if;
					end if;	
				if ball_y>=500 then
						dir_y<=-1;
				end if;		
					if ball_y<=30 then
						dir_y<=1;
					end if;
			end if;	
				led_buffer<=not led_buffer;
		end if;	
	end if;	
	end process;	
with player_A select
				A_buffer <=  X"3F"  when "0000",
						X"06"  when "0001",
						X"5B"  when "0010",
						X"4F"  when "0011",
						X"66"  when "0100",
						X"6D"  when "0101",
						X"7D"  when "0110",
						X"07"  when "0111",
						X"7F"  when "1000",
						X"6F"  when "1001",
						X"3F"  when others;		
with player_B select
				B_buffer <=  X"3F"  when "0000",
						X"06"  when "0001",
						X"5B"  when "0010",
						X"4F"  when "0011",
						X"66"  when "0100",
						X"6D"  when "0101",
						X"7D"  when "0110",
						X"07"  when "0111",
						X"7F"  when "1000",
						X"6F"  when "1001",
						X"3F"  when others;							
score:process(pix_clk)
	begin
		if(rising_edge(pix_clk)) then
			 count_se<=count_se+1;	 
		if(count_se>=0 AND count_se<50000) then	
			AN(1) <='0';
			AN(0) <='1';
			AN(2)<='0';
			SEG<=B_buffer;
		elsif(count_se>=50000 AND count_se<100000) then
			AN(0)<='0' ;
			AN(1)<='1';
			AN(2)<='0';
			SEG<=X"40";
		elsif(count_se>=100000 AND count_se<150000) then
			AN(0)<='0' ;
			AN(1)<='0';
			AN(2)<='1';
			SEG<=A_buffer;
		end if;
		if(count_se>=150000) then
		count_se<=(others=>'0');
		end if;
		end if;
	end process;						
						
	Led1<=led_buffer;
end Behavioral;
