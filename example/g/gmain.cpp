#include <iostream>
using namespace std;
extern "C" {
void g1(void);
void g2(void);
};
int main()
{
	cout << __FILE__ << ':' << "Hello World" << endl;
	g1();
	g2();
	return 0;
}
