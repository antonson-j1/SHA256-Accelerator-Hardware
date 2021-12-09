// Helper for statistics
int get_num_cycles(void);
int get_num_instr(void);
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