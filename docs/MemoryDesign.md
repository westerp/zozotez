# Data structures #

Having already written EBF I have used two years perfecting the data structures of it. The dat astructures required for Zozotez are actually less complex than EBF. My plan for a data structures are follwing:

## Stack ##
Like EBF I place the stack at the lowest address with the start of the stack at the highest address. I'm using odd places in place of the program counter and even places as a utility stack. Before the lowest address of the first stack is a token which has the highest cell address (M=-1). In the final release I thing the stack will be 2x256 elements, but as an illustration I sho only 10 elements:

**U9 P9 U8 P8 U7 P7 U6 P6 U5 P5 U4 P4 U3 P3 U2 P2 U1 P1 U0 P0 M**

The stack uses no extra cells but when pushing/popping it will use a higher address as mark and therefore will under-run when pushing the last element.

## Symbol array ##
Like EBF which used an array to get pointer position of an variable or index of an macro, Zozotez will have a array of objects. The index of the array will be the hash value of a symbol and like EBF be 251 elements large. The elements in the array will be 3 references: **string\_ref**, **assoc\_ref** and **param\_list**. The top of the array is next to **M** of the stack but nt so close to interfere with them. The lowest index will be the highest memory address, just like the stack and will have a end marker, ends,  which needs to be zero.

**CR4 SR4 AR4 PL4 CR3 SR3 AR3 PL3 CR2 SR2 AR2 PL2 CR1 SR1 AR1 PL1 CR0 SR0 AR0 PL0 ENDS**

An array needs to be opened before elements can be fetched and closed afterwards. If 3rd. element is open CR0 and CR1 is 1 so a loop like `[<<<<]` from cr0 will move you to the cr of the active element.

The elements in the array are all indexes of the church data array which is Zozotez main memory.

The element **string\_ref** is the position of the first element of a sequence of cons where each car is the ascii value of the symbol.

The **assoc\_ref** is the index of which the symbol is associated with / evaluates to.

The **param\_list** is used to push the assoc\_ref when entering a function that uses this symbol as one of its parameter names.

## LISP registers ##
There are not really data structure but they are 6 cells located right after **ENDS** named **AX BX CD DX EX FX** that are general purpose registers for computation. In this area everything is done.

## LISP data array ##
To the right of FX we have **END** which marks the beginning of another array. Implemented in the same manner as the Symbol array, but starting at the lowest address and growing towards the end of memory. There are 3 elements in this as well **type**, **car**, **cdr**. This has also a 4th to navigate which element is open.

**END T0 CAR0 CDR0 T1 CAR1 CDR1 ... TN CARN CDRN**

Except for the symbol lookup and the stacks, everything is stored in one or more cons cells. The **type** dictates if the car contains data or a array index.

All of these data structures are then supported by [A bouch of Macroes](SupportLibrary.md) that work on them from the register area.