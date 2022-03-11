// CS 370
// Approximation of the number PI through the Leibniz's series
// See: https://en.wikipedia.org/wiki/Leibniz_formula_for_%CF%80

#include <stdio.h>
#include <stdlib.h>

int main()
{
	long double	iterCnt = 1000000000.0;		// Number of iterations
	long double	i = 0.0;			// loop control variable
	long double	s = 1.0;			// signal for the next iteration
	long double	pi = 0.0;


	// simple headers
	printf("Approximation of the number PI through the Leibniz's series\n");
	printf("Please wait. Running...\n\n");

	// pi estimatation via Leibniz's series
	for(i = 1.0; i <= (iterCnt * 2.0); i += 2.0) {
		pi = pi + s * (4.0 / i);
		s = -s;
	}

	// show result
	printf("Aproximated value of PI = %1.16Lf\n", pi);

	return 0;
}

