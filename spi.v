
module spi_master

(
	// System side
	input rstn,
	input clk,
	input t_start,
	input [15:0] d_in,

	output wire mosi,
	output wire sck,
	output reg cs,
	output reg read_en
);

parameter reset = 0, idle = 1, load = 2, transact = 3, unload = 4;

reg [15:0] data;
reg [2:0] state;
reg [3:0] count;

assign sck  = (state == transact)? clk : 1'b0;
assign mosi = ( ~cs ) ? data[15] : 1'bz;

always @(posedge clk)
begin
	case (state)
	reset:
		begin
		cs <=1;
		read_en <=0;
		data <=0;
		if (t_start)
			state <= load;
		state <= idle;
		end
	idle:
		begin
			cs <=1;
			read_en <=1;
			data <= 0;
			if (t_start)
				state <= load;
			if (rstn)
				state <= reset;
		end	
	load:
		begin
			cs <=0;
			read_en <=0;
			data <= d_in;
			if (rstn)
				state <= reset;
			state <= transact;
		end
	transact:
		begin
			if (count == 4'hF) begin
				cs <= 1;
				state <= unload;
			end
			else begin 
				state <= transact;
				cs <= 0;
				read_en <=0;
				data <= {data[14:0], mosi};
			end
		end
	unload:
		begin
			cs <=1;
			read_en <=1;
			if(t_start)
				state <= load;
			if (rstn)
				state <= reset;
			state <= idle;			
		end
	default: state <= reset;
	endcase
end

always @(posedge clk)
	begin
	if (state == transact)
		count <= count +1;
	else	
		count <= 0;
	end
endmodule 	
