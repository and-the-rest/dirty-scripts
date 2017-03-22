/*
 * mdtable: sample program to generate markdown table templates.
 * Version: 0.2
 * Author(s): rmNULL
 */
#include <stdio.h>
#include <stdlib.h>
/* TODO: Either write a better command line parser or use an existing
 * 	library(getopt?).
 */

#define DRAW_HEAD(cols, width) do { drawCols(cols, width, ' '); \
					drawCols(cols, width, '-'); \
				} while(0)

static void drawCols(	unsigned long n_fields,
			unsigned long width,
			char fill);

void drawTable( unsigned long n_rows,
		const unsigned long n_cols,
		const unsigned long width,
		const char fill);

void usage(void)
{
	printf("USAGE: %s -FLAG value ...\n", "./mdtable");
	puts("\t-h for help");
	exit(1);
}

void help(void)
{
	printf("USAGE: %s -FLAG value ...\n", "./mdtable");
	puts("Generate markdown table template\n");
	printf("FLAGS:\n %s\n %s\n %s\n %s\n %s\n",
			"-h: help menu",
			"-r: set number of rows",
			"-c: set number of columns",
			"-w: width of each field",
			"-f: character to be filled in");

	puts("Example: $ ./mdtable -cr 3 4 -w 4 -f + ");
	puts("\t $ ./mdtable # creates 4 x 4 table, 8 wide");
	puts("\t $ ./mdtable -wrc 12 8 4 > tabletemplate");
	exit(0);
}

int main(int argc, char *argv[])
{
	/* default values */
	char fill = ' ';

	unsigned long width = 8;
	unsigned long n_rows = 4;
	unsigned long n_cols = 4;

	char flag;
	char **value = NULL;

	while (--argc) {
		if (**++argv == '-') {
			value = argv;
			while ((flag = *++*argv) != '\0') {
				++value;
				if (*value == NULL && flag != 'h') {
					printf("ArgumentError: Value not provided for -%c.\n",
							flag);
					help();
				}

				switch (flag) {
				case 'r':
					n_rows = atol(*value);
					break;
				case 'c':
					n_cols = atol(*value);
					break;
				case 'w':
					width = atol(*value);
					break;
				case 'f':
					fill = **value;
					break;
				case 'h':
					help();
					break;
				default:
					usage();
					break;
				}
			}
		}
	}

	drawTable(n_rows, n_cols, width, fill);
	return 0;
}

/*
 * drawCols:
 * 	generates a column of Markdown table of given width and fills it with the
 * 	specified letter(or character).
 *
 *	Argument(s):
 *	n_fields: number of fields in the table.
 *	width: width of each field.
 *	fill: character to fill in the table.
 */
static void drawCols(unsigned long n_fields, const unsigned long width, const char fill)
{
	unsigned int n = 0;
	char *s = n_fields == 0 ? "" : "|\n";

	while (n_fields--) {
		putchar('|');
		n = width; /* restore the width of the field */

		while (n--) {
			 /* atleast a single hyphen needs to be present. */
			 /* on cases width <= 2, colon occupies(fills) all the fields */
			 /* of the table. */
			if (fill == '-' && width > 2
				&& (n == width - 1 || n == 0))
				putchar(':');
			else
				putchar(fill);
		}

	}

	printf("%s", s);
}

void drawTable( unsigned long n_rows,
		const unsigned long n_cols,
		const unsigned long width,
		const char fill)
{
	DRAW_HEAD(n_cols, width);
	while(n_rows--)
		drawCols(n_cols, width, fill);
}
