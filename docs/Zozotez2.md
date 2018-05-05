# Zozotez Deux #
I'm currently thinking of making a lexical scoped Zozotez Compiler. The thought is to implement a close relative to Scheme so that it can be bootstrapped with Scheme and hopefully self contained.

## What is good with the current Zozotez? ##

  * It freaking works (that freaks me out every time)
  * It's touring complete
  * The whole LISP is available
  * source is readable (much better than EBF itself)

## So what is wrong with Zozotez? ##

  * Hash collisions on symbols. (irritating)
  * interpreters with byte sized cells has only 255 cons memory.
  * Dynamic scoping (like the original LISP)
  * macro-expansion every time a function is run rather at evaluation time
  * no closures in functions
  * only thing implemented in BF is eval
  * No garbage collection
  * No compilation (a lot happens every time code gets evaluated)
  * A lot of consing (relative to no per-evaluation)
  * programs are data
  * Not written in itself :(

## Requirements for a Zozotez compiler ##

  * eval works pretty much as in Zozotez, but unused features are not incorporated in the build. eval itself will not be a primary operator. Eg. eiod is a R5RS-compatible eval for scheme implementations without eval thus eval can be implemented as a library function.
  * Runtime also doesn't know about macroes. In the compiler I want syntax-rules based macroes, perhaps borrowing som ecode from eiod.
  * parameters either on stack or in registers in our runtime machine
  * all the global stuff already evaluated compile time
  * symbols have to be completly different. Maybe implemented by read as trie structure with leafs pointing towards the address which again has pointer to the representation and the global address accociated with it. Symbls used in code will always already be expanded such that function arguments really are not symbol bindings but stack pointer index/register index
  * set-car!, set-cdr! but no set! Since we don't use symbols we might just box it so that (lambda (x) (lambda () (set! x (+ x 1)) x)) becomes (lambda (x) (let ((x2 (cons x '())) (lambda () (set-car x2 (+ (car x2) 1)) (car x2))).
  * optmization of expressions that only has constants. eg. ((lambda (x)(+ 5 x) 10) doesn't actualy need to be done in BF at all.
  * a function that is not recursive or (self) tail recursive and that consists of primitives can be compiled to be a primitive
  * other than (), #f and #t all other procedures and constants are mapped such that it leaves as little footprint as possible. eg (eq? '(a b c) '(a b c)) => #t if not optimized (since (a b c) gets reused) or #f (compilation optimized away the expression) and at compilation time they were different.
  * Try to write it is as little of scheme as possible and make sure it works in Stalin, Racket (r5rs module)++

## Runtime ##

### Memory map ###
A 8-bit BF has it's limits, but with so much less to be evaluated we might leave it as an option to either use one or two cell addressing. We might even have a compile time option to set the memory limit and in two cell addressing we might square that to get as little movement as possible. More cells per cons also means more movement though.


### core ###
This list should not be very long. I assume that pc-stack contains the program counter and util-stack the arguments. Procedures will have two forms. One compiled where the arhuments are registers, and another where it's a primitive procedure in it's own right.
  * a procedure takes it's arguments from stack, cleans it up and returns it's values on stack. eg. cons will reduce stack by 1 since it take two arguments and returns one.
  * (argument index) retrieves an argument from stack/registes. Index 0 is the last bound. eg. in ((lambda (x) (+ ((lambda (y) (+ y x)) 10) x) (read)) x will have index 1 when it's free in the innner lambda and 0 when it's bound. eg. ((lambda (x) (+ ((lambda (y) (+ (argument 0) (argument 1))) 10) (argument 0)) (read))
  * cons, type, car, cdr, set-type!, set-car!, set-cdr!, +, -, eq? that works on addresses such that it can create all data types we have. In source we might prefix them such that they don't collide with similar operations meant for pairs only.
  * read-char, write-char
  * if,  lambda, list-lambda, constant->address, syntax-rules

Imagine the expression:
```
(letrec ((x (lambda (y) 
               (if (= y 0)
                   #f 
                   (begin 
                       (display "Foo!\n") 
                       (x (- y 1)))))))
    (x (read-number)))

(define (= x y)
   (or (eq? x y)
       (and (eq? (type x) (type y))
            (eq? (car x) (car y)))))

;;but we know 0 is a number... why not do (in Zozotez macro style/EBF)
$ax = &stack_pop
%ax &lis_open
;; if we want to check type we do it here
%ax &get_car
whilen t not zero
(
  %ax- 
  $bx|"Foo!"(-)
)
%ax+ &stack_push ; return #f

```