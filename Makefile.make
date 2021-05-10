Start:
	bin/Stack.out


Stack: Main Protection UnitTests MyStack.h
	g++ -o bin/Stack.out bin/Stack_Main.o bin/UnitTests.o bin/Protection.o

SuperStack: MainDBG Protection UnitTests MyStack.h
	g++ -o bin/Stack.out bin/Stack_Main.o bin/UnitTests.o bin/Protection.o


Main: Stack_Main.cpp
	g++ -o bin/Stack_Main.o -c Stack_Main.cpp

MainDBG: Stack_Main.cpp
	g++ -o bin/Stack_Main.o -c Stack_Main.cpp -DSUPERDEBUG


Protection: Protection.cpp
	g++ -o bin/Protection.o -c Protection.cpp

UnitTests: UnitTests.cpp
	g++ -o bin/UnitTests.o  -c UnitTests.cpp
