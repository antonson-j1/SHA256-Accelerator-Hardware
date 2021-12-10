// Helper for statistics
int get_num_cycles(void);
int get_num_instr(void);
static void stats_print_dec(unsigned int val, int digits, bool zero_pad);
int get_num_cycles(void)
{
	unsigned int num_cycles;
	__asm__ volatile ("rdcycle %0;" : "=r"(num_cycles));
	return num_cycles;
}
int get_num_instr(void)
{
	unsigned int num_instr;
	__asm__ volatile ("rdinstret %0;" : "=r"(num_instr));
	return num_instr;
}

static void stats_print_dec(unsigned int val, int digits, bool zero_pad)
{
	char buffer[32];
	char *p = buffer;
	while (val || digits > 0) {
		if (val)
			*(p++) = '0' + val % 10;
		else
			*(p++) = zero_pad ? '0' : ' ';
		val = val / 10;
		digits--;
	}
	while (p != buffer) {
		if (p[-1] == ' ' && p[-2] == ' ') p[-1] = '.';
		print_chr(*(--p));
	}
}