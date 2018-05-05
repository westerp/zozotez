# Having the program counter in the stack #
Zozotez has a stack which contains alternate expressions and an address to a list-element to set-car the result. Eg. When Zozotez is starting up it has these elements in the stack from top to bottom:

  * **address\_to\_expression** (eval (read))
  * **empty\_list\_elelemnt\_a** (NIL)

The address points to LISP data (eval (read)). Eval, or main-loop as I originally called it, pops the stack to a register and get the type. We have 5 types in Zozotez:
  * 0 (A) Available cell
  * 1 (N) Number. So far only used to store symbol strings
  * 2 (S) Symbol. car has hash value (symbol array index)
  * 3 (L) List-cons. Untouched
  * 4 (PA) List-pre-apply. Indicates that the first cmd field is evaluated but non if the other arguments.
  * 5 (AP) List-apply. Indicates that the expression is a valid function and that arguments are evaluated in normal order.

## BF cannot call a utility-function ##
It just doesn't work. Instead we have eval which is a loop that pops instruction and return-addresses and manipulate the stack every time we need to do eval again.
If we need to call a function in the middle of a  function, we split it up in a function-start and a function-end-part where function end-part gets pushed on stack first in function-start at the same time as the other calls to eval in  between. Next will then be those before ending by calling function-end. This can be done recursively so that the evaluations in between might themselves push other function-parts on the stack the also gets processed before function-end. Zozotez has 3 levels of evaluation.

# Main workings #
In Zozotez, Main handles type 2(S) directly, with 3(L) it creates a new cell of type list-pre-apply and connect it to the rest of the original expression. #'(NIL (read)) and pushed it on the stack. It will use the same return address as the original expression had. It then push the same address again on the stack. this time as an return addres and then it pushed the first element of the original expression, eval, to the stack. It is finished and the loop pops next expression to do and the loop restarts if the stack is not empty.

Stack contains now:
  * **address\_to\_arg0** eval
  * **address\_to\_new\_head\_of\_expression** #'(NIL (read))
  * **address\_to\_new\_head\_of\_expression** #'(NIL (read))
  * **empty\_list\_elelemnt\_a** (NIL)

## The type is Symbol ##
A symbol will be done by opening the symbol array and retrieveing the assoc\_ref and set-car-ing that to the result-address. the assoc\_ref of eval is a symbol **eval** which is in the lower memory area (actually 17). This address is then set-carred to the return-adress.

Stack contains now:
  * **address\_to\_new\_head\_of\_expression** #'(**eval** (read))
  * **empty\_list\_elelemnt\_a** (NIL)

## The first pre-apply list ##
Since this type is pre-apply, Main will check if car is the address of a known primitive function. **eval** happens not to be a special form (2-5), but a function (6-17). It changes pre-apply to apply (destructive) and pushes this back on stack. It then attached the cdr to a new list with the same length and push each cons as a return to each car of the original arguments in reverse order. Main is then finished.

Stack contains now:
  * **address\_to\_arg1\_of\_original\_expression** (read)
  * **address\_to\_arg1\_of\_new\_expression** (NIL)
  * **address\_to\_new\_head\_of\_expression** #'(**eval** NIL)
  * **empty\_list\_elelemnt\_a** (NIL)

Stack in next iteration:
  * **address\_to\_arg0** read
  * **address\_to\_arg1\_of\_original\_expression** #'(NIL)
  * **address\_to\_arg1\_of\_original\_expression** #'(NIL)
  * **address\_to\_arg1\_of\_new\_expression** (NIL)
  * **address\_to\_new\_head\_of\_expression** #'(**eval** NIL)
  * **empty\_list\_elelemnt\_a** (NIL)

Stack in next iteration:
  * **address\_to\_arg1\_of\_original\_expression** #'(**read**)
  * **address\_to\_arg1\_of\_new\_expression** (NIL)
  * **address\_to\_new\_head\_of\_expression** #'(**eval** NIL)
  * **empty\_list\_elelemnt\_a** (NIL)

## Apply list ##
Since type is List-apply we know that the expression has all the parameters evaluated and that it is a valid function. the switch will just go though the car-addresses of the firt element and do the code that matches, in this case the read-implementation which set-car the next element on stack. Lets say we read T

Stack after this is:
  * **address\_to\_new\_head\_of\_expression** #'(**eval** T)
  * **empty\_list\_elelemnt\_a** (NIL)


Next it will apply-eval which just pushes it firt argument on the stack without changing the return.
Stack after this:

address\_of\_T**T** **empty\_list\_elelemnt\_a** (NIL)

This is a symbol. It resolves to the address 1 (which is a symbol named T). It is set-carred to the last element of stack. Stack is empty and Main finishes,

# Why all these levels anyway? #
I probably could have left many steps out, but this way we can rename everything and send everything as parameters to functions, even in command position. Lets say we setq a read-eval-print-loop:
```
(set 'repl (lambda () (if (eq (print(eval(read))) 'exit) NIL (repl))))
```
set actually returns the expression so we can call it directly:
```
((set 'repl (lambda () (if (eq (print(eval(read))) 'exit) NIL (repl)))))
```

If you have looked at the source you already know this, but there are no symbols names lambda,if,eq,print,eval or read. they are given one char symbols, but we can easily fix that too. the symbol for lambda in Zozotez is \. Consider this example:
```
((\ (repl exit if macro lambda set eq atom car cdr cons read print eval) (repl))
  (\ () (if (eq (print(eval(read))) 'exit) NIL (repl)))
  (\ () 'exit)
  ? ~ \ : = s a d c r p e)
```

This creates a read-eval-print-loop with normal name binding to the functions through the arguments. The read-eval-print actually uses them in it's implementation. All arguments in any position in that list are either primitive form-symbols or functions. This will work when Zozotez is fully implemented.