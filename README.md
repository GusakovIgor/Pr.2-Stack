# Pr.2-Stack
# Introduction

### First of all I highly recommend you to read this README in my [Notion](https://www.notion.so/Super-protected-stack-e12adfb68cd14ea48b7b01f2a0f6d036) (it's more colourfull and clear). But if you don't want to, you can read it here.

### Let me introduce you a pretty cool, simple project, that can help to:

- Understand how classical data structure "stack" works in details
- Modify it to be very-very safety

### By the way you will:

- Have a deep dive into C pointers
- Understand memory allocation and reallocation
- Learn to write safety code

### First question about stack is "what is it?"

It's just a dynamic array, that works by special rules:

- You can't get element by index, you don't know, where the specific element is.
- But you can imagine stack as a pack of mentos. You won't know the taste of the dragees from the bottom until you get all the dragees above. Stack is the same. You can work only with "top" element.
- And of course when you're putting dragee in pack, you're updating top element, so in the next step you'll be able to get out only the dragee you put down on this step
- So you can push elements in stack and pop elements from stack. Pushing is like putting dragee in pack and popping is like taking "top" dragee out
- Also you can watch on "top" element without getting it out. That operation is called top
- We can also open mentos pack from the bottom and all dragees will fall down, so we will have only empty pack. Simillar, we can clear our stack
- And there is something else stack can do. It's implimented using dynamic array, so what will happen, when we'll put too much dragees in it? Segfault? Of course not, stack can expand when it's filled and it can free some space, when there are too few elements in it. Those operations are called expansion and free

![Introduction](https://github.com/GusakovIgor/Pr.2-Stack/blob/main/img/Stack%20-%20introduction.png)

### Implementation of all these functions you can find in Stack_Main.cpp

- They are really simple, there are just few comments about them in this toggle
    - Push is putting element in `data` and increasing `size`. Then it checks if `size == capacity` and if it's true calling StackExpansion.
    - StackExpansion doubles current `capacity`.
    - Pop is getting element out of `data`, decreasing `size`, and then, if `size ≤ 0.25 * capacity`, it's calling StackFree.
    - StackFree halves current `capacity`.
    - All not filled elements in `data` array must be filled with `NaN`.
    - There is special flag `is_empty` to know does stack empty or not.

# Protection

### This is the most interesting part of project which code you can find in Protection.cpp

There are 2 methods of protection, one (canaries) is permanent and another (hash) is optional. What are they?

## Canaries

Canaries protecting anybody from going beyond the array boundaries

- Little birds of justice (example)

    For example if you want to change elements in stack by yourself using pointer on array

    Of course in this case you should know what you're doing, but everyone can make a mistake. Just like this:

    `size_t size = stk->size + 1;`    
    `for (int i = size; i > 0; i--)`    
    `{`   
            `stk->data[i] -= 5;`    
            `printf ("%2d: %f\n", i, stk->data[i]);`    
            `ASSERT_OK (stk, "Demonstration");`   
    `}`

    If you'll start this code (simply printing all elements in stack changing them previously) with one element in stack it will break right boundary and only ASSERT_OK will tell you what happened. It will give you full information about error in "Logs.txt" file:
    
    ![Crashed_1](https://github.com/GusakovIgor/Pr.2-Stack/blob/main/img/Stack_Crashed_1.png)
    
    Don't panic, I'll tell you all about what happening here.

- Idea of Canaries

    ![Canaries](https://github.com/GusakovIgor/Pr.2-Stack/blob/main/img/Stack%20-%20canaries.png)

    And after constructing stack structure we saving pointers on canaries andd always checking, that they are equal with start value

    Of course user don't have access to canaries. He is working with pointer on stack, which is the same it would be without any protection.

    So if we can do such a thing with hole stack structure, why cannot we do that with array?

    ![Both Canaries](https://github.com/GusakovIgor/Pr.2-Stack/blob/main/img/Stack%20-%20both%20canaries.png)

## Hash

Hash is protecting user from changing something in stack by himself, not using stack functions

- The All-seeing Eye of Sauron (example)

    Example is rather similar to canaries. Trying to change and print array but without logical mistakes:

    `size_t size = stk->size;`    
    `for (int i = size; i > 0; i--)`    
    `{`   
        `       stk->data[i] -= 5;`   
        `       printf ("%2d: %f\n", i + 1, stk->data[i]);`   
        `       ASSERT_OK (stk, "Demonstration");`    
    `}`

    If you'll start this code ASSERT_OK will trigger end your program telling you to check out "Logs.txt" file:

    ![Crashed_2](https://github.com/GusakovIgor/Pr.2-Stack/blob/main/img/Stack_Crashed_2.png)

- Idea of Hash

    - After every "legal" operation (push, pop, clear, expansion, free) we updating hash of stack
    - ASSERT_OK calculate current hash and compares it with saved hash
        - If they don't match returning HASH_PROTECTION_ERROR
        - Hash is calculating by every byte in stack and it's array, so we need to do something with saved hash value (cause it saved in stack and will affect
          hash counting)
        - Every time we calculating hash, we saving current hash in temporary variable, replacing it with zero, calculating new hash and putting it in stack. Than
          comparing it with old one.
    - So user can arrange ASSERT_OKs in program to check for mistakes in filling or changing stack

# Building

My stack has two build modes: normal and superdebug. In normal mode only canaries are available and in superdebug mode hash checking is enabled too.

To build in normal mode: `make Stack -f Makefile.make`

To build in debug mode: `make SuperStack -f Makefile.make`

When you're starting a program built in normal mode `Demonstration()` function is called. It contains whatever you want to do to see how stack works.

When you're starting a program built in debug mode program is waiting from you information about how to start UnitTests (UnitTests.cpp)

That help is printing, when you typing `bin/Stack.out` without arguments:

"--Help"     Help Print with commands
"--All"         All Tests
"--None"    Without Unit Tests
"--Demo"   Start Demonstration

"1"    Test_StackPush
"2"    Test_StackPop
"3"    Test_StackTop
"4"    Test_StackExpansion
"5"    Test_StackFree

So you can use `Demonstration()` function in debug mode too.
