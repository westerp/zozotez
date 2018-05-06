Welcome to Zozotez. Zozotez, which means Lisp in French (infinitive zozoter, but we use [polite form](http://en.wikipedia.org/wiki/T-V_distinction))
is a **tail recursive** Lisp interpreter which runs under any `BrainFuck`
environment. It's a fully LISP1 compliant interpreter if used with the largest bootstrap expression when started up. Without it it's still LISP1, but with other symbols. See below.

![http://sylwester.no/gcodeimg/zozotez.png](http://sylwester.no/gcodeimg/zozotez.png)

The summer 2010 and 2011 I created [EBF](http://sylwester.no/ebf-compiler/). A Compiler for a superset of `BrainFuck` which makes `BrainFuck` object code. I wrote it because I wanted to learn how programming languages was bootstrapped. It is of course written in itself. EBF is the language I have written Zozotez. Zozotez is in itself extendable since it has the power of both functions and macroes :)

`BrainFuck` is an Esoteric language/turing tarpit that only has
enough instructions to become Turing Complete which means that
it is possible to create any application with it, but not as
easy as some other programming languages. Daniel Cristofani wrote so elegantly:
"- a language designed for the amusement of programmers". For more information
on `Brainfuck` see [Wikipedia](http://en.wikipedia.org/wiki/Brainfuck)

The idea of creating Lisp in `Brainfuck` started in 2007 when
talking with a collague with my new found fasination and
time waster: To create small brainfuck programs. Later that
day we talked about favorite programming language and he's
was Lisp. He said that the language is so easy to implement
that it can be written in `BrainFuck`. The original LISP
was based on research done by AI researcher John `McCarthy` in
the late 1950's which produced a paper in 1958 describing
the language which also included a interpreter written in
itself using only `10*` primitive operators that need to be
implemented in some underlying machinecode. For a breif
article on this see [This article](http://www.paulgraham.com/rootsoflisp.html)
which is slightly easier to understand than `McCarthy's`
own paper which is more mathematical than programmer-oriented.

`*` Actually it was 7 defined: quote,atom,eq,car,cdr,cons and cond. I say 10 because I have added list-lambda (functions) in addition to read and print for side effects. `BrainFuck` is actually Turing complete without the side effects too, but application would be harder to use as this must be emulated in either code or environment.

## Why do this? ##
Mostly for kicks. EBF and Zozotez are both projects that have everlasting enhancement potential while any puzzle is finished when you have laid the last piece. The fact that some people have thought about this, some has started, but never succeeded has motivated me as I feel I'm the first to successfully climb this mountain. I feel I have the know how to successfully implement LISP in any imperative machine architecture and not just LISP which relies on the underlying implementation to do certain things. [Peter Michaux' Scheme implementation](http://michaux.ca/articles/scheme-from-scratch-bootstrap-v0_1-integers) has similar properties and is an excellent blog how he did it step by step.

# Syntax overview #

Zozotez is a LISP dialect, but because of it's nature all except the symbols T and NIL have been given different, one char symbols. Here is the formal syntax with usual LISP equivalents.

## Special forms ##
  * **`"`** (lisp quote) A quote returns the argument unevaluated. If you'd like to have expr unaltererd. eg. (`"` expr) => expr
  * **`?`** (lisp if) if evaluates only the first argument and if that is true it will evaluate the next argument. If it is false and it will evaluate the third argument.eg. (? T 'one two) => one
  * **`\`** (lisp lambda) whole expression returns unaltered
  * **`~`** (lisp flambda) as lambda it returns unaltered

## Functions ##
All functions evaluate all its arguments, even excess arguments, befor invoking the functions.
  * **`=`** (lisp eq) returns T if first argument is pointer equal to second or the same symbol. eg. (= 'a 'a) => T
  * **`s`** (lisp atom) returns T if first argument is a symbol. eg (s NIL) => T
  * **`a`** (lisp car) returns the first element of the first argument, which must be a list. eg. (a '(q w)) => q
  * **`d`** (lisp cdr) returns the rest of the first argument, which must be a list. eg. (d '(q w)) => (w)
  * **`c`** (lisp cons) returns a new list consisting of the first argument begin the first element and the second argument being the rest of the list. eg. (c 'q '(w)) => (q w)
  * **`e`** (lisp eval) evaluates the first argument. Note that, as a function, the argument has already been evaluated once. eg. (e ''q) => q
  * **`r`** (lisp read) returns an unevaluated expression from keyboard. read can be used to read a line and will enclose that in a list. If what read is one expression it will return that. Excess closing parenthesis will be ignored but too few and it will still wait for more input.
  * **`p`** (lisp print) returns the first argument unchanged. It also prints the first argument as an expression. If there is a second argument it will for symbols NOT terminate it with a newline and for a list it will omitt the outer parenthesis. eg. (p '(this is a test) T) => (this is a test) printed: this is a test\n
  * **`:`** (lisp set) creates an asociation between the symbol in first argument to the expression in the second argument. eg. (= (: 'test '(this is a test)) test) => T
  * **`(\)`** (lisp (lambda)) returns the result from applying the user defined function definition
  * **`(~)`** (lisp (lambda)) evaluates the return from the result from applying the user defined  macro definition

## User defined functions ##
If an expression in the operation position evaluates to a list with the first element \ it is a lambda-expression. A lambda expression is a user defined function.
One can define a new function with set in this manner:
```
(: 'cons (\ (arg1 arg2) (c arg1 arg2)))
so that 
(cons 'a '(b)) => (a b)
```

We can also invoke it directly:
```
((\ (arg1 arg2) (c arg1 arg2)) 'a '(b)) => (a b)
```

Only the last expression returns something in a user defined function. If there are more than one expression it has to be for the side effects.

## User defined macroes ##
A macro is a function where the arguments are not evaluated before the execution and the resulting expression gets evaluated in the end. Thus:
((~(sym arg)(c :(c(c "(c sym))(c arg))))) a '(b))
evaluates the return of the body, which is (: (" a) (" (b))) which assosiates a with (b). You might have noticed that this implements setq.

## Implementation limitation ##
When read reads a symbol it creates a hash using a similar method as EBF. It has one symbol table for both functions, macroes and variables and they are prone to collisions. In EBF collisions were errors requiring you to change the name to something else, while collisions in Zozotez are not handeled so ` (eq 'p 'ok) ` returns T since they both have the same hash. To check your symbols do `'<symbol>` in a REPL and it will echo the stored string (which will not be the same as you entered if it's an collision). Together with dynamic scoping it is a serious flaw in Zozotez which I may fix in the future, but I feel there are other areas more cool (like garbage collection, numbers, tail call optimizations and precomputing (compilation) of functions. I also want to make lexical scoping, but the design with the o(1) hash lookup does not support such a scheme at this time.

## Examples ##
### quine ###
```
((\ (x) (list x (list (" ") x))) (" (\ (x) (list x (list (" ") x)))))
```

If you'd like to know about the design og Zozotez I've added some information on that, starting with [memory design](MemoryDesign.md).

# This site is a member of a `Web Ring`. #
To browse visit [The Esoteric Programming Languages Ring](http://ss.webring.com/navbar?f=l;y=webringcom44;u=defurl1)
<br /><br />
