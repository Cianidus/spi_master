module spi_test();

	

	reg sys_clk;
	reg t_start;
	reg [7:0] d_in;
	wire [7:0] d_out;
	reg [3:0] t_size;
	wire cs;
	reg rstn;
	wire spi_clk;
	wire miso;
	wire mosi;
	wire read_en;

	simple_spi_m_bit_rw spi
	(
		.sys_clk(sys_clk),
		.t_start(t_start),
		.d_in(d_in),
		.d_out(d_out),
		.t_size(t_size),
		.cs(cs),
		.rstn(rstn),
		.spi_clk(spi_clk),
		.miso(miso),
		.mosi(mosi),
		.read_en(read_en)
	);

	assign miso = mosi;
	always
		#2 sys_clk = !sys_clk;

	initial
	begin
		sys_clk = 0;
		t_start = 0;
		d_in = 0;
		rstn = 0;
		t_size = 8;
		#4;
		rstn = 1;
	end

	initial
	begin
		$dumpfile("simple_spi.vcd");
		$dumpvars(0,spi_test);
	end

	integer i;
	task transact_test;
		input [7:0] data;
		begin
			d_in = data[7:0];
			#3 t_start = 1;
			#4 t_start = 0;
			for( i=0; i < 8; i++)
			begin
				#4;
			end
			#16;
		end
	endtask	

	initial
	begin
		#10;
		transact_test( {1'b0, 64'hDEADBEEF} );
		#1000;
		$finish;
	end

endmodule