#include <stdio.h>
#include <conio.h>
#include <Python.h>

int main()
{
	char filename[] = "sha256_python.py";
	FILE* fp;

	Py_Initialize();

	fp = _Py_fopen(filename, "r");
	PyRun_SimpleFile(fp, filename);

	Py_Finalize();
	return 0;
}